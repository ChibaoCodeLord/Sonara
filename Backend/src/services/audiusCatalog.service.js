import { normalizeMusicText } from './youtubeMatch.service.js';
export class AudiusClient {
  constructor({ fetcher = fetch, wait = ms => new Promise(resolve => setTimeout(resolve, ms)) } = {}) { this.fetcher = fetcher; this.wait = wait; this.nextAt = 0; }
  async page({ kind = 'trending', time = 'week', query = '', offset = 0, limit = 100 } = {}) {
    const url = new URL(`https://api.audius.co/v1/tracks/${kind === 'search' ? 'search' : 'trending'}`);
    for (const [key, value] of Object.entries({ app_name: 'Sonara', limit, offset, ...(kind === 'search' ? { query, sort_method: 'relevant' } : { time }) })) url.searchParams.set(key, value);
    for (let attempt = 0; attempt < 3; attempt++) {
      if (this.nextAt > Date.now()) await this.wait(this.nextAt - Date.now());
      this.nextAt = Date.now() + 1100;
      const response = await this.fetcher(url, { signal: AbortSignal.timeout(25000), headers: { Accept: 'application/json' } });
      if (response.status === 429 && attempt < 2) { const delay = Number(response.headers.get('retry-after') || 3); if (!Number.isFinite(delay) || delay > 60) throw new Error('Audius rate limit; chạy lại sau Retry-After.'); await this.wait(Math.max(1, delay) * 1000); continue; }
      if (response.status >= 500 && attempt < 2) { await this.wait(2000 * (attempt + 1)); continue; }
      const data = await response.json();
      if (response.status === 400 && offset > 0 && /offset/i.test(data.error || '')) return { tracks: [], apiLimit: true };
      if (response.status === 400 && /time is invalid/i.test(data.error || '')) return { tracks: [], apiLimit: false, unsupported: true };
      if (!response.ok || !Array.isArray(data.data)) throw new Error(`Audius HTTP ${response.status}.`);
      return { tracks: data.data, apiLimit: false };
    }
    throw new Error('Audius tạm giới hạn truy cập.');
  }
}

export function normalizeAudiusTrack(track, { region = 'INTL', fetchedAt = new Date() } = {}) {
  if (!/^[a-zA-Z0-9_-]+$/.test(track?.id || '') || !track.title || !track.user?.id) throw new Error('Thiếu Audius ID, tên hoặc người đăng.');
  if (track.is_streamable !== true || track.is_stream_gated || track.access?.stream === false || track.is_unlisted || track.is_delete) return null;
  const cover = track.artwork?.['480x480'] || track.artwork?.['150x150'] || '';
  let coverUrl = ''; try { if (new URL(cover).protocol === 'https:') coverUrl = cover; } catch { /* fallback artwork */ }
  const path = String(track.permalink || '').startsWith('/') ? track.permalink : '';
  return {
    audius_id: track.id, catalog_source: 'audius', title: track.title,
    duration_ms: Math.max(0, Number(track.duration) || 0) * 1000, genre: track.genre || '', cover_url: coverUrl,
    audio_url: `https://api.audius.co/v1/tracks/${track.id}/stream?app_name=Sonara`,
    audius_metadata: { artist_id: track.user.id, artist: track.user.name || track.user.handle || 'Audius', handle: track.user.handle || '',
      url: path ? `https://audius.co${path}` : `https://audius.co/tracks/${track.id}`, region, fetched_at: fetchedAt,
      is_streamable: true, is_stream_gated: false, download_allowed: Boolean(track.is_downloadable),
      uploader_verified: Boolean(track.user.is_verified), release_date: track.release_date || track.created_at || '', tags: track.tags || '' },
    imported_at: fetchedAt
  };
}

export function queryMatchesTrack(track, query) {
  const text = normalizeMusicText(`${track.title} ${track.user?.name || ''} ${track.user?.handle || ''}`);
  const words = normalizeMusicText(query).split(' ').filter(Boolean);
  return words.length > 0 && words.every(word => text.split(' ').includes(word));
}
