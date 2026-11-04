import mongoose from 'mongoose';
import {createHash} from 'node:crypto';
import {Track,Artist,TrackArtist,ContentReport,AdminAuditLog} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {text,objectId,choice,boolean,pagination,integer} from '../utils/validation.js';
import {applyTrackMetadata,jsonArray} from './adminMetadata.service.js';
import {dateFilter} from './adminRead.service.js';
import {transaction} from '../utils/transaction.js';
import {activeCatalogSetting,publicTrackFilter} from './catalogPolicy.service.js';
import {getPublicTrack} from './track.service.js';
import {pageInfo} from './catalogBrowse.service.js';

export async function touchCatalog(session){
  const settings=await activeCatalogSetting(),tracks=await Track.countDocuments(publicTrackFilter(settings)).session(session);
  await mongoose.connection.db.collection('catalog_settings').updateOne({_id:'active'},{$inc:{revision:1},$set:{tracks,updated_at:new Date()}},{upsert:true,session});
}
const auditSnapshot=t=>({title:t.title,genre:t.genre,status:t.status,moderation_status:t.moderation_status,deleted_at:t.deleted_at||null,revision:t.revision||0,cover_url:t.cover_url,album:t.catalog_metadata?.album,lyrics_count:t.synced_lyrics?.length||0});
export async function editTrack(user,id,body={},remove=false,options={}){
  const _id=objectId(id,'Track ID'),update={};
  if(body.title!==undefined)update.title=text(body.title,'title',{max:300});if(body.genre!==undefined)update.genre=text(body.genre,'genre',{max:80});
  if(body.explicit!==undefined)update.explicit=boolean(body.explicit,'explicit');
  if(body.status!==undefined){const status=choice(body.status,'status',['active','hidden','unreleased','PUBLISHED','BANNED','ARCHIVED','UNRELEASED']);update.status=({PUBLISHED:'active',BANNED:'hidden',ARCHIVED:'hidden',UNRELEASED:'unreleased'})[status]||status;update.moderation_status=({active:'PUBLISHED',hidden:'BANNED',unreleased:'UNRELEASED'})[status]||status;update.deleted_at=null;}
  const names=body.artists!==undefined?jsonArray(body.artists,'artists',20):body.artist!==undefined?[body.artist]:undefined;
  if(names!==undefined&&(!Array.isArray(names)||!names.length||names.length>20))throw new ApiError(400,'artists cần từ 1 đến 20 tên.');
  const artistNames=names?.map(n=>text(n,'artist',{max:120}));
  if(artistNames&&body.artist_ids!==undefined)throw new ApiError(400,'Chỉ dùng tên hoặc ID nghệ sĩ.');
  if(!remove&&!Object.keys(update).length&&!artistNames&&!['artist_ids','album','album_id','synced_lyrics'].some(k=>body[k]!==undefined)&&!options.coverUrl)throw new ApiError(400,'Không có metadata cập nhật hợp lệ.');
  return transaction(async session=>{
    const track=await Track.findById(_id).session(session);if(!track)throw new ApiError(404,'Không tìm thấy bài hát.');const before=auditSnapshot(track);
    if(body.expected_revision!==undefined&&integer(body.expected_revision,'expected_revision',{min:0,max:Number.MAX_SAFE_INTEGER})!==(track.revision||0))throw new ApiError(409,'Bài hát đã thay đổi. Hãy tải lại.');
    if(remove)track.set({status:'hidden',moderation_status:'ARCHIVED',deleted_at:new Date()});else track.set(update);
    if(artistNames){
      const artists=[];for(const name of [...new Set(artistNames)]){const key='local:artist:'+createHash('sha256').update(name.normalize('NFC').toLowerCase()).digest('hex');const artist=await Artist.findOneAndUpdate({source_key:key},{$setOnInsert:{name}},{session,upsert:true,new:true,runValidators:true});if(!artists.some(a=>String(a._id)===String(artist._id)))artists.push(artist);}
      await TrackArtist.deleteMany({track_id:_id},{session});await TrackArtist.insertMany(artists.map((a,i)=>({track_id:_id,artist_id:a._id,role:i?'featured_artist':'main_artist'})),{session});
      track.catalog_metadata={...(track.catalog_metadata||{}),artists:artists.map(a=>({id:String(a._id),name:a.name,image_url:a.image_url||''})),artist_credit_kind:'admin_corrected'};
    }
    if(!remove)await applyTrackMetadata(track,body,session,options.coverUrl);
    track.revision=(track.revision||0)+1;await track.save({session});await touchCatalog(session);
    const after=auditSnapshot(track);await AdminAuditLog.create([{actor_id:user._id,action:remove?'TRACK_ARCHIVED':'TRACK_UPDATED',target_id:_id,target_type:'track',before,after:{...after,...(artistNames?{artists:artistNames}:{})}}],{session});
    return {id:String(_id),...after};
  });
}
export async function submitReport(user,id,body){
  const track=await getPublicTrack(id),reason=choice(body.reason,'reason',['COPYRIGHT','INAPPROPRIATE','BROKEN_AUDIO','WRONG_METADATA','OTHER']),description=body.description===undefined?'':text(body.description,'description',{min:0,max:2000});
  const filter={user_id:user._id,track_id:track._id,status:'PENDING'};const existing=await ContentReport.findOne(filter).lean();if(existing)return {id:String(existing._id),status:existing.status,duplicate:true};
  try{const row=await ContentReport.create({...filter,reason,description});return {id:String(row._id),status:row.status,duplicate:false};}catch(e){if(e.code!==11000)throw e;const row=await ContentReport.findOne(filter).lean();return {id:String(row._id),status:row.status,duplicate:true};}
}
export async function reports(query){
  const {page,limit}=pagination(query),filter={...dateFilter(query)};if(query.status)filter.status=choice(query.status,'status',['PENDING','RESOLVED','REJECTED']);
  if(query.reason)filter.reason=choice(query.reason,'reason',['COPYRIGHT','INAPPROPRIATE','BROKEN_AUDIO','WRONG_METADATA','OTHER']);if(query.track_id)filter.track_id=objectId(query.track_id);
  const [rows,total]=await Promise.all([ContentReport.find(filter).sort({created_at:-1,_id:-1}).skip((page-1)*limit).limit(limit).populate('track_id','title status').populate('user_id','display_name').lean(),ContentReport.countDocuments(filter)]);
  return {reports:rows.map(r=>({...r,id:String(r._id)})),pagination:pageInfo(total,page,limit)};
}
export async function resolveReport(user,id,body){
  const _id=objectId(id,'Report ID'),status=choice(body.status,'status',['RESOLVED','REJECTED']),note=body.resolution_note===undefined?'':text(body.resolution_note,'resolution_note',{min:0,max:2000}),hide=body.hide_track===undefined?false:boolean(body.hide_track,'hide_track');
  if(hide&&status!=='RESOLVED')throw new ApiError(400,'Chỉ gỡ bài khi chấp nhận báo cáo.');
  return transaction(async session=>{
    const row=await ContentReport.findById(_id).session(session);if(!row)throw new ApiError(404,'Không tìm thấy báo cáo.');if(row.status!=='PENDING')throw new ApiError(409,'Báo cáo đã được xử lý.');
    row.set({status,resolution_note:note,resolved_by:user._id,resolved_at:new Date()});await row.save({session});
    if(hide){const track=await Track.findById(row.track_id).session(session);if(!track)throw new ApiError(404,'Không tìm thấy bài hát của báo cáo.');const before=auditSnapshot(track);track.set({status:'hidden',moderation_status:'BANNED',revision:(track.revision||0)+1});await track.save({session});await touchCatalog(session);await AdminAuditLog.create([{actor_id:user._id,action:'TRACK_UPDATED',target_id:track._id,target_type:'track',before,after:auditSnapshot(track)}],{session});}
    await AdminAuditLog.create([{actor_id:user._id,action:'REPORT_RESOLVED',target_id:_id,target_type:'report',before:{status:'PENDING'},after:{status,resolution_note:note,hide_track:hide}}],{session});return {id:String(_id),status};
  });
}
export async function auditLogs(query){
  const {page,limit}=pagination(query),filter={...dateFilter(query)};if(query.action)filter.action=text(query.action,'action',{max:80});if(query.actor_id)filter.actor_id=objectId(query.actor_id);if(query.target_id)filter.target_id=objectId(query.target_id);
  const [logs,total]=await Promise.all([AdminAuditLog.find(filter).sort({created_at:-1,_id:-1}).skip((page-1)*limit).limit(limit).populate('actor_id','display_name').lean(),AdminAuditLog.countDocuments(filter)]);return {logs,pagination:pageInfo(total,page,limit)};
}
