import test from 'node:test';
import assert from 'node:assert/strict';
import { mergeCatalog, uniqueYouTubeTracks, fetchMusicBrainzCatalog, fetchArchiveCatalog } from '../src/utils/remoteCatalog.js';
import { forAudioPlayback } from '../src/utils/audioCatalog.js';

const song = { id: 'musicbrainz_test', provider: 'youtube', youtubeId: 'gJHSDZfJrRY', title: 'Test metadata' };
test('YouTube catalog becomes audio preparation; cached MP3 keeps original ID and metadata', () => {
  const pending = forAudioPlayback({ ...song, embedCheck: { status: 'blocked' } });
  assert.equal(pending.provider, 'youtube-audio'); assert.equal(pending.embedCheck, undefined);
  const ready = forAudioPlayback(pending, { audioUrl: '/file.mp3', durationSeconds: 200 });
  assert.equal(ready.provider, 'audio'); assert.equal(ready.id, song.id); assert.equal(ready.durationSeconds, 200);
});

test('Archive pages retain all licensed audio and reject records without attribution', async () => {
  let calls = 0;
  const source = { id: 'archive_1', provider: 'archive', title: 'Open music', audioUrl: 'https://archive.org/download/rb001/song.mp3', licenseUrl: 'https://creativecommons.org/licenses/by-nc-nd/3.0/' };
  const tracks = await fetchArchiveCatalog(async () => Response.json({ data: { tracks: [{ ...source, id: `archive_${++calls}` }], pagination: { totalPages: 2 } } }));
  assert.equal(tracks.length, 2); assert.equal(uniqueYouTubeTracks(tracks).length, 2);
  await assert.rejects(fetchArchiveCatalog(async () => Response.json({ data: { tracks: [{ ...source, licenseUrl: '' }], pagination: { totalPages: 1 } } })));
});
test('saved local IDs remain resolvable while discovery cards deduplicate the same YouTube video', () => {
  const local = { ...song, id: 'yt_gJHSDZfJrRY' };
  const catalog = mergeCatalog([song], [local, song]);
  assert.equal(catalog.length, 2); assert(catalog.some(track => track.id === local.id));
  assert.equal(uniqueYouTubeTracks(catalog).length, 1); assert.equal(uniqueYouTubeTracks(catalog)[0].id, song.id);
});
test('catalog loads all pages and rejects malformed or failed responses', async () => {
  const urls = [];
  const result = await fetchMusicBrainzCatalog(async url => { urls.push(url); return Response.json({ data: { tracks: [{ ...song, id: `track_${urls.length}` }], pagination: { totalPages: 2 } } }); });
  assert.equal(result.length, 2); assert.match(urls[1], /page=2/);
  await assert.rejects(fetchMusicBrainzCatalog(async () => new Response('', { status: 503 })));
  await assert.rejects(fetchMusicBrainzCatalog(async () => Response.json({ data: { tracks: [{ ...song, youtubeId: 'bad' }], pagination: { totalPages: 1 } } })));
});
