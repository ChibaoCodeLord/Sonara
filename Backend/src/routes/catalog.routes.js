import { Router } from 'express';
import { Track } from '../models/track.model.js';
import { toWebsiteTrack } from '../services/catalogRepository.service.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import audioRoutes from './catalogAudio.routes.js';
import mongoose from 'mongoose';
import { validArchiveIdentifier } from '../services/archiveCatalog.service.js';
import { localAudioPath, validVideoId, bulkCrawlStatus } from '../services/youtubeBulk.service.js';
import { randomUUID } from 'node:crypto';
import {activeCatalogSetting,publicTrackFilter,publicTracks} from '../services/catalogPolicy.service.js';
import {streamAudioFile} from '../services/audioStream.service.js';
import {pagination,text} from '../utils/validation.js';

const router = Router();
const snapshots=new Map();
const pendingSnapshots=new Map();
const snapshotLifetime=120000;
const websiteFields='source_key catalog_source catalog_dataset title duration_ms genre cover_url audio_url preview_url synced_lyrics catalog_metadata.artists catalog_metadata.album catalog_metadata.source_url catalog_metadata.region catalog_metadata.license_url catalog_metadata.license_label catalog_metadata.download_allowed catalog_metadata.content_kind catalog_metadata.fetched_at catalog_metadata.source_metadata.collection catalog_metadata.source_metadata.format catalog_metadata.source_metadata.file_name';
async function buildSnapshot(source){
  const setting=await activeCatalogSetting();
  const filter={...publicTrackFilter(setting),...(source?{catalog_source:source}:{})};
  const found=await Track.find(filter).select(websiteFields).sort({title:1,_id:1}).limit(10001).maxTimeMS(15000).lean();
  const docs=[...new Map(found.map(t=>[String(t._id),t])).values()];
  if(docs.length>10000)throw Object.assign(new Error('Catalog vượt giới hạn tải hiện tại.'),{statusCode:503});
  const token=randomUUID();
  const snapshot={token,source,created:Date.now(),revision:setting?.revision||0,dataset:setting?.dataset||'local',importedAt:setting?.imported_at,tracks:docs.map(toWebsiteTrack)};
  if(snapshots.size>=8)snapshots.delete(snapshots.keys().next().value);
  snapshots.set(token,snapshot);return snapshot;
}
router.use('/audio', audioRoutes);
router.get('/crawl-status',asyncHandler(async(_req,res)=>{res.set('Cache-Control','no-store');res.json({data:await bulkCrawlStatus()});}));
router.get('/local-audio/:videoId', asyncHandler(async(req,res)=>{
  if(!validVideoId(req.params.videoId))return res.status(400).json({message:'Video ID không hợp lệ.'});
  const track=await Track.findOne({...await publicTracks(),source_key:`youtube:${req.params.videoId}`,'audio_cache.storage':'youtube-bulk'}).lean();
  if(!track?.audio_cache?.job_id)return res.status(404).json({message:'Không có audio đã xác minh.'});
  await streamAudioFile(localAudioPath(track.audio_cache.job_id),req.headers.range,res);
}));
// One active crawl snapshot; old catalog never leaks through a fallback source.
router.get('/', asyncHandler(async (req, res) => {
  const {page,limit}=pagination(req.query,100);
  const source = req.query.source===undefined?'':text(req.query.source,'source',{min:0,max:40});
  if (source && !/^[a-z]+$/.test(source)) return res.status(400).json({ message: 'Nguồn không hợp lệ.' });
  const currentSetting=await activeCatalogSetting(),currentDataset=currentSetting?.dataset||'local',revision=currentSetting?.revision||0;
  for(const [key,value]of snapshots)if(Date.now()-value.created>snapshotLifetime||value.dataset!==currentDataset||value.revision!==revision)snapshots.delete(key);
  let token=req.query.snapshot;
  let snapshot=token?snapshots.get(token):null;
  if(token&&(!snapshot||snapshot.source!==source))return res.status(409).json({code:'CATALOG_CHANGED',message:'Catalog vừa cập nhật. Hãy tải lại.'});
  if(!snapshot){
    snapshot=[...snapshots.values()].reverse().find(s=>s.source===source&&Date.now()-s.created<10000);
    if(!snapshot){
      if(!pendingSnapshots.has(source))pendingSnapshots.set(source,buildSnapshot(source).finally(()=>pendingSnapshots.delete(source)));
      snapshot=await pendingSnapshots.get(source);
    }
    token=snapshot.token;
  }
  const total=snapshot.tracks.length;
  const tracks=snapshot.tracks.slice((page-1)*limit,page*limit);
  // A cached page must not expose a track hidden after the snapshot was built.
  const visible=await Track.countDocuments({...await publicTracks(),_id:{$in:tracks.map(t=>t.databaseId)}});
  if(visible!==tracks.length){snapshots.delete(token);return res.status(409).json({code:'CATALOG_CHANGED',message:'Catalog vừa cập nhật. Hãy tải lại.'});}
  res.set('Cache-Control', 'no-store');
  res.json({ data: { dataset: `${snapshot.dataset}:${token}`, snapshot:token, importedAt: snapshot.importedAt, tracks,
    pagination: { total, page, limit, totalPages: Math.ceil(total / limit) } } });
}));
// Read-only public catalog. Imports and provider credentials are CLI/server-side only.
const getCatalog = source => asyncHandler(async (req, res) => {
  const {page,limit}=pagination(req.query,50);
  const filter = {...await publicTracks(),catalog_source:source};
  if (source === 'archive' && req.query.collection) {
    if (!validArchiveIdentifier(req.query.collection)) return res.status(400).json({ message: 'Collection ID không hợp lệ.' });
    filter['archive_metadata.collection'] = req.query.collection;
  }
  if (req.query.matched === 'true' || req.query.playable === 'true') filter['youtube.status'] = 'matched';
  if (req.query.playable === 'true') filter['youtube.playback_status'] = { $ne: 'blocked' };
  if (['VN', 'INTL'].includes(req.query.region)) filter[`${source}_metadata.region`] = req.query.region;
  const [tracks, total] = await Promise.all([
    Track.find(filter).sort({ imported_at: -1, _id: 1 }).skip((page - 1) * limit).limit(limit).lean(),
    Track.countDocuments(filter)
  ]);
  res.json({ data: { tracks: tracks.map(toWebsiteTrack), pagination: { total, page, limit, totalPages: Math.ceil(total / limit) } } });
});
router.get('/spotify', getCatalog('spotify'));
router.get('/musicbrainz', getCatalog('musicbrainz'));
router.get('/audius', getCatalog('audius'));
router.get('/archive', getCatalog('archive'));
router.get('/archive/status', asyncHandler(async (req, res) => {
  const collection = req.query.collection || 'restingbell';
  if (!validArchiveIdentifier(collection)) return res.status(400).json({ message: 'Collection ID không hợp lệ.' });
  const report = await mongoose.connection.db.collection('catalog_imports').findOne({ source: 'archive', collection }, { projection: { _id: 0, complete: 1, collection: 1, reconciliation: 1, finishedAt: 1 } });
  res.json({ data: report || { collection, complete: false } });
}));
export default router;
