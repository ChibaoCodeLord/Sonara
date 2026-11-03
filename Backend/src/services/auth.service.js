import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import {randomBytes,randomUUID,createHash} from 'node:crypto';
import {User,UserSession,LikedTrack,Track} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
import {ENV} from '../config/env.js';
import {email as parseEmail,password as parsePassword,text,sanitizeText} from '../utils/validation.js';
import {publicTracks} from './catalogPolicy.service.js';
const digest=value=>createHash('sha256').update(value).digest('hex');
export const userDTO=user=>({id:String(user._id),name:user.display_name||user.name,email:user.email,role:user.role||'user',status:user.status||'active',avatar:user.avatar_url||'',avatar_url:user.avatar_url||'',country:user.country||'VN'});
const assertActive=user=>{if(user.status&&user.status.toLowerCase()!=='active')throw new ApiError(403,'Tài khoản đã bị khóa hoặc tạm ngưng.');};
function deviceFields(body){return Object.fromEntries(['device_id','device_name'].map(key=>[key,body[key]===undefined?'':text(body[key],key,{min:0,max:150})]));}
async function issueSession(user,device,session,family=randomUUID()){
  const refresh=randomBytes(32).toString('hex'),id=new mongoose.Types.ObjectId();
  await UserSession.create([{_id:id,user_id:user._id,refresh_token_hash:digest(refresh),family_id:family,expires_at:new Date(Date.now()+ENV.REFRESH_TOKEN_DAYS*86400000),...device}],{session});
  const token=jwt.sign({id:String(user._id),sid:String(id),version:user.token_version||0},ENV.JWT_SECRET,{algorithm:'HS256',expiresIn:ENV.JWT_EXPIRES_IN});
  const decoded=jwt.decode(token);return {user:userDTO(user),token,refresh_token:refresh,expires_in:decoded.exp-decoded.iat,token_type:'Bearer'};
}
async function transact(work){const session=await mongoose.startSession();let result;try{await session.withTransaction(async()=>{result=await work(session);});return result;}finally{await session.endSession();}}
export async function register(body={}){
  const name=sanitizeText(text(body.name??body.display_name,'Tên hiển thị',{max:50})),email=parseEmail(body.email),password=parsePassword(body.password),device=deviceFields(body);
  return transact(async session=>{
    if(await User.exists({email}).session(session))throw new ApiError(400,'Địa chỉ email này đã được sử dụng.');
    const user=new User({display_name:name,email,password_hash:password});await user.save({session});
    return issueSession(user,device,session);
  });
}
export async function login(body={}){
  const email=parseEmail(body.email);
  if(typeof body.password!=='string'||!body.password||Buffer.byteLength(body.password,'utf8')>72)throw new ApiError(400,'Mật khẩu không hợp lệ.');
  const user=await User.findOne({email}).select('+password_hash +token_version');
  if(!user||!await user.comparePassword(body.password))throw new ApiError(401,'Email hoặc mật khẩu không chính xác.');
  assertActive(user);return transact(session=>issueSession(user,deviceFields(body),session));
}
export async function getProfile(userId){
  const user=await User.findById(userId).lean();if(!user)throw new ApiError(404,'Không tìm thấy người dùng.');assertActive(user);
  const likes=await LikedTrack.find({user_id:userId}).select('track_id').lean();
  const tracks=likes.length?await Track.find({...await publicTracks(),_id:{$in:likes.map(r=>r.track_id)}}).select('_id').lean():[];
  return {...userDTO(user),favoriteSongs:tracks.map(t=>String(t._id)),likedTrackIds:tracks.map(t=>String(t._id))};
}
export async function refresh(body={}){
  const token=text(body.refresh_token,'refresh_token',{min:64,max:64});if(!/^[a-f0-9]{64}$/.test(token))throw new ApiError(401,'Refresh token không hợp lệ.');
  const old=await UserSession.findOne({refresh_token_hash:digest(token)});
  if(!old||old.expires_at<=new Date())throw new ApiError(401,'Refresh token không hợp lệ hoặc đã hết hạn.');
  if(old.revoked_at){await UserSession.updateMany({user_id:old.user_id,family_id:old.family_id,revoked_at:null},{$set:{revoked_at:new Date()}});throw new ApiError(401,'Phiên đã bị thu hồi. Hãy đăng nhập lại.');}
  const user=await User.findById(old.user_id).select('+token_version');if(!user)throw new ApiError(401,'Tài khoản không còn tồn tại.');assertActive(user);
  const rotated=await transact(async session=>{
    const claimed=await UserSession.findOneAndUpdate({_id:old._id,revoked_at:null,expires_at:{$gt:new Date()}},{$set:{revoked_at:new Date()}},{new:true,session});
    if(!claimed)return null;
    return issueSession(user,{device_id:old.device_id,device_name:old.device_name},session,old.family_id);
  });
  if(!rotated){await UserSession.updateMany({user_id:old.user_id,family_id:old.family_id,revoked_at:null},{$set:{revoked_at:new Date()}});throw new ApiError(401,'Refresh token đã được sử dụng. Hãy đăng nhập lại.');}
  return rotated;
}
export async function logout(userId,sessionId){await UserSession.updateOne({_id:sessionId,user_id:userId,revoked_at:null},{$set:{revoked_at:new Date()}});}
export async function updateProfile(userId,body={}){
  const update={};
  if(body.name!==undefined||body.display_name!==undefined)update.display_name=sanitizeText(text(body.name??body.display_name,'Tên hiển thị',{max:50}));
  if(body.country!==undefined){const country=text(body.country,'country',{min:2,max:2}).toUpperCase();if(!/^[A-Z]{2}$/.test(country))throw new ApiError(400,'country không hợp lệ.');update.country=country;}
  if(!Object.keys(update).length)throw new ApiError(400,'Chưa có trường hồ sơ hợp lệ để cập nhật.');
  const user=await User.findByIdAndUpdate(userId,{$set:update},{new:true,runValidators:true});if(!user)throw new ApiError(404,'Không tìm thấy người dùng.');return userDTO(user);
}
export async function changePassword(userId,body={}){
  const next=parsePassword(body.new_password,'Mật khẩu mới');
  if(typeof body.current_password!=='string'||!body.current_password||Buffer.byteLength(body.current_password,'utf8')>72)throw new ApiError(400,'Mật khẩu hiện tại không hợp lệ.');
  return transact(async session=>{
    const user=await User.findById(userId).select('+password_hash +token_version').session(session);
    if(!user||!await user.comparePassword(body.current_password))throw new ApiError(400,'Mật khẩu hiện tại không chính xác.');
    if(await user.comparePassword(next))throw new ApiError(400,'Mật khẩu mới phải khác mật khẩu hiện tại.');
    user.password_hash=next;user.token_version=(user.token_version||0)+1;await user.save({session});
    await UserSession.updateMany({user_id:userId,revoked_at:null},{$set:{revoked_at:new Date()}},{session});
  });
}
