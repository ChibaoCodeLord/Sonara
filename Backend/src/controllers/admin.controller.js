import {asyncHandler} from '../utils/asyncHandler.js';
import {ApiResponse} from '../utils/apiResponse.js';
import {createUploadedTrack,cleanupUploads} from '../services/adminUpload.service.js';
import {enrichTrackDetails,toLegacySong} from '../services/track.service.js';
export const createTrack=asyncHandler(async(req,res)=>{
  let track;try{track=await createUploadedTrack(req.body,req.files,req.user._id);}catch(error){await cleanupUploads(req.files);throw error;}
  const dto=await enrichTrackDetails(track);
  res.status(201).json(new ApiResponse(201,req.baseUrl==='/api/v1/songs'?toLegacySong(dto):dto,'Đã tải bài hát lên.'));
});
