import mongoose from 'mongoose';
import { ApiError } from './apiError.js';

export function text(value,field,{min=1,max=200}={}){
  if(typeof value!=='string')throw new ApiError(400,`${field} phải là chuỗi.`);
  const result=value.trim();if(result.length<min||result.length>max)throw new ApiError(400,`${field} phải dài ${min}–${max} ký tự.`);return result;
}
export const sanitizeText=value=>typeof value==='string'?value.replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])):value;
export function email(value){
  const normalized=text(value,'Email',{max:254}).toLowerCase();
  if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalized))throw new ApiError(400,'Email không hợp lệ.');return normalized;
}
export function password(value,field='Mật khẩu'){
  if(typeof value!=='string'||value.length<8||Buffer.byteLength(value,'utf8')>72)throw new ApiError(400,`${field} cần ít nhất 8 ký tự và tối đa 72 byte UTF-8.`);return value;
}
export function objectId(value,field='ID'){
  if(typeof value!=='string'||!/^[a-f\d]{24}$/i.test(value))throw new ApiError(400,`${field} không hợp lệ.`);return new mongoose.Types.ObjectId(value);
}
export function integer(value,field,{fallback,min=1,max=100}={}){
  if(value===undefined)return fallback;
  if(typeof value!=='string'&&typeof value!=='number'||!/^\d+$/.test(String(value)))throw new ApiError(400,`${field} phải là số nguyên.`);
  const number=Number(value);if(!Number.isSafeInteger(number)||number<min||number>max)throw new ApiError(400,`${field} phải trong khoảng ${min}–${max}.`);return number;
}
export const escapeRegex=value=>value.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');
export function pagination(query={},defaultLimit=20){return {page:integer(query.page,'page',{fallback:1,max:10000}),limit:integer(query.limit,'limit',{fallback:defaultLimit,max:100})};}
export function boolean(value,field){if(typeof value!=='boolean')throw new ApiError(400,`${field} phải là boolean.`);return value;}
export function choice(value,field,allowed){if(!allowed.includes(value))throw new ApiError(400,`${field} không hợp lệ.`);return value;}
export function idList(value,field='song_ids',max=200){if(!Array.isArray(value)||value.length>max)throw new ApiError(400,`${field} phải là mảng tối đa ${max} ID.`);const ids=value.map(id=>objectId(id,field));if(new Set(ids.map(String)).size!==ids.length)throw new ApiError(400,`${field} không được trùng ID.`);return ids;}
