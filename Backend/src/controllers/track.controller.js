import * as service from '../services/track.service.js';
import {resolveTrackAudio,streamAudioFile} from '../services/audioStream.service.js';
import {ApiResponse} from '../utils/apiResponse.js';
import {asyncHandler} from '../utils/asyncHandler.js';
export const getTracks=asyncHandler(async(req,res)=>res.json(new ApiResponse(200,await service.getAllTracks(req.query),'Lấy danh sách bài hát thành công.')));
export const getTrackById=asyncHandler(async(req,res)=>res.json(new ApiResponse(200,await service.getTrackById(req.params.id),'Lấy chi tiết bài hát thành công.')));
export const streamTrack=asyncHandler(async(req,res)=>{
  const target=resolveTrackAudio(await service.getPublicTrack(req.params.id));
  if(target.url)return res.redirect(target.url);
  await streamAudioFile(target.file,req.headers.range,res);
});
