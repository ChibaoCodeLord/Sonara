import { readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const seedsFile = new URL('./youtube-seeds.json', import.meta.url);
const destination = new URL('../src/data/youtubeCatalog.json', import.meta.url);
const normalize = text => text.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').toLowerCase();
const seeds = JSON.parse(await readFile(seedsFile, 'utf8'));
let previous = { tracks: [] };
try { previous = JSON.parse(await readFile(destination, 'utf8')); } catch { /* First import. */ }
const tracks = [], failures = [];
// Sequential, bounded requests. Only public oEmbed metadata is fetched; no audio/video files.
for (const seed of seeds) {
  if (!/^[\w-]{11}$/.test(seed.id) || !['VN', 'INTL'].includes(seed.region)) throw new Error('Invalid seed');
  const sourceUrl = `https://www.youtube.com/watch?v=${seed.id}`;
  try {
    const response = await fetch(`https://www.youtube.com/oembed?url=${encodeURIComponent(sourceUrl)}&format=json`, { signal: AbortSignal.timeout(20000) });
    if (!response.ok) throw Object.assign(new Error(`oEmbed HTTP ${response.status}`), { status: response.status });
    const data = await response.json();
    if (data.provider_name !== 'YouTube' || !data.title || !data.author_name || !normalize(data.author_name).includes(seed.channelMatch)) throw new Error(`Unexpected channel: ${data.author_name}`);
    const thumbnail = new URL(data.thumbnail_url);
    const channel = new URL(data.author_url);
    if (thumbnail.protocol !== 'https:' || !['i.ytimg.com', 'img.youtube.com'].includes(thumbnail.hostname) || channel.protocol !== 'https:' || !['youtube.com', 'www.youtube.com'].includes(channel.hostname)) throw new Error('Unexpected metadata URL');
    const existing = previous.tracks.find(track => track.youtubeId === seed.id);
    tracks.push({ ...(existing?.embedCheck ? { embedCheck: existing.embedCheck, durationSeconds: existing.durationSeconds } : {}), id: `yt_${seed.id}`, provider: 'youtube', youtubeId: seed.id, title: data.title, artist: seed.artist, channelTitle: data.author_name, channelUrl: data.author_url, region: seed.region, genre: seed.region === 'VN' ? 'Nhạc Việt' : 'Quốc tế', album: 'Video âm nhạc · YouTube', coverUrl: data.thumbnail_url, sourceUrl, durationSeconds: existing?.durationSeconds || null, isLossless: false, lyrics: [], fetchedAt: new Date().toISOString() });
    console.log(`OK ${seed.region} ${data.title}`);
  } catch (error) {
    failures.push({ id: seed.id, error: error.message });
    const existing = previous.tracks.find(track => track.youtubeId === seed.id);
    // Preserve verified metadata on transient refresh failures, never fabricate new tracks.
    if (existing && ![401, 403, 404].includes(error.status) && (error.status >= 500 || error.status === 429 || ['TypeError', 'TimeoutError', 'AbortError'].includes(error.name))) tracks.push(existing);
    console.error(`SKIP ${seed.id}: ${error.message}`);
  }
}
if (!tracks.some(track => track.region === 'VN') || !tracks.some(track => track.region === 'INTL')) throw new Error('No usable catalog for both regions. Existing file has not been changed.');
const result = { source: 'YouTube oEmbed', generatedAt: new Date().toISOString(), description: 'Editorial selection, not a chart. Video availability and embedding are checked at playback.', tracks, failures };
await writeFile(destination, JSON.stringify(result, null, 2) + '\n');
console.log(JSON.stringify({ file: fileURLToPath(destination), tracks: tracks.length, vietnam: tracks.filter(track => track.region === 'VN').length, international: tracks.filter(track => track.region === 'INTL').length, failures: failures.length }));
