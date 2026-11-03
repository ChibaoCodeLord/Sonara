import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { createReadStream } from 'node:fs';
import { stat, readFile } from 'node:fs/promises';
import { runCommand } from './mediaImport.service.js';

export const bulkAudioRoot = fileURLToPath(new URL('../../temp/youtube-bulk-library/',import.meta.url));
const bulkStateFile=fileURLToPath(new URL('../../../music_crawl/youtube_bulk/state.json',import.meta.url));
export async function bulkCrawlStatus(){
  try{
    const state=JSON.parse(await readFile(bulkStateFile,'utf8'));
    return {running:state.running===true&&Date.now()-Date.parse(state.updated_at)<15*60*1000,
      target:state.stats?.target||1000,totalAudio:state.stats?.active_audio||0,
      converted:state.candidates.filter(c=>c.status==='ready').length,
      failed:state.candidates.filter(c=>c.status==='failed').length,updatedAt:state.updated_at,stopReason:state.stop_reason||''};
  }catch(e){if(e.code==='ENOENT')return{running:false,totalAudio:0,target:1000};throw e;}
}
export const validVideoId = id => typeof id === 'string' && /^[\w-]{11}$/.test(id);
export function localAudioPath(jobId) {
  if (!/^[a-f\d-]{36}$/.test(jobId || '')) throw new Error('Mã tệp audio không hợp lệ.');
  return path.join(bulkAudioRoot,jobId,'audio.mp3');
}
export async function verifyMp3(file,{runner=runCommand}={}) {
  const fileStat=await stat(file);
  if(fileStat.size<1000 || fileStat.size>100*1024*1024)throw new Error('Invalid audio file size');
  const probe=JSON.parse(await runner(process.env.FFPROBE_PATH||'ffprobe',['-v','error','-show_entries','format=duration,size:stream=codec_type,codec_name','-of','json',file],{timeout:30000}));
  const duration=Number(probe.format?.duration);
  if(!probe.streams?.some(s=>s.codec_type==='audio'&&s.codec_name==='mp3') || !Number.isFinite(duration) || duration<30 || duration>1800)throw new Error('Invalid MP3 stream/duration');
  await runner(process.env.FFMPEG_PATH||'ffmpeg',['-nostdin','-v','error','-i',file,'-f','null','-'],{timeout:90000});
  const digest=createHash('sha256');
  for await(const chunk of createReadStream(file))digest.update(chunk);
  return {duration_seconds:duration,size_bytes:fileStat.size,sha256:digest.digest('hex'),full_decode_passed:true,verified_at:new Date().toISOString()};
}
export function candidateAllowed(video,{minDuration=60,maxDuration=720}={}) {
  return validVideoId(video?.id)&&Number.isFinite(video.duration)&&video.duration>=minDuration&&video.duration<=maxDuration&&
    !video.is_live&&!['is_live','is_upcoming'].includes(video.live_status)&&
    !/\b(karaoke|reaction|tutorial|review|nightcore|sped up|slowed|1 hour|compilation|nonstop)\b/i.test(video.title||'');
}
