import mongoose from 'mongoose';
import {createHash,randomUUID} from 'node:crypto';
import {createReadStream} from 'node:fs';
import {stat,unlink} from 'node:fs/promises';
import path from 'node:path';
import {Track,Artist,Album,TrackArtist,AlbumTrack,AlbumArtist,AdminAuditLog} from '../models/index.js';
import {text,objectId,integer,choice} from '../utils/validation.js';
import {ApiError} from '../utils/apiError.js';
import {runCommand} from './mediaImport.service.js';
import {uploadRoot} from './audioStream.service.js';

export async function cleanupUploads(files={}){
  for(const file of Object.values(files).flat())if(file?.path&&path.dirname(path.resolve(file.path))===path.resolve(uploadRoot))await unlink(file.path).catch(()=>{});
}
function array(value,field){let parsed=value;try{if(typeof value==='string')parsed=JSON.parse(value);}catch{throw new ApiError(400,`${field} cần là mảng JSON.`);}if(!Array.isArray(parsed)||parsed.length<1||parsed.length>20)throw new ApiError(400,`${field} cần từ 1 đến 20 phần tử.`);return parsed;}
export async function inspectMedia(file,{cover=false,runner=runCommand}={}){
  const size=(await stat(file.path)).size;if(size>(cover?10:100)*1024*1024)throw new ApiError(413,cover?'Ảnh bìa tối đa 10 MB.':'Audio tối đa 100 MB.');
  let probe;try{probe=JSON.parse(await runner(process.env.FFPROBE_PATH||'ffprobe',['-v','error','-show_entries','format=duration:stream=codec_type,codec_name,width,height:stream_disposition=attached_pic','-of','json',file.path],{timeout:30000}));}catch(e){throw new ApiError(e.code==='ENOENT'?503:400,e.code==='ENOENT'?'Máy chủ chưa có FFprobe.':'File không chứa media hợp lệ.');}
  if(cover){const image=probe.streams?.find(s=>s.codec_type==='video');const expected={'.jpg':'mjpeg','.png':'png','.webp':'webp'}[path.extname(file.filename)];if(!image||image.codec_name!==expected||!(image.width>0&&image.height>0)||image.width*image.height>40000000)throw new ApiError(400,'Ảnh bìa không hợp lệ hoặc quá lớn.');return;}
  const audio=probe.streams?.find(s=>s.codec_type==='audio'),duration=Number(probe.format?.duration);
  const ext=path.extname(file.filename),codecs={'.mp3':/^mp3$/,'.wav':/^pcm_/,'.m4a':/^(aac|alac)$/,'.aac':/^aac$/,'.flac':/^flac$/,'.ogg':/^(opus|vorbis)$/};
  if(!audio||!codecs[ext]?.test(audio.codec_name)||!Number.isFinite(duration)||duration<=0||duration>7200||probe.streams.some(s=>s.codec_type==='video'&&!s.disposition?.attached_pic))throw new ApiError(400,'Audio không khớp định dạng hoặc thời lượng không hợp lệ.');
  try{await runner(process.env.FFMPEG_PATH||'ffmpeg',['-nostdin','-v','error','-i',file.path,'-f','null','-'],{timeout:120000});}catch{throw new ApiError(400,'Không giải mã được toàn bộ audio.');}
  const digest=createHash('sha256');for await(const chunk of createReadStream(file.path))digest.update(chunk);
  return {duration_ms:Math.round(duration*1000),verification:{duration_seconds:duration,size_bytes:size,sha256:digest.digest('hex'),full_decode_passed:true,verified_at:new Date()}};
}
export async function createUploadedTrack(body={},files={},actorId){
  if(!actorId)throw new ApiError(401,'Cần xác thực người tải lên.');
  const requested=choice(body.status||'PUBLISHED','status',['PUBLISHED','BANNED','ARCHIVED','UNRELEASED']);
  const state={PUBLISHED:'active',BANNED:'hidden',ARCHIVED:'hidden',UNRELEASED:'unreleased'}[requested];
  const title=text(body.title,'Tên bài hát',{max:300}),genre=body.genre===undefined?'':text(body.genre,'Thể loại',{min:0,max:80});
  const artistIds=body.artist_ids===undefined?null:array(body.artist_ids,'artist_ids').map(id=>objectId(id,'Artist ID'));
  if(artistIds&&(body.artist!==undefined||body.artists!==undefined))throw new ApiError(400,'Chỉ dùng artist_ids hoặc tên nghệ sĩ.');
  const artistNames=artistIds?null:(body.artists===undefined?[text(body.artist,'Nghệ sĩ',{max:120})]:array(body.artists,'artists').map(name=>text(name,'Nghệ sĩ',{max:120})));
  const albumId=body.album_id===undefined?null:objectId(body.album_id,'Album ID');
  if(albumId&&body.album!==undefined)throw new ApiError(400,'Chỉ dùng album_id hoặc tên album.');
  const albumTitle=body.album===undefined?'':text(body.album,'Album',{max:200});
  if(body.explicit!==undefined&&![true,false,'true','false'].includes(body.explicit))throw new ApiError(400,'explicit cần là boolean.');
  const audio=files.audio?.[0],cover=files.cover?.[0];if(!audio)throw new ApiError(400,'Cần tải lên file audio.');
  const measured=await inspectMedia(audio);if(cover)await inspectMedia(cover,{cover:true});
  const audioUrl='/uploads/'+audio.filename,coverUrl=cover?'/uploads/'+cover.filename:'';
  const trackNumber=integer(body.track_number,'track_number',{fallback:0,min:0,max:1000});
  let lyrics=[];if(body.synced_lyrics!==undefined){try{lyrics=typeof body.synced_lyrics==='string'?JSON.parse(body.synced_lyrics):body.synced_lyrics;}catch{throw new ApiError(400,'synced_lyrics cần là mảng JSON.');}if(!Array.isArray(lyrics)||lyrics.length>2000)throw new ApiError(400,'synced_lyrics không hợp lệ.');let previous=-1;lyrics=lyrics.map(line=>{if(!line||typeof line!=='object'||!Number.isSafeInteger(line.time_ms)||line.time_ms<previous||line.time_ms<0||line.time_ms>measured.duration_ms)throw new ApiError(400,'Mốc lời bài hát không hợp lệ.');previous=line.time_ms;return {time_ms:line.time_ms,text:text(line.text,'Lời bài hát',{max:1000})};});}
  const session=await mongoose.startSession();let saved;
  try{await session.withTransaction(async()=>{
    const db=mongoose.connection.db,setting=await db.collection('catalog_settings').findOne({_id:'active'},{session});
    const artists=[];
    if(artistIds){for(const id of artistIds){const artist=await Artist.findById(id).session(session);if(!artist)throw new ApiError(400,'Artist ID không tồn tại.');if(!artists.some(a=>String(a._id)===String(id)))artists.push(artist);}}
    else for(const name of [...new Set(artistNames)]){const key='local:artist:'+createHash('sha256').update(name.normalize('NFC').toLowerCase()).digest('hex');const artist=await Artist.findOneAndUpdate({source_key:key},{$setOnInsert:{name}},{upsert:true,new:true,runValidators:true,session});if(!artists.some(a=>String(a._id)===String(artist._id)))artists.push(artist);}
    let album;
    if(albumId){album=await Album.findById(albumId).session(session);if(!album)throw new ApiError(400,'Album ID không tồn tại.');}
    else if(albumTitle){const key='local:album:'+createHash('sha256').update(String(artists[0]._id)+':'+albumTitle.normalize('NFC').toLowerCase()).digest('hex');album=await Album.findOneAndUpdate({source_key:key},{$setOnInsert:{title:albumTitle,cover_url:coverUrl}},{upsert:true,new:true,runValidators:true,session});}
    const sourceId=randomUUID(),credits=artists.map(a=>({id:String(a._id),name:a.name,image_url:a.image_url||''}));
    const [track]=await Track.create([{title,genre,duration_ms:measured.duration_ms,explicit:body.explicit===true||body.explicit==='true',audio_url:audioUrl,cover_url:coverUrl,source_key:'local:'+sourceId,catalog_source:'local',catalog_dataset:setting?.dataset||'local-catalog',status:state,moderation_status:requested,synced_lyrics:lyrics,imported_at:new Date(),
      audio_cache:{storage:'upload',...measured.verification},catalog_metadata:{source_id:sourceId,artists:credits,album:album?{id:String(album._id),title:album.title,cover_url:album.cover_url,artists:credits.slice(0,1)}:null,artist_credit_kind:'admin_supplied',source_url:'',region:'INTL',full_audio_url:audioUrl,preview_url:'',content_kind:'music_recording',fetched_at:new Date().toISOString(),download_allowed:false}}],{session});
    await TrackArtist.insertMany(artists.map((a,i)=>({track_id:track._id,artist_id:a._id,role:i?'featured_artist':'main_artist'})),{session});
    if(album){await AlbumTrack.create([{track_id:track._id,album_id:album._id,track_number:trackNumber,disc_number:1}],{session});if(!await AlbumArtist.exists({album_id:album._id}).session(session))await AlbumArtist.create([{album_id:album._id,artist_id:artists[0]._id,credit_kind:'derived_track_main_artist',derived_from_track_id:track._id}],{session});}
    await AdminAuditLog.create([{actor_id:actorId,action:'TRACK_CREATED',target_id:track._id,target_type:'track',after:{title:track.title,audio_url:track.audio_url,artists:credits}}],{session});
    await db.collection('catalog_settings').updateOne({_id:'active'},{$inc:{tracks:state==='active'?1:0,revision:1},$set:{updated_at:new Date()},$setOnInsert:{dataset:'local-catalog',audio_only:true,imported_at:new Date()}},{upsert:true,session});saved=track;
  });return saved;}finally{await session.endSession();}
}
