import {Router} from 'express';
import {catalogAudio} from '../services/catalogAudio.service.js';
import {Track} from '../models/track.model.js';
import {publicTracks} from '../services/catalogPolicy.service.js';
import {toWebsiteTrack} from '../services/catalogRepository.service.js';
import {streamAudioFile} from '../services/audioStream.service.js';
import {validVideoId} from '../services/youtubeBulk.service.js';
import {asyncHandler} from '../utils/asyncHandler.js';
const router=Router();
router.post('/',asyncHandler(async(req,res)=>{
  const local=['127.0.0.1','::1','::ffff:127.0.0.1'].includes(req.socket.remoteAddress);
  if(!local||req.get('X-Sonara-Client')!=='website')return res.status(403).json({error:'Chuyển đổi audio chỉ mở trên máy chủ cục bộ.'});
  if(!validVideoId(req.body.youtubeId))return res.status(400).json({error:'YouTube ID không hợp lệ.'});
  const url='https://www.youtube.com/watch?v='+req.body.youtubeId;
  const track=await Track.findOne({...await publicTracks({fullAudioOnly:false}),'youtube.url':url}).lean();
  if(!track)return res.status(404).json({error:'Không tìm thấy bài hát trong catalog công khai.'});
  if(track.audio_url)return res.json({id:track.audio_cache?.job_id||req.body.youtubeId,status:'ready',progress:100,track:toWebsiteTrack(track)});
  try{res.status(202).json(await catalogAudio.prepare(req.body.youtubeId));}catch(e){res.status(e.status||503).json({error:e.message});}
}));
router.get('/jobs/:id',asyncHandler(async(req,res)=>{
  const job=await catalogAudio.get(req.params.id);
  if(!job)return res.status(404).json({error:'Không tìm thấy tác vụ audio.'});
  const track=await Track.exists({...await publicTracks({fullAudioOnly:false}),'youtube.url':job.url});
  return track?res.json(job):res.status(404).json({error:'Không tìm thấy tác vụ audio.'});
}));
router.get('/jobs/:id/stream',asyncHandler(async(req,res)=>{
  const job=await catalogAudio.get(req.params.id);
  if(job?.status!=='ready')return res.status(404).json({error:'Audio chưa sẵn sàng.'});
  const track=await Track.exists({...await publicTracks({fullAudioOnly:false}),'youtube.url':job.url});
  if(!track)return res.status(404).json({error:'Không tìm thấy audio công khai.'});
  await streamAudioFile(catalogAudio.service.audioPath(job.id),req.headers.range,res);
}));
export default router;
