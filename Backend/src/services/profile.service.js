import mongoose from 'mongoose';
import {ListeningHistory,Playlist,UserSettings} from '../models/index.js';
import {text,choice,integer,boolean} from '../utils/validation.js';
import {ApiError} from '../utils/apiError.js';
const defaults={is_spatial_audio:false,is_vocal_separation:false,sensitivity_level:2,streaming_quality:'STANDARD',theme_mode:'system',equalizer_profile:'Flat'};
const dto=row=>({isSpatialAudio:row.is_spatial_audio,isVocalSeparation:row.is_vocal_separation,sensitivityLevel:row.sensitivity_level,streamingQuality:row.streaming_quality,themeMode:row.theme_mode,equalizerProfile:row.equalizer_profile,capabilities:{spatial_processing:false,vocal_separation:false},...Object.fromEntries(Object.keys(defaults).map(k=>[k,row[k]]))});
export async function stats(user){
  const [totals,playlists,hum]=await Promise.all([ListeningHistory.aggregate([{$match:{user_id:user._id}},{$group:{_id:null,ms:{$sum:'$listened_ms'},completed:{$sum:{$cond:['$completed',1,0]}}}}]),Playlist.countDocuments({owner_id:user._id}),mongoose.connection.db.collection('hum_search_history').countDocuments({user_id:user._id})]);
  return {listeningHours:(totals[0]?.ms||0)/3600000,completedListens:totals[0]?.completed||0,playlistsCount:playlists,humMatchesCount:hum};
}
export async function getSettings(user){const row=await UserSettings.findOne({user_id:user._id}).lean();return dto({...defaults,...row});}
export async function updateSettings(user,body){
  const update={};for(const key of ['is_spatial_audio','is_vocal_separation'])if(body[key]!==undefined)update[key]=boolean(body[key],key);
  if(body.sensitivity_level!==undefined)update.sensitivity_level=integer(body.sensitivity_level,'sensitivity_level',{min:1,max:3});
  if(body.streaming_quality!==undefined)update.streaming_quality=choice(body.streaming_quality,'streaming_quality',['STANDARD','HIGH','LOSSLESS','HI_RES_FLAC_24BIT']);
  if(body.theme_mode!==undefined)update.theme_mode=choice(body.theme_mode,'theme_mode',['light','dark','system']);
  if(body.equalizer_profile!==undefined)update.equalizer_profile=text(body.equalizer_profile,'equalizer_profile',{max:80});
  if(!Object.keys(update).length)throw new ApiError(400,'Không có cài đặt hợp lệ.');
  try{await UserSettings.updateOne({user_id:user._id},{$set:update},{upsert:true,runValidators:true});}catch(e){if(e.code!==11000)throw e;await UserSettings.updateOne({user_id:user._id},{$set:update},{runValidators:true});}return getSettings(user);
}
