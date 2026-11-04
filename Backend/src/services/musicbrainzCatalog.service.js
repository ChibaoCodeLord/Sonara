export const validMbid = id => /^[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}$/i.test(id || '');
export class MusicBrainzError extends Error {
  constructor(message, status = 0) { super(message); this.name = 'MusicBrainzError'; this.status = status; }
}

export class MusicBrainzClient {
  constructor({ userAgent = process.env.MUSICBRAINZ_USER_AGENT || 'Sonara/1.0 (http://localhost:5173)', fetcher = fetch, wait = ms => new Promise(resolve => setTimeout(resolve, ms)), now = Date.now, interval = 1100 } = {}) {
    if (!/^\S+\/\S+\s+\(.+\)$/.test(userAgent) || /[\r\n]/.test(userAgent)) throw new MusicBrainzError('MUSICBRAINZ_USER_AGENT cần tên ứng dụng/phiên bản và địa chỉ liên hệ trong ngoặc.');
    this.userAgent = userAgent; this.fetcher = fetcher; this.wait = wait; this.now = now;
    this.interval = Math.max(1100, interval); this.nextAt = 0; this.tail = Promise.resolve();
  }
  request(resource, params = {}) {
    // Serialize even concurrent callers, including retries: at most one request / 1.1 seconds.
    const task = this.tail.then(() => this.perform(resource, params));
    this.tail = task.catch(() => {}); return task;
  }
  async perform(resource, params) {
    if (!/^(artist|recording)(\/[a-f\d-]{36})?$/.test(resource)) throw new MusicBrainzError('MusicBrainz resource không hợp lệ.');
    const url = new URL(`https://musicbrainz.org/ws/2/${resource}`);
    for (const [key, value] of Object.entries({ ...params, fmt: 'json' })) url.searchParams.set(key, value);
    for (let attempt = 0; attempt < 3; attempt++) {
      const delay = this.nextAt - this.now(); if (delay > 0) await this.wait(delay);
      this.nextAt = this.now() + this.interval;
      const response = await this.fetcher(url, { headers: { 'User-Agent': this.userAgent, Accept: 'application/json' }, signal: AbortSignal.timeout(25000) });
      if ([429, 503].includes(response.status) && attempt < 2) {
        const retry = response.headers.get('retry-after');
        const seconds = retry === null ? 2 ** (attempt + 1) : /^\d+$/.test(retry) ? Number(retry) : (Date.parse(retry) - this.now()) / 1000;
        if (!Number.isFinite(seconds) || seconds > 60) throw new MusicBrainzError('MusicBrainz yêu cầu chờ lâu. Chạy lại sau Retry-After.', response.status);
        this.nextAt = Math.max(this.nextAt, this.now() + Math.max(1, seconds) * 1000); continue;
      }
      if (!response.ok) throw new MusicBrainzError(`MusicBrainz HTTP ${response.status}.`, response.status);
      return response.json();
    }
    throw new MusicBrainzError('Không hoàn thành yêu cầu MusicBrainz.');
  }
  async recordings(artistId, { limit = 10, offset = 0 } = {}) {
    if (!validMbid(artistId)) throw new MusicBrainzError('Artist MBID không hợp lệ.');
    const result = await this.request('recording', { query: `arid:${artistId}`, limit: Math.min(100, Math.max(1, limit)), offset });
    if (!Array.isArray(result.recordings)) throw new MusicBrainzError('MusicBrainz không trả danh sách recordings.');
    return result;
  }
}

export function normalizeMusicBrainzRecording(recording, { region = 'INTL', fetchedAt = new Date() } = {}) {
  const artists = (recording?.['artist-credit'] || []).filter(credit => validMbid(credit.artist?.id)).map(credit => ({ musicbrainz_id: credit.artist.id, name: credit.name || credit.artist.name, url: `https://musicbrainz.org/artist/${credit.artist.id}`, joinphrase: credit.joinphrase || '' }));
  if (!validMbid(recording?.id) || !recording.title || !artists.length) throw new MusicBrainzError('Recording thiếu MBID, tên bài hoặc artist credit.');
  const releases = (recording.releases || []).filter(release => validMbid(release.id));
  const release = releases.find(item => item.status === 'Official') || releases[0];
  const medium = release?.media?.find(item => item.track?.length) || release?.media?.[0];
  const releaseTrack = medium?.track?.[0];
  const date = release?.date || recording['first-release-date'] || '';
  return {
    musicbrainz_id: recording.id, musicbrainz_url: `https://musicbrainz.org/recording/${recording.id}`,
    title: recording.title, duration_ms: Number.isFinite(recording.length) && recording.length > 0 ? recording.length : 0,
    isrc: recording.isrcs?.[0] || '', catalog_source: 'musicbrainz', imported_at: fetchedAt,
    musicbrainz_metadata: {
      artists, region, fetched_at: fetchedAt, disambiguation: recording.disambiguation || '',
      first_release_date: recording['first-release-date'] || '',
      ...(release ? { album: {
        musicbrainz_id: release.id, url: `https://musicbrainz.org/release/${release.id}`, title: release.title,
        album_type: release['release-group']?.['primary-type']?.toLowerCase() || '',
        release_group_id: release['release-group']?.id || '', release_date: date,
        release_date_precision: /^\d{4}-\d{2}-\d{2}$/.test(date) ? 'day' : /^\d{4}-\d{2}$/.test(date) ? 'month' : /^\d{4}$/.test(date) ? 'year' : '',
        total_tracks: release['track-count'] || medium?.['track-count'] || 0
      } } : {}),
      disc_number: medium?.position || 1,
      // Search responses have offset/track number only when explicitly returned.
      track_number: /^\d+$/.test(releaseTrack?.number || '') ? Number(releaseTrack.number) : Number.isInteger(medium?.['track-offset']) ? medium['track-offset'] + 1 : null
    }
  };
}
