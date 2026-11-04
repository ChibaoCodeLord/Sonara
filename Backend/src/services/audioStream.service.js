import path from 'node:path';
import fs from 'node:fs';
import {pipeline} from 'node:stream/promises';
import {fileURLToPath} from 'node:url';
import {ApiError} from '../utils/apiError.js';
import {localAudioPath} from './youtubeBulk.service.js';

export const uploadRoot=fileURLToPath(new URL('../../uploads/',import.meta.url));
export const catalogAudioRoot=fileURLToPath(new URL('../../temp/catalog-audio-library/',import.meta.url));
export const safeFileName=name=>typeof name==='string'&&/^[a-z\d][a-z\d._-]*$/i.test(name)&&!name.includes('..');
export function containedFile(root,name){
  if(!safeFileName(name))throw new ApiError(404,'Không tìm thấy file âm thanh.');
  const resolvedRoot=path.resolve(root);
  const candidate=path.resolve(root,name);
  if(!candidate.startsWith(resolvedRoot+path.sep))throw new ApiError(404,'Không tìm thấy file âm thanh.');
  return candidate;
}
export function parseRange(header,size){
  if(!header||!header.startsWith('bytes=')||header.includes(','))return null;
  const match=/^bytes=(\d*)-(\d*)$/.exec(header);if(!match||(!match[1]&&!match[2])||size===0)return false;
  const first=match[1]?Number(match[1]):null,last=match[2]?Number(match[2]):null;
  if([first,last].some(n=>n!==null&&(!Number.isSafeInteger(n)||n<0)))return false;
  if(first===null)return last>0?{start:Math.max(0,size-last),end:size-1}:false;
  if(first>=size||last!==null&&last<first)return false;
  return {start:first,end:last===null?size-1:Math.min(last,size-1)};
}
export async function streamAudioFile(filePath,rangeHeader,res){
  let file;try{file=await fs.promises.stat(filePath);}catch{throw new ApiError(404,'File âm thanh không tồn tại.');}
  if(!file.isFile())throw new ApiError(404,'File âm thanh không tồn tại.');
  const range=parseRange(rangeHeader,file.size);
  const type={'.mp3':'audio/mpeg','.flac':'audio/flac','.wav':'audio/wav','.m4a':'audio/mp4','.aac':'audio/aac','.ogg':'audio/ogg'}[path.extname(filePath).toLowerCase()]||'application/octet-stream';
  if(range===false){res.writeHead(416,{'Content-Range':`bytes */${file.size}`,'Content-Length':0});res.end();return;}
  const headers={'Content-Type':type,'Accept-Ranges':'bytes','Content-Length':range?range.end-range.start+1:file.size};
  if(range)headers['Content-Range']=`bytes ${range.start}-${range.end}/${file.size}`;
  res.writeHead(range?206:200,headers);
  if(res.req?.method==='HEAD'){res.end();return;}
  try{await pipeline(fs.createReadStream(filePath,range||{}),res);}catch(error){if(!['ERR_STREAM_PREMATURE_CLOSE','ECONNRESET'].includes(error.code))throw error;}
}
export function resolveTrackAudio(track){
  const url=track.audio_url||track.preview_url;
  if(!url)throw new ApiError(404,'Bài hát chưa có audio.');
  if(/^https?:\/\//i.test(url)){
    const parsed=new URL(url);if(parsed.username||parsed.password)throw new ApiError(404,'URL audio không hợp lệ.');return {url:parsed.href};
  }
  const bulk=/^\/api\/v1\/catalog\/local-audio\/([\w-]{11})$/.exec(url);
  if(bulk){if(track.audio_cache?.storage!=='youtube-bulk'||track.source_key!==`youtube:${bulk[1]}`)throw new ApiError(404,'Audio bulk chưa được xác minh.');return {file:localAudioPath(track.audio_cache.job_id)};}
  const job=/^\/api\/v1\/catalog\/audio\/jobs\/([a-f\d-]{36})\/stream$/.exec(url);
  if(job){if(track.audio_cache?.job_id!==job[1]||track.audio_cache?.source_url!==track.youtube?.url)throw new ApiError(404,'Audio không khớp nguồn bài hát.');return {file:path.join(catalogAudioRoot,job[1],'audio.mp3')};}
  const upload=/^\/?uploads\/([^/]+)$/.exec(url);
  if(upload)return {file:containedFile(uploadRoot,upload[1])};
  throw new ApiError(404,'Loại storage audio chưa được hỗ trợ.');
}
