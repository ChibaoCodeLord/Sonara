import jwt from 'jsonwebtoken';
import {createHash} from 'node:crypto';
import {ENV} from '../config/env.js';
import * as auth from './auth.service.js';
import {UserSession} from '../models/index.js';
import {ApiError} from '../utils/apiError.js';
const cookieName='sonara_admin_refresh';
const cookieOptions={httpOnly:true,sameSite:'strict',secure:ENV.NODE_ENV==='production',path:'/api/v1/admin/session'};
export function adminClient(req,_res,next){
  if(req.get('X-Sonara-Admin')!=='website')throw new ApiError(403,'Thiếu mã nhận diện khu vực quản trị.');
  let origin=req.get('origin');
  if(!origin&&req.get('referer')){
    try{origin=new URL(req.get('referer')).origin;}catch{}
  }
  const allowed=new Set([`${req.protocol}://${req.get('host')}`,...(process.env.ADMIN_ORIGINS||'http://localhost:5173,http://127.0.0.1:5173,http://localhost:4173,http://127.0.0.1:4173').split(',').map(v=>v.trim())]);
  if(!origin||!allowed.has(origin))throw new ApiError(403,'Nguồn truy cập quản trị không hợp lệ.');
  next();
}
function refreshCookie(req){try{const raw=(req.headers.cookie||'').split(';').map(v=>v.trim()).find(v=>v.startsWith(cookieName+'='));return raw?decodeURIComponent(raw.slice(cookieName.length+1)):'';}catch{return '';}}
function send(res,result){const {refresh_token,...data}=result;res.cookie(cookieName,refresh_token,{...cookieOptions,maxAge:ENV.REFRESH_TOKEN_DAYS*86400000});res.set('Cache-Control','no-store');return data;}
async function ensureAdmin(result,res){
  if(result.user.role!=='admin'||result.user.status!=='active'){const decoded=jwt.decode(result.token);await auth.logout(result.user.id,decoded.sid);res.clearCookie(cookieName,cookieOptions);throw new ApiError(403,'Tài khoản không có quyền quản trị.');}return result;
}
export async function loginAdmin(req,res){return send(res,await ensureAdmin(await auth.login(req.body),res));}
export async function refreshAdmin(req,res){
  const token=refreshCookie(req);if(!token)throw new ApiError(401,'Bạn chưa đăng nhập khu vực quản trị.');
  try{return send(res,await ensureAdmin(await auth.refresh({refresh_token:token}),res));}catch(e){res.clearCookie(cookieName,cookieOptions);throw e;}
}
export async function logoutAdmin(req,res){const value=refreshCookie(req);if(value)await UserSession.updateOne({refresh_token_hash:createHash('sha256').update(value).digest('hex'),revoked_at:null},{$set:{revoked_at:new Date()}});res.clearCookie(cookieName,cookieOptions);return null;}
