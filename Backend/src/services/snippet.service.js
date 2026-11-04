import path from 'node:path';
import {mkdir,stat,rename,unlink} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {createHash,randomUUID} from 'node:crypto';
import {ApiError} from '../utils/apiError.js';
import {getPublicTrack} from './track.service.js';
import {resolveTrackAudio,streamAudioFile} from './audioStream.service.js';
import {runCommand} from './mediaImport.service.js';
export const snippetCacheRoot=fileURLToPath(new URL('../../temp/snippets/',import.meta.url));
export const snippetKey=(track,info)=>createHash('sha256').update([String(track._id),track.audio_url,info.size,info.mtimeMs].join(':')).digest('hex');
const root=snippetCacheRoot,pending=new Map();
export async function snippet(id,range,res){
  const track=await getPublicTrack(id);let preview;
  try{if(track.preview_url){const url=new URL(track.preview_url);if(['http:','https:'].includes(url.protocol)&&!url.username&&!url.password)preview=url.href;}}catch{/* Invalid source previews are never redirected. */}
  if(preview)return res.redirect(302,preview);
  const media=resolveTrackAudio(track);if(!media.file)throw new ApiError(404,'Nguồn nhạc chưa cung cấp bản nghe thử.');
  let info;try{info=await stat(media.file);}catch{throw new ApiError(404,'Không tìm thấy audio.');}
  const key=snippetKey(track,info),file=path.join(root,key+'.mp3');
  if(!await stat(file).then(s=>s.size>0).catch(()=>false)){
    if(!pending.has(key)){
      if(pending.size>=2)throw new ApiError(429,'Đang tạo bản nghe thử, hãy thử lại sau.');
      const task=(async()=>{await mkdir(root,{recursive:true});const temp=path.join(root,key+'-'+randomUUID()+'.mp3');try{await runCommand(process.env.FFMPEG_PATH||'ffmpeg',['-nostdin','-v','error','-protocol_whitelist','file,pipe,crypto','-ss',String(track.duration_ms>=105000?75:0),'-i',media.file,'-t','30','-vn','-codec:a','libmp3lame','-b:a','128k',temp],{timeout:30000});await rename(temp,file);}catch(e){await unlink(temp).catch(()=>{});throw new ApiError(e.code==='ENOENT'?503:502,'Không tạo được bản nghe thử.');}})().finally(()=>pending.delete(key));pending.set(key,task);
    }await pending.get(key);
  }
  await streamAudioFile(file,range,res);
}
