import jwt from 'jsonwebtoken';
import {ENV} from '../config/env.js';
import {User,UserSession,Track} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {objectId} from '../utils/validation.js';
import {resolveTrackAudio,streamAudioFile} from './audioStream.service.js';
export async function previewSession(user,sessionId,id){
  const track=await Track.findById(objectId(id,'Track ID')).lean();if(!track)throw new ApiError(404,'Không tìm thấy bài hát.');resolveTrackAudio(track);
  const token=jwt.sign({kind:'admin-media',id:String(user._id),sid:String(sessionId),version:user.token_version||0,track:String(track._id),revision:track.revision||0},ENV.JWT_SECRET,{algorithm:'HS256',audience:'sonara-admin-media',issuer:'sonara',expiresIn:'10m'});
  return {url:'/api/v1/admin/media/'+token,expires_at:new Date(Date.now()+600000)};
}
export async function streamPreview(req,res){
  let claims;try{claims=jwt.verify(req.params.token,ENV.JWT_SECRET,{algorithms:['HS256'],audience:'sonara-admin-media',issuer:'sonara'});}catch{throw new ApiError(401,'Phiên nghe thử đã hết hạn. Hãy mở lại player.');}
  if(claims.kind!=='admin-media')throw new ApiError(401,'Token nghe thử không hợp lệ.');
  const [user,session,track]=await Promise.all([User.findById(objectId(claims.id)).select('+token_version'),UserSession.findOne({_id:objectId(claims.sid),user_id:claims.id,revoked_at:null,expires_at:{$gt:new Date()}}),Track.findById(objectId(claims.track)).lean()]);
  if(!user||!session||user.role!=='admin'||user.status!=='active'||(user.token_version||0)!==claims.version)throw new ApiError(401,'Quyền nghe thử đã bị thu hồi.');
  if(!track)throw new ApiError(404,'Không tìm thấy bài hát.');if((track.revision||0)!==claims.revision)throw new ApiError(409,'Audio/metadata đã thay đổi. Hãy mở lại player.');
  res.set({'Cache-Control':'no-store','Referrer-Policy':'no-referrer'});const audio=resolveTrackAudio(track);if(audio.url)return res.redirect(302,audio.url);await streamAudioFile(audio.file,req.headers.range,res);
}
