import { runCommand } from './mediaImport.service.js';

export const normalizeMusicText = text => String(text || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
const tokens = text => new Set(normalizeMusicText(text).split(' ').filter(Boolean));
const coverage = (needle, haystack) => { const words = tokens(needle); const target = tokens(haystack); return words.size ? [...words].filter(word => target.has(word)).length / words.size : 0; };
const versions = ['remix', 'cover', 'karaoke', 'live', 'tour', 'concert', 'instrumental', 'sped up', 'speed up', 'slowed', 'nightcore', '8d', 'dance performance', 'first pressing', 'extended', 'taylor s version', 'taylors version', 'melody', 'remaster', 'remastered'];
const hasPhrase = (text, phrase) => ` ${text} `.includes(` ${phrase} `);

export function scoreYouTubeCandidate(track, candidate) {
  const title = normalizeMusicText(candidate.title);
  const expected = normalizeMusicText(`${track.title} ${track.musicbrainz_metadata?.disambiguation || ''}`);
  const titleScore = coverage(track.title, candidate.title);
  const artists = track.musicbrainz_metadata?.artists || track.spotify_metadata?.artists || [];
  const artistScore = coverage(artists[0]?.name, `${candidate.title} ${candidate.channel_title}`);
  const duration = track.duration_ms / 1000;
  const delta = duration && candidate.duration_seconds ? Math.abs(duration - candidate.duration_seconds) : null;
  const durationScore = delta === null ? 0 : Math.max(0, 1 - delta / Math.max(20, duration * 0.15));
  const mismatch = versions.some(version => hasPhrase(title, version) && !hasPhrase(expected, version)) || (/\b\d+\s*(hz|hertz)\b/.test(title) && !/\b\d+\s*(hz|hertz)\b/.test(expected)) || (hasPhrase(expected, 'clean') && !hasPhrase(title, 'clean'));
  const score = Math.max(0, Math.min(1, 0.55 * titleScore + 0.3 * artistScore + 0.15 * durationScore - (mismatch ? 0.4 : 0)));
  const accepted = titleScore >= 0.85 && artistScore >= 0.65 && delta !== null && delta <= Math.max(15, duration * 0.08) && !mismatch && score >= 0.85;
  return { ...candidate, match_score: Number(score.toFixed(4)), title_score: titleScore, artist_score: artistScore, duration_delta: delta, version_mismatch: mismatch, accepted };
}

function durationSeconds(value) {
  const match = /^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$/.exec(value || '');
  return match ? Number(match[1] || 0) * 3600 + Number(match[2] || 0) * 60 + Number(match[3] || 0) : 0;
}

export class YouTubeMatcher {
  constructor({ apiKey = process.env.YOUTUBE_API_KEY, ytdlp = process.env.YTDLP_PATH || 'yt-dlp', runner = runCommand, fetcher = fetch } = {}) {
    this.apiKey = apiKey; this.ytdlp = ytdlp; this.runner = runner; this.fetcher = fetcher;
  }
  async api(resource, params) {
    const url = new URL(`https://www.googleapis.com/youtube/v3/${resource}`);
    for (const [key, value] of Object.entries({ ...params, key: this.apiKey })) url.searchParams.set(key, value);
    const response = await this.fetcher(url, { signal: AbortSignal.timeout(20000) });
    if (!response.ok) throw new Error(`YouTube Data API HTTP ${response.status}; kiểm tra key hoặc quota.`);
    return response.json();
  }
  async candidates(track) {
    const artists = track.musicbrainz_metadata?.artists || track.spotify_metadata?.artists || [];
    const query = `${track.title} ${artists.map(artist => artist.name).join(' ')} ${track.musicbrainz_metadata?.disambiguation || ''} official audio`;
    if (this.apiKey) {
      const search = await this.api('search', { part: 'snippet', q: query, type: 'video', videoEmbeddable: 'true', videoSyndicated: 'true', maxResults: '5' });
      const ids = search.items?.map(item => item.id?.videoId).filter(id => /^[\w-]{11}$/.test(id || '')) || [];
      if (!ids.length) return [];
      const videos = await this.api('videos', { part: 'snippet,contentDetails,status', id: ids.join(',') });
      return (videos.items || []).filter(video => video.status?.embeddable && video.status.privacyStatus === 'public' && video.snippet?.liveBroadcastContent === 'none').map(video => ({
        video_id: video.id, title: video.snippet.title, channel_title: video.snippet.channelTitle,
        duration_seconds: durationSeconds(video.contentDetails?.duration), embeddable: true, search_provider: 'youtube-data-api'
      }));
    }
    // Public metadata search; no account cookies, audio download, or temporary stream URL.
    const output = await this.runner(this.ytdlp, ['--ignore-config', '--no-plugin-dirs', '--no-cache-dir', '--skip-download', '--flat-playlist', '--dump-single-json', '--socket-timeout', '12', '--retries', '1', '--extractor-retries', '1', `ytsearch5:${query}`], { timeout: 60000 });
    const result = JSON.parse(output);
    return (result.entries || []).filter(video => /^[\w-]{11}$/.test(video.id || '') && !video.is_live).map(video => ({
      video_id: video.id, title: video.title || '', channel_title: video.channel || video.uploader || '',
      duration_seconds: Number(video.duration) || 0, embeddable: null, search_provider: 'yt-dlp-public-metadata'
    }));
  }
  async checkEmbed(candidate) {
    if (candidate.embeddable === true) return true;
    const url = new URL('https://www.youtube.com/oembed');
    url.searchParams.set('url', `https://www.youtube.com/watch?v=${candidate.video_id}`); url.searchParams.set('format', 'json');
    const response = await this.fetcher(url, { signal: AbortSignal.timeout(15000) });
    if ([401, 403, 404].includes(response.status)) return false;
    if (!response.ok) throw new Error(`YouTube oEmbed HTTP ${response.status}.`);
    const data = await response.json();
    return data.provider_name === 'YouTube' && Boolean(data.html);
  }
  async match(track) {
    const candidates = (await this.candidates(track)).map(candidate => scoreYouTubeCandidate(track, candidate)).sort((a, b) => b.match_score - a.match_score);
    for (const candidate of candidates.filter(item => item.accepted)) {
      if (await this.checkEmbed(candidate)) return {
        status: 'matched', video_id: candidate.video_id, url: `https://www.youtube.com/watch?v=${candidate.video_id}`,
        embed_url: `https://www.youtube.com/embed/${candidate.video_id}`, title: candidate.title, channel_title: candidate.channel_title,
        duration_seconds: candidate.duration_seconds, match_score: candidate.match_score, search_provider: candidate.search_provider,
        // oEmbed is a preflight, not proof of playback in every browser or country.
        embed_check: candidate.embeddable === true ? 'data-api' : 'oembed', checked_at: new Date(), candidates
      };
    }
    return { status: candidates.length ? 'review' : 'unmatched', checked_at: new Date(), candidates };
  }
}
