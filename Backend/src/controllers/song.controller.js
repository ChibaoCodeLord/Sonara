import * as service from '../services/song.service.js';
import {ApiResponse} from '../utils/apiResponse.js';
import {asyncHandler} from '../utils/asyncHandler.js';
export {streamTrack as streamSong} from './track.controller.js';
export {createTrack as createSong} from './admin.controller.js';
export const getSongs=asyncHandler(async(req,res)=>res.json(new ApiResponse(200,await service.getAllSongs(req.query),'Lấy danh sách bài hát thành công.')));
export const getSongById=asyncHandler(async(req,res)=>res.json(new ApiResponse(200,await service.getSongById(req.params.id),'Lấy chi tiết bài hát thành công.')));
export const toggleLike=asyncHandler(async(req,res)=>res.json(new ApiResponse(200,await service.toggleLike(req.user._id,req.params.id),'Đã cập nhật yêu thích.')));
export const setLiked=liked=>asyncHandler(async(req,res)=>res.json(new ApiResponse(200,await service.setLiked(req.user._id,req.params.id,liked),'Đã cập nhật yêu thích.')));
