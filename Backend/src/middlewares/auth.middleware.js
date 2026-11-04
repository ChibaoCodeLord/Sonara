import jwt from 'jsonwebtoken';
import {ENV} from '../config/env.js';
import {ApiError} from '../utils/apiError.js';
import {asyncHandler} from '../utils/asyncHandler.js';
import {User,UserSession} from '../models/index.js';
export const protect=asyncHandler(async(req,_res,next)=>{
  const match=/^Bearer ([^\s]+)$/.exec(req.headers.authorization||'');
  if(!match)throw new ApiError(401,'Bạn chưa đăng nhập. Vui lòng cung cấp token hợp lệ.');
  const decoded=jwt.verify(match[1],ENV.JWT_SECRET,{algorithms:['HS256']});
  if(decoded.kind&&decoded.kind!=='access')throw new ApiError(401,'Token không dùng được cho API này.');
  if(!decoded.id||!decoded.sid||![decoded.id,decoded.sid].every(id=>typeof id==='string'&&/^[a-f\d]{24}$/i.test(id)))throw new ApiError(401,'Phiên không hợp lệ. Hãy đăng nhập lại.');
  const [user,session]=await Promise.all([User.findById(decoded.id).select('+token_version'),UserSession.findOne({_id:decoded.sid,user_id:decoded.id,revoked_at:null,expires_at:{$gt:new Date()}})]);
  if(!user||!session||(user.token_version||0)!==decoded.version)throw new ApiError(401,'Phiên đã hết hạn hoặc bị thu hồi.');
  if(user.status&&user.status.toLowerCase()!=='active')throw new ApiError(403,'Tài khoản đã bị khóa hoặc tạm ngưng.');
  req.user=user;req.auth={sessionId:session._id};next();
});
export const restrictTo=(...roles)=>(req,_res,next)=>{
  if(!req.user)throw new ApiError(401,'Bạn chưa đăng nhập.');
  if(!roles.includes(req.user.role||'user'))throw new ApiError(403,'Bạn không có quyền thực hiện hành động này.');next();
};
export const optionalAuth=(req,res,next)=>req.headers.authorization?protect(req,res,next):next();
