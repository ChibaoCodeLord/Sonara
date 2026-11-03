// Server-side public metadata only. Never send these credentials to the browser.
export class CatalogApiError extends Error {
  constructor(message, status = 0) { super(message); this.status = status; }
}

export class SpotifyClient {
  constructor({ clientId = process.env.SPOTIFY_CLIENT_ID, clientSecret = process.env.SPOTIFY_CLIENT_SECRET, fetcher = fetch, wait = ms => new Promise(resolve => setTimeout(resolve, ms)) } = {}) {
    this.clientId = clientId; this.clientSecret = clientSecret;
    this.fetcher = fetcher; this.wait = wait; this.token = null; this.expiresAt = 0;
  }
  async tokenForRequest() {
    if (this.token && Date.now() < this.expiresAt) return this.token;
    if (!this.clientId || !this.clientSecret) throw new CatalogApiError('Thiếu SPOTIFY_CLIENT_ID hoặc SPOTIFY_CLIENT_SECRET trong Backend/.env.');
    const response = await this.fetcher('https://accounts.spotify.com/api/token', {
      method: 'POST', signal: AbortSignal.timeout(20000),
      headers: { Authorization: `Basic ${Buffer.from(`${this.clientId}:${this.clientSecret}`).toString('base64')}`, 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'grant_type=client_credentials'
    });
    if (!response.ok) throw new CatalogApiError('Spotify không chấp nhận thông tin ứng dụng. Kiểm tra Client ID/Client Secret.', response.status);
    const data = await response.json();
    if (!data.access_token) throw new CatalogApiError('Spotify không trả về access token.');
    this.token = data.access_token; this.expiresAt = Date.now() + Math.max(0, (data.expires_in - 60) * 1000);
    return this.token;
  }
  async request(endpoint, params = {}) {
    const url = new URL(`https://api.spotify.com/v1/${endpoint}`);
    for (const [key, value] of Object.entries(params)) url.searchParams.set(key, value);
    for (let attempt = 0; attempt < 3; attempt++) {
      const token = await this.tokenForRequest();
      const response = await this.fetcher(url, { headers: { Authorization: `Bearer ${token}` }, signal: AbortSignal.timeout(20000) });
      // Spotify can return plain text for 403; do not blindly parse JSON or log credentials.
      const body = await response.text();
      if (response.status === 401 && attempt < 2) { this.token = null; continue; }
      if (response.status === 429 && attempt < 2) {
        const seconds = Number(response.headers.get('retry-after') || 1);
        if (!Number.isFinite(seconds) || seconds > 30) throw new CatalogApiError('Spotify giới hạn tần suất. Chạy lại sau thời gian Retry-After.', 429);
        await this.wait(Math.max(1, seconds) * 1000); continue;
      }
      if (!response.ok) {
        const premium = response.status === 403 && /premium/i.test(body);
        throw new CatalogApiError(premium ? 'Spotify yêu cầu tài khoản chủ ứng dụng có Premium đang hoạt động. Sau khi bật Premium có thể cần chờ vài giờ.' : `Spotify API trả HTTP ${response.status}. Kiểm tra quyền ứng dụng và endpoint.`, response.status);
      }
      try { return JSON.parse(body); } catch { throw new CatalogApiError('Spotify trả dữ liệu không phải JSON.', response.status); }
    }
    throw new CatalogApiError('Không thể hoàn thành yêu cầu Spotify.');
  }
  async search(query, { market = 'VN', limit = 5, offset = 0 } = {}) {
    if (!query?.trim()) throw new CatalogApiError('Từ khóa Spotify không được rỗng.');
    const data = await this.request('search', { q: query, type: 'track', market, limit: Math.min(10, Math.max(1, limit)), offset });
    if (!Array.isArray(data.tracks?.items)) throw new CatalogApiError('Spotify không trả danh sách tracks hợp lệ.');
    return data.tracks;
  }
}

export function normalizeSpotifyTrack(track, { region = 'INTL', fetchedAt = new Date() } = {}) {
  if (!/^[a-zA-Z0-9]{22}$/.test(track?.id || '') || !track.name || !track.artists?.length || !/^[a-zA-Z0-9]{22}$/.test(track.album?.id || '')) throw new Error('Bản ghi Spotify thiếu ID, tên, nghệ sĩ hoặc album.');
  if (track.artists.some(artist => !/^[a-zA-Z0-9]{22}$/.test(artist.id || '') || !artist.name)) throw new Error('Nghệ sĩ Spotify không hợp lệ.');
  const https = value => { try { return new URL(value).protocol === 'https:' ? value : ''; } catch { return ''; } };
  return {
    spotify_id: track.id, spotify_url: `https://open.spotify.com/track/${track.id}`,
    title: track.name, duration_ms: Number.isFinite(track.duration_ms) ? track.duration_ms : 0,
    explicit: Boolean(track.explicit), isrc: track.external_ids?.isrc || '',
    // Fields removed by Development Mode remain absent in source metadata, not invented.
    spotify_metadata: {
      artists: track.artists.map(artist => ({ spotify_id: artist.id, name: artist.name, url: `https://open.spotify.com/artist/${artist.id}` })),
      album: { spotify_id: track.album.id, title: track.album.name, album_type: track.album.album_type, release_date: track.album.release_date, release_date_precision: track.album.release_date_precision, total_tracks: track.album.total_tracks, cover_url: https(track.album.images?.[0]?.url), url: `https://open.spotify.com/album/${track.album.id}` },
      disc_number: track.disc_number || 1, track_number: track.track_number || 1,
      ...(Number.isFinite(track.popularity) ? { popularity: track.popularity } : {}),
      region, fetched_at: fetchedAt
    },
    cover_url: https(track.album.images?.[0]?.url), genre: '', status: 'active',
    catalog_source: 'spotify', imported_at: fetchedAt
  };
}
