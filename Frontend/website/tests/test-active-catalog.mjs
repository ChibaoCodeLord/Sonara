import test from 'node:test';
import assert from 'node:assert/strict';
import { fetchActiveCatalog } from '../src/utils/remoteCatalog.js';
import { deriveCatalogEntities, playableTrack } from '../src/utils/catalogEntities.js';
import { usePlayerStore } from '../src/store/usePlayerStore.js';
import { useAppStore } from '../src/store/useAppStore.js';

const full = { id:'catalog_test', title:'Actual catalog track', playbackKind:'full', provider:'archive', audioUrl:'https://example.test/audio.mp3',
  artists:[{id:'artist_archive_a',name:'A'}], albumInfo:{id:'album_archive_r',title:'Release',release_date:'2020'}, metadataSource:'archive' };
test('active catalog pages are complete and preserve audio/preview/metadata distinctions', async () => {
  let count = 0;
  const result = await fetchActiveCatalog(async () => Response.json({data:{dataset:'new',tracks:[{...full,id:`catalog_${++count}`}],pagination:{totalPages:2}}}));
  assert.equal(result.tracks.length,2); assert.equal(result.dataset,'new');
  const entities = deriveCatalogEntities(result.tracks);
  assert.equal(entities.artists.length,1); assert.equal(entities.albums.length,1); assert.equal(entities.albums[0].songIds.length,2);
  assert.equal(playableTrack({...full,audioUrl:'',previewUrl:'https://example.test/preview.mp3',provider:'metadata'}),false);
});
test('API failures, duplicate IDs and changes between pages fail without local fallback', async () => {
  await assert.rejects(fetchActiveCatalog(async () => new Response('',{status:503})));
  await assert.rejects(fetchActiveCatalog(async () => Response.json({data:{dataset:'new',tracks:[full,full],pagination:{totalPages:1}}})), /trùng ID/);
  let page = 0;
  await assert.rejects(fetchActiveCatalog(async () => Response.json({data:{dataset:String(++page),tracks:[{...full,id:String(page)}],pagination:{totalPages:2}}})), /thay đổi/);
});
test('snapshot token is reused for all pages while the importer adds songs',async()=>{
  const urls=[];
  const result=await fetchActiveCatalog(async u=>{urls.push(u);return Response.json({data:{dataset:'frozen',snapshot:'token',tracks:[{...full,id:String(urls.length)}],pagination:{totalPages:2}}});});
  assert.equal(result.tracks.length,2);assert.match(urls[1],/snapshot=token/);
});
test('album-only contributors remain discoverable without being invented as track performers', () => {
  const entities = deriveCatalogEntities([{...full,albumInfo:{...full.albumInfo,artists:[{id:'guest',name:'Album credit'}]}}]);
  const guest = entities.artists.find(a=>a.name==='Album credit');
  assert(guest); assert.deepEqual(guest.topTrackIds,[]); assert.deepEqual(guest.albumIds,[full.albumInfo.id]);
});
test('new installs have no seeded library, queue or default playing song', () => {
  assert.equal(usePlayerStore.getState().currentSong,null);
  assert.deepEqual(usePlayerStore.getState().queue,[]);
  assert.deepEqual(usePlayerStore.getState().likedSongIds,[]);
  assert.deepEqual(useAppStore.getState().playlists,[]);
});
test('metadata-only records never start playback or enter the playable queue', () => {
  const initial = usePlayerStore.getState();
  try {
    const state = () => usePlayerStore.getState();
    const metadata = {...full,id:'metadata',provider:'metadata',audioUrl:'',playbackKind:'metadata'};
    state().playSong(metadata); assert.equal(state().isPlaying,false); assert.equal(state().currentSong,null);
    state().setQueue([metadata,full]); assert.equal(state().queue.length,1); assert.equal(state().currentSong.id,full.id);
  } finally { usePlayerStore.setState(initial,true); }
});
