import {createHash} from 'node:crypto';
import {Artist,Album,AlbumArtist,AlbumTrack,TrackArtist} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {text,objectId,integer} from '../utils/validation.js';
import {inspectMedia} from './adminUpload.service.js';
export function jsonArray(value,field,max=2000){let parsed=value;try{if(typeof value==='string')parsed=JSON.parse(value);}catch{throw new ApiError(400,`${field} phải là mảng JSON.`);}if(!Array.isArray(parsed)||parsed.length>max)throw new ApiError(400,`${field} không hợp lệ.`);return parsed;}
export function lyrics(value,duration){let previous=-1;return jsonArray(value,'synced_lyrics').map(line=>{if(!line||!Number.isSafeInteger(line.time_ms)||line.time_ms<0||line.time_ms<previous||line.time_ms>duration)throw new ApiError(400,'Mốc thời gian lyrics không hợp lệ.');previous=line.time_ms;return {time_ms:line.time_ms,text:text(line.text,'lyrics.text',{max:1000})};});}
export async function inspectCover(files){const cover=files?.cover?.[0];if(files?.audio?.length)throw new ApiError(400,'Thay audio cần luồng xác minh riêng.');if(cover)await inspectMedia(cover,{cover:true});return cover?'/uploads/'+cover.filename:null;}
export async function applyTrackMetadata(track,body,session,coverUrl){
  if(body.synced_lyrics!==undefined)track.synced_lyrics=lyrics(body.synced_lyrics,track.duration_ms);
  if(coverUrl)track.cover_url=coverUrl;
  if(body.artist_ids!==undefined){
    if(body.artist!==undefined||body.artists!==undefined)throw new ApiError(400,'Chỉ dùng artist_ids hoặc tên nghệ sĩ.');
    const ids=jsonArray(body.artist_ids,'artist_ids',20).map(id=>objectId(id,'Artist ID'));if(!ids.length||new Set(ids.map(String)).size!==ids.length)throw new ApiError(400,'artist_ids cần ID duy nhất.');
    const artists=await Artist.find({_id:{$in:ids}}).session(session);if(artists.length!==ids.length)throw new ApiError(400,'Nghệ sĩ không tồn tại.');const map=new Map(artists.map(a=>[String(a._id),a]));
    await TrackArtist.deleteMany({track_id:track._id},{session});await TrackArtist.insertMany(ids.map((id,i)=>({track_id:track._id,artist_id:id,role:i?'featured_artist':'main_artist'})),{session});
    track.catalog_metadata={...(track.catalog_metadata||{}),artists:ids.map(id=>({id:String(id),name:map.get(String(id)).name,image_url:map.get(String(id)).image_url||''})),artist_credit_kind:'admin_corrected'};
  }
  if(body.album_id!==undefined||body.album!==undefined){
    if(body.album_id&&body.album)throw new ApiError(400,'Chỉ dùng album_id hoặc tên album.');
    let album;
    if(body.album_id){album=await Album.findById(objectId(body.album_id,'Album ID')).session(session);if(!album)throw new ApiError(400,'Album không tồn tại.');}
    else if(body.album){const title=text(body.album,'album',{max:200}),credit=await TrackArtist.findOne({track_id:track._id,role:'main_artist'}).session(session);const key='local:album:'+createHash('sha256').update(String(credit?.artist_id||'')+':'+title.normalize('NFC').toLowerCase()).digest('hex');album=await Album.findOneAndUpdate({source_key:key},{$setOnInsert:{title,cover_url:track.cover_url||''}},{upsert:true,new:true,session,runValidators:true});if(credit&&!await AlbumArtist.exists({album_id:album._id}).session(session))await AlbumArtist.create([{album_id:album._id,artist_id:credit.artist_id,credit_kind:'derived_track_main_artist',derived_from_track_id:track._id}],{session});}
    const previous=album?await AlbumTrack.findOne({track_id:track._id,album_id:album._id}).session(session):null;
    await AlbumTrack.deleteMany({track_id:track._id},{session});if(album)await AlbumTrack.create([{track_id:track._id,album_id:album._id,track_number:integer(body.track_number,'track_number',{fallback:previous?.track_number||0,min:0,max:1000}),disc_number:integer(body.disc_number,'disc_number',{fallback:previous?.disc_number||1,min:1,max:100})}],{session});
    track.catalog_metadata={...(track.catalog_metadata||{}),album:album?{id:String(album._id),title:album.title,cover_url:album.cover_url||''}:null,album_credit_kind:'admin_corrected'};
  }
}
