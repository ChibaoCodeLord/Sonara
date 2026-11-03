import multer from 'multer';
import {randomUUID} from 'node:crypto';
import fs from 'node:fs';
import {ApiError} from '../utils/apiError.js';
import {uploadRoot} from '../services/audioStream.service.js';
import {cleanupUploads} from '../services/adminUpload.service.js';
fs.mkdirSync(uploadRoot,{recursive:true});
const extensions={audio:{'audio/mpeg':'.mp3','audio/mp3':'.mp3','audio/wav':'.wav','audio/x-wav':'.wav','audio/mp4':'.m4a','audio/x-m4a':'.m4a','audio/aac':'.aac','audio/flac':'.flac','audio/x-flac':'.flac','audio/ogg':'.ogg'},cover:{'image/jpeg':'.jpg','image/png':'.png','image/webp':'.webp'}};
export const upload=multer({
  storage:multer.diskStorage({destination:(_req,_file,cb)=>cb(null,uploadRoot),filename:(_req,file,cb)=>cb(null,file.fieldname+'-'+randomUUID()+extensions[file.fieldname][file.mimetype])}),
  limits:{fileSize:100*1024*1024,files:2,fields:20,fieldSize:65536},
  fileFilter:(_req,file,cb)=>extensions[file.fieldname]?.[file.mimetype]?cb(null,true):cb(new ApiError(400,'Định dạng file không phù hợp với trường audio/cover.'))
});
const receiver=upload.fields([{name:'audio',maxCount:1},{name:'cover',maxCount:1}]);
export const receiveTrackUpload=(req,res,next)=>receiver(req,res,error=>{if(error)cleanupUploads(req.files).then(()=>next(error),next);else next();});
const coverReceiver=multer({storage:upload.storage,limits:{fileSize:10*1024*1024,files:1,fields:20,fieldSize:65536},fileFilter:(_req,file,cb)=>extensions.cover[file.mimetype]?cb(null,true):cb(new ApiError(400,'Ảnh bìa phải là JPEG, PNG hoặc WebP.'))}).single('cover');
export const receivePlaylistCover=(req,res,next)=>coverReceiver(req,res,error=>{
  const fail=e=>cleanupUploads({cover:req.file?[req.file]:[]}).then(()=>next(e),next);
  if(error)return fail(error);
  try{if(req.is('multipart/form-data')){for(const key of ['is_public','collaborative'])if(['true','false'].includes(req.body[key]))req.body[key]=req.body[key]==='true';if(typeof req.body.collaborator_ids==='string')req.body.collaborator_ids=JSON.parse(req.body.collaborator_ids);}next();}catch{return fail(new ApiError(400,'Metadata multipart không hợp lệ.'));}
});
