import {Track,TrackArtist,AlbumTrack} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {text,objectId,pagination,escapeRegex} from '../utils/validation.js';
import {publicTracks} from './catalogPolicy.service.js';
export {streamAudioFile} from './audioStream.service.js';
const sorts=new Set(['-popularity','popularity','title','-title','-imported_at','imported_at','-createdAt']);
export async function getPublicTrack(id){
  const track=await Track.findOne({...await publicTracks(),_id:objectId(id,'Track ID')}).lean();
  if(!track)throw new ApiError(404,'Không tìm thấy bài hát.');return track;
}
export async function enrichTracks(records){
  if(!records.length)return [];
  const ids=records.map(t=>t._id);
  const [credits,albumLinks]=await Promise.all([
    TrackArtist.find({track_id:{$in:ids}}).populate('artist_id','name image_url verified').lean(),
    AlbumTrack.find({track_id:{$in:ids}}).populate('album_id','title album_type cover_url release_date').lean()
  ]);
  const artists=new Map(),albums=new Map();
  for(const r of credits)if(r.artist_id){const list=artists.get(String(r.track_id))||[];list.push({id:r.artist_id._id,name:r.artist_id.name,image_url:r.artist_id.image_url,verified:r.artist_id.verified,role:r.role});artists.set(String(r.track_id),list);}
  for(const r of albumLinks)if(r.album_id&&!albums.has(String(r.track_id)))albums.set(String(r.track_id),{id:r.album_id._id,title:r.album_id.title,album_type:r.album_id.album_type,cover_url:r.album_id.cover_url,release_date:r.album_id.release_date,track_number:r.track_number,disc_number:r.disc_number});
  return records.map(t=>{
    const album=albums.get(String(t._id));
    const dto=Object.fromEntries(['_id','title','duration_ms','explicit','isrc','popularity','preview_url','audio_url','cover_url','genre','synced_lyrics','status','catalog_source'].filter(k=>t[k]!==undefined).map(k=>[k,t[k]]));
    const artistList=artists.get(String(t._id))||[];
    const coverUrl=t.cover_url||album?.cover_url||'';
    const durationSeconds=Math.round((t.duration_ms||0)/1000);
    return {
      ...dto,
      id:String(t._id),
      artists:artistList,
      artist:artistList.map(a=>a.name).join(', '),
      ...(album?{album}:{}),
      album_title:album?.title||'',
      cover_url:coverUrl,
      coverUrl:coverUrl,
      imageUrl:coverUrl,
      duration:durationSeconds,
      durationSeconds:durationSeconds,
      audioUrl:t.audio_url||'',
      playsCount:t.popularity||0
    };
  });
}
export const enrichTrackDetails=async track=>track?(await enrichTracks([track.toObject?track.toObject():track]))[0]:null;
export async function getAllTracks(query={}){
  const {page,limit}=pagination(query),filter=await publicTracks();
  if(query.query!==undefined){const q=text(query.query,'query',{min:0,max:200});if(q)filter.title={$regex:escapeRegex(q),$options:'i'};}
  if(query.genre!==undefined)filter.genre=text(query.genre,'genre',{max:80});
  const sort=query.sort===undefined?'-popularity':text(query.sort,'sort',{max:30});if(!sorts.has(sort))throw new ApiError(400,'Tiêu chí sắp xếp không hợp lệ.');
  const [docs,total]=await Promise.all([Track.find(filter).sort(sort==='-createdAt'?'-imported_at':sort).skip((page-1)*limit).limit(limit).lean(),Track.countDocuments(filter)]);
  return {tracks:await enrichTracks(docs),pagination:{total,page,limit,totalPages:Math.ceil(total/limit)}};
}
// Read requests never count as a listening event.
export const getTrackById=async id=>enrichTrackDetails(await getPublicTrack(id));
export function toLegacySong(track){return {...track,id:String(track._id||track.id),artist:(track.artists||[]).map(a=>a.name).join(', '),album:track.album?.title||'',albumInfo:track.album||null,audioUrl:track.audio_url||'',coverUrl:track.cover_url||'',duration:(track.duration_ms||0)/1000,playsCount:track.popularity||0,isLossless:/\.(flac|wav)(?:\?|$)/i.test(track.audio_url||'')};}
