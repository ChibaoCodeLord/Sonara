import mongoose from 'mongoose';
import {ApiError} from '../utils/apiError.js';
import {LikedTrack} from '../models/likedTrack.model.js';
import {getAllTracks,getTrackById,getPublicTrack,toLegacySong} from './track.service.js';
export {streamAudioFile as streamSongAudio} from './audioStream.service.js';
export async function getAllSongs(query){const {tracks,...rest}=await getAllTracks(query);return {songs:tracks.map(toLegacySong),...rest};}
export const getSongById=async id=>toLegacySong(await getTrackById(id));
export async function toggleLike(userId,id){
  const track=await getPublicTrack(id),session=await mongoose.startSession();let result;
  try{for(let attempt=0;attempt<3;attempt++){try{await session.withTransaction(async()=>{
    const filter={user_id:userId,track_id:track._id};
    const previous=await LikedTrack.findOne(filter).session(session);
    if(previous)await LikedTrack.deleteOne({_id:previous._id},{session});else await LikedTrack.create([filter],{session});
    result={liked:!previous,likesCount:await LikedTrack.countDocuments({track_id:track._id}).session(session)};
  });return result;}catch(error){if(error.code!==11000)throw error;}}
  throw new ApiError(409,'Trạng thái thích vừa thay đổi. Hãy thử lại.');
  }finally{await session.endSession();}
}
export async function setLiked(userId,id,liked){
  const track=await getPublicTrack(id),filter={user_id:userId,track_id:track._id};
  if(liked){try{await LikedTrack.updateOne(filter,{$setOnInsert:filter},{upsert:true});}catch(e){if(e.code!==11000)throw e;}}
  else await LikedTrack.deleteOne(filter);
  return {liked,likesCount:await LikedTrack.countDocuments({track_id:track._id})};
}
