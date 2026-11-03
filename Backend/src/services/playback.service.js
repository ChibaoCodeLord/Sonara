import {createHash} from 'node:crypto';
import mongoose from 'mongoose';
import {Track,PlaybackSession,PlaybackEvent,ListeningHistory,PlaybackState} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {text,choice,idList,integer,pagination,boolean,objectId} from '../utils/validation.js';
import {transaction} from '../utils/transaction.js';
import {publicTracks} from './catalogPolicy.service.js';
import {enrichTracks,getPublicTrack} from './track.service.js';
import {pageInfo} from './catalogBrowse.service.js';

const number=(v,field,max)=>{if(typeof v!=='number'||!Number.isFinite(v)||v<0||v>max)throw new ApiError(400,`${field} không hợp lệ.`);return v;};
const eventKey=(v,name)=>{const s=text(v,name,{min:8,max:100});if(!/^[a-z\d._:-]+$/i.test(s))throw new ApiError(400,`${name} không hợp lệ.`);return s;};
export function mergeSegments(segments,start,end){
  const sorted=[...segments,...(end>start?[[start,end]]:[])].sort((a,b)=>a[0]-b[0]),merged=[];
  for(const pair of sorted){const last=merged.at(-1);if(last&&pair[0]<=last[1])last[1]=Math.max(last[1],pair[1]);else merged.push([...pair]);}
  if(merged.length>500)throw new ApiError(409,'Phiên phát có quá nhiều lần tua, hãy mở phiên mới.');return merged;
}
export function creditProgress(play,type,position,now){
  const elapsed=Math.max(0,now-new Date(play.last_event_at).getTime()),delta=position-play.last_position_ms;
  const canCredit=!play.paused&&['HEARTBEAT','PAUSE','COMPLETE'].includes(type)&&delta>0&&delta<=elapsed+1500;
  const amount=canCredit?Math.min(delta,elapsed,15000):0;
  const segments=mergeSegments(play.segments||[],Math.max(0,position-amount),position);
  return {segments,credited_ms:Math.min(play.duration_ms,segments.reduce((sum,[a,b])=>sum+b-a,0))};
}
export async function recordEvent(user,authSession,body,{now=Date.now}={}){
  const eventId=eventKey(body.event_id,'event_id'),playId=eventKey(body.play_id,'play_id');
  const type=choice(body.event_type,'event_type',['START','HEARTBEAT','PAUSE','RESUME','SEEK','COMPLETE']);
  const track=await getPublicTrack(body.song_id),duration=track.duration_ms;
  if(!Number.isFinite(duration)||duration<=0)throw new ApiError(409,'Bài hát chưa có thời lượng hợp lệ.');
  const position=Math.round(number(body.position_seconds,'position_seconds',duration/1000)*1000);
  if(body.duration_played_seconds!==undefined)number(body.duration_played_seconds,'duration_played_seconds',duration/1000);
  const context=body.context_type===undefined?'library':text(body.context_type,'context_type',{max:50});
  const hash=createHash('sha256').update(JSON.stringify([playId,String(track._id),type,position,context,body.duration_played_seconds??null])).digest('hex');
  return transaction(async session=>{
    const previous=await PlaybackEvent.findOne({user_id:user._id,event_id:eventId}).session(session);
    if(previous){if(previous.payload_hash!==hash)throw new ApiError(409,'event_id đã dùng với nội dung khác.');return {...previous.result,duplicate:true};}
    const timestamp=new Date(now());let play=await PlaybackSession.findOne({user_id:user._id,play_id:playId}).session(session);
    if(type==='START'){
      if(play)throw new ApiError(409,'play_id đã tồn tại.');
      await PlaybackSession.updateMany({user_id:user._id,ended:false},{$set:{ended:true,paused:true}},{session});
      [play]=await PlaybackSession.create([{user_id:user._id,auth_session_id:authSession,play_id:playId,track_id:track._id,duration_ms:duration,last_position_ms:position,last_event_at:timestamp}],{session});
      await ListeningHistory.create([{user_id:user._id,track_id:track._id,play_id:playId,played_at:timestamp,source:context}],{session});
    }else{
      if(!play||String(play.track_id)!==String(track._id)||String(play.auth_session_id)!==String(authSession))throw new ApiError(409,'Không tìm thấy phiên phát phù hợp.');
      if(play.ended)throw new ApiError(409,'Phiên phát đã kết thúc.');
      const progress=creditProgress(play,type,position,timestamp.getTime());const firstCompletion=!play.completed&&progress.credited_ms>play.duration_ms*0.8;
      play.set({...progress,last_position_ms:position,last_event_at:timestamp,paused:type==='PAUSE'?true:type==='RESUME'?false:play.paused,ended:type==='COMPLETE',completed:play.completed||firstCompletion});await play.save({session});
      await ListeningHistory.updateOne({user_id:user._id,play_id:playId},{$set:{listened_ms:play.credited_ms,completed:play.completed,...(firstCompletion?{completed_at:timestamp}:{})}},{session});
      if(firstCompletion)await Track.updateOne({_id:track._id,status:'active'},{$inc:{popularity:1}},{session});
    }
    const result={play_id:playId,event_id:eventId,listened_ms:play.credited_ms,completed:play.completed,ended:play.ended,duplicate:false};
    await PlaybackEvent.create([{user_id:user._id,event_id:eventId,play_id:playId,payload_hash:hash,result}],{session});return result;
  });
}
export async function history(user,query){
  const {page,limit}=pagination(query,30);
  const [data]=await ListeningHistory.aggregate([{$match:{user_id:user._id,listened_ms:{$gt:0}}},{$sort:{played_at:-1,_id:-1}},{$group:{_id:'$track_id',latest:{$first:'$$ROOT'}}},{$sort:{'latest.played_at':-1,_id:-1}},{$lookup:{from:'tracks',localField:'_id',foreignField:'_id',pipeline:[{$match:await publicTracks()}],as:'track'}},{$unwind:'$track'},{$facet:{total:[{$count:'count'}],rows:[{$skip:(page-1)*limit},{$limit:limit}]}}]);
  const rows=data?.rows||[],tracks=await enrichTracks(rows.map(r=>r.track));return {history:rows.map((r,i)=>({track:tracks[i],played_at:r.latest.played_at,listened_ms:r.latest.listened_ms,completed:r.latest.completed})),pagination:pageInfo(data?.total[0]?.count||0,page,limit)};
}
export async function getQueue(user){
  const row=await PlaybackState.findOne({user_id:user._id}).lean();
  const ids=Array.isArray(row?.queue)?row.queue.filter(id=>id instanceof mongoose.Types.ObjectId||typeof id==='string'&&/^[a-f\d]{24}$/i.test(id)):[];
  const tracks=ids.length?await Track.find({...await publicTracks(),_id:{$in:ids}}).lean():[],map=new Map(tracks.map(t=>[String(t._id),t]));
  const visible=ids.filter(id=>map.has(String(id))),current=row?.current_track_id&&map.has(String(row.current_track_id))?String(row.current_track_id):visible.length?String(visible[0]):null;
  return {song_ids:visible.map(String),tracks:await enrichTracks(visible.map(id=>map.get(String(id)))),current_index:Math.max(0,visible.findIndex(id=>String(id)===current)),current_track_id:current,position_ms:current===String(row?.current_track_id)?row?.position_ms||0:0,revision:row?.revision||0,is_playing:!!current&&!!row?.is_playing,repeat_mode:row?.repeat_mode||'off',shuffle:row?.shuffle||false};
}
export async function setQueue(user,body){
  const ids=idList(body.song_ids),index=integer(body.current_index,'current_index',{fallback:0,min:0,max:Math.max(0,ids.length-1)}),revision=integer(body.expected_revision,'expected_revision',{fallback:0,min:0,max:Number.MAX_SAFE_INTEGER});
  const repeat=body.repeat_mode===undefined?'off':choice(body.repeat_mode,'repeat_mode',['off','track','context']);
  const tracks=await Track.find({...await publicTracks(),_id:{$in:ids}}).select('_id duration_ms').lean();if(tracks.length!==ids.length)throw new ApiError(400,'Queue chứa bài không công khai hoặc không tồn tại.');
  const position=integer(body.position_ms,'position_ms',{fallback:0,min:0,max:tracks.find(t=>String(t._id)===String(ids[index]))?.duration_ms||0});
  await transaction(async session=>{
    const row=await PlaybackState.findOne({user_id:user._id}).session(session);if((row?.revision||0)!==revision)throw new ApiError(409,'Queue đã thay đổi. Hãy tải lại.');
    const values={queue:ids,current_index:index,current_track_id:ids[index]||null,position_ms:position,is_playing:ids.length>0&&(body.is_playing===undefined?false:boolean(body.is_playing,'is_playing')),shuffle:body.shuffle===undefined?false:boolean(body.shuffle,'shuffle'),repeat_mode:repeat,updated_at:new Date(),revision:revision+1};
    if(row)await PlaybackState.updateOne({_id:row._id},{$set:values},{session});else await PlaybackState.create([{user_id:user._id,...values}],{session});
  });return getQueue(user);
}
