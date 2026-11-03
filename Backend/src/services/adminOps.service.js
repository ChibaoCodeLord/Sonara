import mongoose from 'mongoose';
import {stat,statfs} from 'node:fs/promises';
import {Track,TrackArtist,Artist,AudioAudit,AdminAuditLog} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {objectId,choice} from '../utils/validation.js';
import {activeCatalogSetting} from './catalogPolicy.service.js';
import {adminScope} from './adminRead.service.js';
import {bulkCrawlStatus} from './youtubeBulk.service.js';
import {resolveTrackAudio,uploadRoot} from './audioStream.service.js';
import {runCommand} from './mediaImport.service.js';
import {transaction} from '../utils/transaction.js';
export const auditTasks=new Map();
let starting=false;
export async function ingestion(){const setting=await activeCatalogSetting(),[crawl,imports,sources]=await Promise.all([bulkCrawlStatus(),mongoose.connection.db.collection('catalog_imports').find({},{projection:{source:1,collection:1,complete:1,finishedAt:1,reconciliation:1}}).sort({finishedAt:-1}).limit(20).toArray(),Track.aggregate([{$match:await adminScope({})},{$group:{_id:'$catalog_source',count:{$sum:1}}},{$sort:{count:-1}}])]);return {dataset:setting?.dataset||null,imported_at:setting?.imported_at||null,crawl,imports,sources,controls:{crawl:false,retry:false,import:false},mode:'read_only',updated_at:new Date()};}
export async function audits(){return AudioAudit.find().select('-issues').sort({created_at:-1}).limit(15).lean();}
export async function auditDetail(id){const row=await AudioAudit.findById(objectId(id)).lean();if(!row)throw new ApiError(404,'Không tìm thấy đợt kiểm tra.');return row;}
export async function startAudit(user,body={}){
  const dataset=choice(body.dataset||'current','dataset',['current','all']);if(starting||auditTasks.size)throw new ApiError(409,'Đang có một đợt kiểm tra chạy trên máy chủ.');starting=true;
  try{
  const filter=await adminScope({dataset}),total=await Track.countDocuments(filter);if(total>10000)throw new ApiError(409,'Hãy chia dataset nhỏ hơn 10.000 bài để kiểm tra.');
  const job=await transaction(async session=>{const [row]=await AudioAudit.create([{actor_id:user._id,dataset,status:'running',total}],{session});await AdminAuditLog.create([{actor_id:user._id,action:'AUDIO_AUDIT_STARTED',target_id:row._id,target_type:'audio_audit',after:{dataset,total}}],{session});return row;});
  const task=(async()=>{
    try{
      const tracks=await Track.find(filter).select('title duration_ms audio_url audio_cache source_key youtube catalog_metadata').lean(),links=await TrackArtist.find({track_id:{$in:tracks.map(t=>t._id)}}).select('track_id artist_id').lean(),artists=new Set((await Artist.distinct('_id')).map(String));
      const credited=new Set(links.filter(l=>artists.has(String(l.artist_id))).map(l=>String(l.track_id))),counts={errors:0,warnings:0,info:0,local_checked:0,remote_unchecked:0},issues=[];
      const add=(t,severity,code,message)=>{counts[severity]++;if(issues.length<10000)issues.push({track_id:String(t._id),title:t.title,severity,code,message});};
      for(let i=0;i<tracks.length;i++){
        const t=tracks[i];if(!t.title?.trim())add(t,'errors','MISSING_TITLE','Thiếu tên bài.');if(!credited.has(String(t._id)))add(t,'warnings','MISSING_ARTIST','Chưa có nghệ sĩ hợp lệ trong quan hệ.');if(!(t.duration_ms>0))add(t,'warnings','UNKNOWN_DURATION','Chưa có thời lượng xác minh.');if(!t.catalog_metadata?.album)add(t,'info','UNKNOWN_ALBUM','Album chưa xác định; có thể không áp dụng.');
        if(!t.audio_url)add(t,'errors','MISSING_AUDIO','Chưa có full audio.');else{try{const media=resolveTrackAudio(t);if(media.file){const s=await stat(media.file);counts.local_checked++;if(!s.isFile()||!s.size)add(t,'errors','EMPTY_AUDIO','File audio rỗng hoặc không hợp lệ.');if(t.audio_cache?.size_bytes&&s.size!==t.audio_cache.size_bytes)add(t,'errors','SIZE_MISMATCH','Kích thước không khớp manifest.');if(!t.audio_cache?.full_decode_passed)add(t,'warnings','UNVERIFIED_DECODE','Chưa có chứng cứ giải mã đầy đủ.');}else{counts.remote_unchecked++;add(t,'info','REMOTE_UNCHECKED','URL remote chưa được tải/giải mã trong đợt kiểm tra local.');}}catch{add(t,'errors','UNAVAILABLE_LOCAL_AUDIO','Không đọc được file hoặc storage không hợp lệ.');}}
        if(i%100===99)await AudioAudit.updateOne({_id:job._id},{$set:{checked:i+1,counts}});
      }
      await AudioAudit.updateOne({_id:job._id},{$set:{status:'completed',checked:tracks.length,counts,issues,truncated:counts.errors+counts.warnings+counts.info>issues.length,finished_at:new Date()}});
    }catch{await AudioAudit.updateOne({_id:job._id},{$set:{status:'failed',error:'Không hoàn tất được kiểm tra. Hãy chạy lại.',finished_at:new Date()}}).catch(()=>{});}
  })().finally(()=>auditTasks.delete(String(job._id)));auditTasks.set(String(job._id),task);
  starting=false;return {id:String(job._id),status:'running'};
  }catch(e){starting=false;throw e;}
}
export async function recoverAudits(){await AudioAudit.updateMany({status:'running'},{$set:{status:'failed',error:'Máy chủ khởi động lại; hãy chạy lại đợt kiểm tra.',finished_at:new Date()}});}
let diagnostics;
export async function system(){if(diagnostics&&Date.now()-diagnostics.at<30000)return diagnostics.data;const tool=async(name,command)=>{try{const value=await runCommand(command,['-version'],{timeout:5000,maxOutput:50000});return {name,available:true,version:value.split(/\r?\n/)[0].slice(0,150)};}catch{return {name,available:false};}};const [ffmpeg,ffprobe,disk]=await Promise.all([tool('FFmpeg',process.env.FFMPEG_PATH||'ffmpeg'),tool('FFprobe',process.env.FFPROBE_PATH||'ffprobe'),statfs(uploadRoot).then(s=>({available_bytes:Number(s.bavail)*Number(s.bsize),total_bytes:Number(s.blocks)*Number(s.bsize)})).catch(()=>null)]);const data={checked_at:new Date(),database:mongoose.connection.readyState===1?'connected':'disconnected',uptime_seconds:Math.floor(process.uptime()),memory_mb:Math.round(process.memoryUsage().rss/1048576),tools:[ffmpeg,ffprobe],disk,active_audio_audits:auditTasks.size,capabilities:{crawl_controls:false,hum:false,assistant:false}};diagnostics={at:Date.now(),data};return data;}
