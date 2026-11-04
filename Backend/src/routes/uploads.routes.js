import {Router} from 'express';
import path from 'node:path';
import {Track} from '../models/track.model.js';
import {publicTracks} from '../services/catalogPolicy.service.js';
import {uploadRoot,containedFile,streamAudioFile} from '../services/audioStream.service.js';
import {asyncHandler} from '../utils/asyncHandler.js';
import {ApiError} from '../utils/apiError.js';
const router=Router();
router.get('/:name',asyncHandler(async(req,res)=>{
  const file=containedFile(uploadRoot,req.params.name),ext=path.extname(file).toLowerCase();
  if(['.jpg','.png','.webp'].includes(ext))return res.sendFile(file,error=>{if(error&&!res.headersSent)res.status(404).end();});
  if(!['.mp3','.wav','.m4a','.aac','.flac','.ogg'].includes(ext))throw new ApiError(404,'Không tìm thấy file.');
  if(!await Track.exists({...await publicTracks(),audio_url:'/uploads/'+req.params.name}))throw new ApiError(404,'Không tìm thấy audio công khai.');
  await streamAudioFile(file,req.headers.range,res);
}));
export default router;
