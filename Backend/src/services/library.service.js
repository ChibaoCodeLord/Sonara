import {FollowedArtist,LikedTrack,Artist,Track,Playlist} from '../models/index.js';
import {objectId,pagination} from '../utils/validation.js';
import {ApiError} from '../utils/apiError.js';
import {transaction} from '../utils/transaction.js';
import mongoose from 'mongoose';
import {publicTracks} from './catalogPolicy.service.js';
import {relatedIds,pageInfo} from './catalogBrowse.service.js';
import {enrichTracks} from './track.service.js';
export async function likedSongs(user,query){
  const {page,limit}=pagination(query,50);
  const [data]=await LikedTrack.aggregate([{$match:{user_id:user._id}},{$sort:{added_at:-1,_id:-1}},{$lookup:{from:'tracks',localField:'track_id',foreignField:'_id',pipeline:[{$match:await publicTracks()}],as:'track'}},{$unwind:'$track'},{$facet:{total:[{$count:'count'}],rows:[{$skip:(page-1)*limit},{$limit:limit}]}}]);
  const enriched=await enrichTracks((data?.rows||[]).map(r=>r.track));
  return {songs:enriched,tracks:enriched,pagination:pageInfo(data?.total[0]?.count||0,page,limit)};
}
export async function followingArtists(user,query){
  const {page,limit}=pagination(query),filter={user_id:user._id,artist_id:{$in:await relatedIds('artist')}};
  const [rows,total]=await Promise.all([FollowedArtist.find(filter).sort({followed_at:-1,_id:-1}).skip((page-1)*limit).limit(limit).populate('artist_id','name image_url verified').lean(),FollowedArtist.countDocuments(filter)]);
  return {artists:rows.filter(r=>r.artist_id).map(r=>({...r.artist_id,id:String(r.artist_id._id),followed_at:r.followed_at})),pagination:pageInfo(total,page,limit)};
}
export async function followArtist(user,id,desired){
  const _id=objectId(id,'Artist ID');if(!await Artist.exists({_id:{$eq:_id,$in:await relatedIds('artist')}}))throw new ApiError(404,'Không tìm thấy nghệ sĩ.');
  return transaction(async session=>{
    // Serialize toggles and the denormalized counter on the artist document.
    await Artist.updateOne({_id},{$inc:{followers_count:0}},{session});
    const filter={user_id:user._id,artist_id:_id},before=await FollowedArtist.findOne(filter).session(session),next=desired===undefined?!before:desired;
    if(next&&!before)await FollowedArtist.create([filter],{session});if(!next&&before)await FollowedArtist.deleteOne({_id:before._id},{session});
    const count=await FollowedArtist.countDocuments({artist_id:_id}).session(session);await Artist.updateOne({_id},{$set:{followers_count:count}},{session});return {following:next,followersCount:count};
  });
}
export async function libraryOverview(user){
  const [likes,artists,playlists,hum]=await Promise.all([likedSongs(user,{limit:'1'}),followingArtists(user,{limit:'1'}),Playlist.countDocuments({owner_id:user._id}),mongoose.connection.db.collection('hum_search_history').countDocuments({user_id:user._id})]);
  return {likedSongsCount:likes.pagination.total,followingArtistsCount:artists.pagination.total,playlistsCount:playlists,humMatchesCount:hum,humAvailable:false};
}
