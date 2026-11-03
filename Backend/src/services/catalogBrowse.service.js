import {Track,TrackArtist,AlbumTrack,Artist,Album,AlbumArtist,Playlist,SearchHistory,Genre} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {text,objectId,pagination,escapeRegex,choice} from '../utils/validation.js';
import {publicTracks} from './catalogPolicy.service.js';
import {enrichTracks} from './track.service.js';

export const pageInfo=(total,page,limit)=>({total,page,limit,totalPages:Math.ceil(total/limit)});
export const slugify=value=>value.normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[đĐ]/g,'d').toLowerCase().replace(/[^a-z\d]+/g,'-').replace(/^-|-$/g,'');
export async function activeIds(extra={}){return Track.distinct('_id',{...await publicTracks(),...extra});}
export async function relatedIds(kind,extra={}){
  const ids=await activeIds(extra);return kind==='artist'?TrackArtist.distinct('artist_id',{track_id:{$in:ids}}):AlbumTrack.distinct('album_id',{track_id:{$in:ids}});
}
const artistFields='name image_url biography verified';
const albumFields='title album_type cover_url release_date release_date_precision label';
const dto=row=>({...row,id:String(row._id)});
export async function listEntities(kind,query={}){
  const {page,limit}=pagination(query,20);if(limit>50)throw new ApiError(400,'limit tối đa 50.');
  const Model=kind==='artist'?Artist:Album;
  const ids=await relatedIds(kind,query.genre===undefined?{}:{genre:text(query.genre,'genre',{max:80})});
  const filter={_id:{$in:ids}};
  if(query.query!==undefined)filter[kind==='artist'?'name':'title']={$regex:escapeRegex(text(query.query,'query',{min:0,max:200})),$options:'i'};
  const [rows,total]=await Promise.all([Model.find(filter).select(kind==='artist'?artistFields:albumFields).sort(kind==='artist'?{name:1,_id:1}:{title:1,_id:1}).skip((page-1)*limit).limit(limit).lean(),Model.countDocuments(filter)]);
  if(kind==='album'){
    const credits=await AlbumArtist.find({album_id:{$in:rows.map(r=>r._id)}}).populate('artist_id',artistFields).lean();
    for(const row of rows)row.artists=credits.filter(c=>String(c.album_id)===String(row._id)&&c.artist_id).map(c=>dto(c.artist_id));
  }
  return {[kind==='artist'?'artists':'albums']:rows.map(dto),pagination:pageInfo(total,page,limit)};
}
export async function artistDetail(id){
  const _id=objectId(id,'Artist ID'),ids=await relatedIds('artist');
  const artist=await Artist.findOne({_id:{$eq:_id,$in:ids}}).select(artistFields).lean();if(!artist)throw new ApiError(404,'Không tìm thấy nghệ sĩ.');
  const {FollowedArtist}=await import('../models/index.js');
  return {...dto(artist),followers_count:await FollowedArtist.countDocuments({artist_id:_id}),top_tracks:await artistTracks(id,5)};
}
export async function artistTracks(id,limit=10){
  const _id=objectId(id,'Artist ID');
  const links=await TrackArtist.find({artist_id:_id}).select('track_id').lean();
  const rows=await Track.find({...await publicTracks(),_id:{$in:links.map(l=>l.track_id)}}).sort({popularity:-1,_id:1}).limit(limit).lean();
  if(!rows.length&&!await Artist.exists({_id:{$eq:_id,$in:await relatedIds('artist')}}))throw new ApiError(404,'Không tìm thấy nghệ sĩ.');
  return enrichTracks(rows);
}
export async function albumDetail(id){
  const _id=objectId(id,'Album ID'),ids=await relatedIds('album');
  const album=await Album.findOne({_id:{$eq:_id,$in:ids}}).select(albumFields).lean();if(!album)throw new ApiError(404,'Không tìm thấy album.');
  const links=await AlbumTrack.find({album_id:_id}).sort({disc_number:1,track_number:1,_id:1}).lean();
  const tracks=await Track.find({...await publicTracks(),_id:{$in:links.map(l=>l.track_id)}}).lean();const map=new Map(tracks.map(t=>[String(t._id),t]));
  const credits=await AlbumArtist.find({album_id:_id}).populate('artist_id',artistFields).lean();
  return {...dto(album),artists:credits.filter(c=>c.artist_id).map(c=>dto(c.artist_id)),tracks:await enrichTracks(links.map(l=>map.get(String(l.track_id))).filter(Boolean))};
}
export async function genres(){const [values,inactive]=await Promise.all([Track.distinct('genre',await publicTracks()),Genre.distinct('slug',{active:false})]);return values.filter(Boolean).sort().map(name=>({name,slug:slugify(name)})).filter(g=>!inactive.includes(g.slug));}
export async function genreTracks(slug,query){
  const key=text(slug,'slug',{max:100}),matches=(await genres()).filter(g=>g.slug===key).map(g=>g.name);
  if(!matches.length)throw new ApiError(404,'Không tìm thấy thể loại.');
  const {page,limit}=pagination(query),filter={...await publicTracks(),genre:{$in:matches}};
  const [rows,total]=await Promise.all([Track.find(filter).sort({popularity:-1,_id:1}).skip((page-1)*limit).limit(limit).lean(),Track.countDocuments(filter)]);
  return {tracks:await enrichTracks(rows),pagination:pageInfo(total,page,limit)};
}
export async function search(query,user){
  const q=text(query.query,'query',{max:200}),type=choice(query.type||'all','type',['all','songs','artists','albums','playlists']),{page,limit}=pagination(query,20);
  const regex={$regex:escapeRegex(q),$options:'i'},result={};
  const run=async(key,Model,filter,fields)=>{
    const [rows,total]=await Promise.all([Model.find(filter).select(fields).sort({_id:1}).skip((page-1)*limit).limit(limit).lean(),Model.countDocuments(filter)]);
    result[key]=key==='songs'?await enrichTracks(rows):rows.map(dto);result[key+'_pagination']=pageInfo(total,page,limit);
  };
  const jobs=[];
  if(type==='all'||type==='songs')jobs.push((async()=>{
    const artists=await Artist.distinct('_id',{name:regex,_id:{$in:await relatedIds('artist')}});
    const linked=await TrackArtist.distinct('track_id',{artist_id:{$in:artists}}),base=await publicTracks();
    await run('songs',Track,{$and:[base,{$or:[{title:regex},{_id:{$in:linked}}]}]},'');
  })());
  if(type==='all'||type==='artists')jobs.push((async()=>run('artists',Artist,{_id:{$in:await relatedIds('artist')},name:regex},artistFields))());
  if(type==='all'||type==='albums')jobs.push((async()=>run('albums',Album,{_id:{$in:await relatedIds('album')},title:regex},albumFields))());
  if(type==='all'||type==='playlists')jobs.push(run('playlists',Playlist,{$and:[{name:regex},user?{$or:[{is_public:true},{owner_id:user._id},{collaborative:true,collaborator_ids:user._id}]}:{is_public:true}]},'name description image_url is_public owner_id'));
  await Promise.all(jobs);
  if(user){const filter={user_id:user._id,normalized:q.normalize('NFC').toLowerCase()},update={$set:{keyword:q,searched_at:new Date()}};try{await SearchHistory.updateOne(filter,update,{upsert:true});}catch(e){if(e.code!==11000)throw e;await SearchHistory.updateOne(filter,update);}const stale=await SearchHistory.find({user_id:user._id}).sort({searched_at:-1,_id:-1}).skip(100).select('_id').lean();if(stale.length)await SearchHistory.deleteMany({_id:{$in:stale.map(r=>r._id)},user_id:user._id});}
  return result;
}
export async function suggestions(query){
  const q=text(query.q,'q',{max:200}),regex={$regex:'^'+escapeRegex(q),$options:'i'};
  const [tracks,artists]=await Promise.all([Track.find({...await publicTracks(),title:regex}).select('title').sort({title:1,_id:1}).limit(5).lean(),Artist.find({_id:{$in:await relatedIds('artist')},name:regex}).select('name').sort({name:1,_id:1}).limit(5).lean()]);
  return [...tracks.map(t=>({id:String(t._id),type:'song',text:t.title})),...artists.map(a=>({id:String(a._id),type:'artist',text:a.name}))].slice(0,5);
}
