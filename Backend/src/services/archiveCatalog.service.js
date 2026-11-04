import { createHash } from 'node:crypto';
export const validArchiveIdentifier = value => typeof value === 'string' && /^[a-zA-Z0-9][a-zA-Z0-9._-]{0,199}$/.test(value);
export const archiveHash = value => createHash('sha256').update(value).digest('hex');
const array = value => Array.isArray(value) ? value : value == null ? [] : [value];
const text = value => array(value).map(String).join(', ').trim();
const truthy = value => [true, 1, '1', 'true', 'yes'].includes(value);

export class ArchiveClient {
  constructor({ fetcher = fetch, wait = ms => new Promise(resolve => setTimeout(resolve, ms)), userAgent = process.env.ARCHIVE_USER_AGENT || 'SonaraCatalog/1.0 (Codex GPT-6; http://localhost:5173)' } = {}) {
    this.fetcher = fetcher; this.wait = wait; this.userAgent = userAgent; this.nextAt = 0;
  }
  async request(path, params = {}) {
    const url = new URL(path, 'https://archive.org');
    if (url.origin !== 'https://archive.org') throw new Error('Archive endpoint ngoài nguồn cho phép.');
    for (const [key, values] of Object.entries(params)) for (const value of array(values)) url.searchParams.append(key, value);
    for (let attempt = 0; attempt < 4; attempt++) {
      if (this.nextAt > Date.now()) await this.wait(this.nextAt - Date.now());
      this.nextAt = Date.now() + 1200;
      let response;
      try { response = await this.fetcher(url, { headers: { 'User-Agent': this.userAgent, Accept: 'application/json' }, signal: AbortSignal.timeout(30000) }); }
      catch { if (attempt < 3) { await this.wait(2000 * (attempt + 1)); continue; } throw new Error('Archive network timeout.'); }
      if ([429, 502, 503, 504].includes(response.status) && attempt < 3) {
        const header = response.headers.get('retry-after');
        const seconds = header === null ? 2 * (attempt + 1) : /^\d+$/.test(header) ? Number(header) : (Date.parse(header) - Date.now()) / 1000;
        if (!Number.isFinite(seconds) || seconds > 120) throw new Error('Archive yêu cầu chờ Retry-After; chạy lại sau.');
        await this.wait(Math.max(1, seconds) * 1000); continue;
      }
      if (!response.ok) throw new Error(`Archive HTTP ${response.status}.`);
      return response.json();
    }
    throw new Error('Archive chưa hoàn thành yêu cầu.');
  }
  async enumerate(collection) {
    if (!validArchiveIdentifier(collection)) throw new Error('Collection ID không hợp lệ.');
    const ids = new Set(); let expected;
    for (let page = 1; ; page++) {
      const result = await this.request('/advancedsearch.php', { q: `collection:${collection} AND mediatype:audio`, output: 'json', 'fl[]': ['identifier'], 'sort[]': ['identifier asc'], rows: 1000, page });
      const response = result.response;
      if (!Number.isInteger(response?.numFound) || !Array.isArray(response.docs)) throw new Error('Archive search response không hợp lệ.');
      if (expected === undefined) expected = response.numFound;
      if (expected !== response.numFound) throw new Error('Danh mục thay đổi khi phân trang; cần lấy lại snapshot.');
      const previousSize = ids.size;
      for (const item of response.docs) { if (!validArchiveIdentifier(item.identifier)) throw new Error('Archive item ID không hợp lệ.'); ids.add(item.identifier); }
      if (ids.size >= expected) break;
      if (ids.size === previousSize) throw new Error('Archive không tiến thêm khi phân trang; chưa đủ mục.');
      if (!response.docs.length) throw new Error('Archive kết thúc sớm, chưa đủ số mục nguồn báo cáo.');
    }
    if (ids.size !== expected) throw new Error('Số unique item khác tổng nguồn báo cáo.');
    return { collection, expected, ids: [...ids].sort(), capturedAt: new Date().toISOString() };
  }
  async metadata(id) { if (!validArchiveIdentifier(id)) throw new Error('Archive item ID không hợp lệ.'); return this.request(`/metadata/${id}`, { extended_err: 1 }); }
}

export function archiveLicense(value) {
  for (const candidate of array(value)) {
    try {
      const url = new URL(candidate);
      if (!['creativecommons.org', 'www.creativecommons.org'].includes(url.hostname) || !['http:', 'https:'].includes(url.protocol)) continue;
      const match = /^\/(licenses\/(by|by-sa|by-nc|by-nc-sa|by-nd|by-nc-nd)\/(1\.0|2\.0|2\.5|3\.0|4\.0)|publicdomain\/(zero|mark)\/1\.0)(?:\/|$)/.exec(url.pathname);
      if (match) return { url: `https://creativecommons.org/${match[1]}/`, label: match[2] ? `CC ${match[2].toUpperCase()} ${match[3]}` : match[4] === 'zero' ? 'CC0 1.0' : 'Public Domain Mark 1.0' };
    } catch { /* Keep unsupported/unverified licensing out of the audio catalog. */ }
  }
  return null;
}
export function archiveFileUrl(id, name) {
  if (!validArchiveIdentifier(id) || typeof name !== 'string' || !name || name.includes('\\') || name.includes('\0') || name.split('/').some(segment => !segment || ['.', '..'].includes(segment))) throw new Error('Archive file path không hợp lệ.');
  return `https://archive.org/download/${encodeURIComponent(id)}/${name.split('/').map(encodeURIComponent).join('/')}`;
}
function seconds(value) {
  const parts = String(value || '').split(':').map(Number);
  if (parts.some(part => !Number.isFinite(part) || part < 0) || parts.length > 3) return 0;
  return parts.reduce((sum, part) => sum * 60 + part, 0);
}
const priority = name => ({ mp3: 0, ogg: 1, m4a: 2, flac: 3, wav: 4 })[name.split('.').at(-1)?.toLowerCase()] ?? 99;

export function normalizeArchiveItem(item, { id, collection, fetchedAt = new Date() }) {
  const metadata = item.metadata;
  if (item.error || !metadata || metadata.identifier !== id) throw new Error('Archive metadata không có đúng item yêu cầu.');
  if (!array(metadata.collection).includes(collection) || metadata.mediatype !== 'audio') throw new Error('Archive item nằm ngoài danh mục audio đã chọn.');
  const audit = { id, title: text(metadata.title), collection, itemUrl: `https://archive.org/details/${id}`, fetchedAt, tracks: 0, variants: 0, reason: null };
  if (truthy(item.is_dark) || truthy(metadata.access_restricted)) return { audit: { ...audit, reason: 'restricted' }, tracks: [] };
  const license = archiveLicense(metadata.licenseurl);
  if (!license) return { audit: { ...audit, reason: 'missing_or_unsupported_license' }, tracks: [] };
  const files = array(item.files); const byName = new Map(files.map(file => [file.name, file])); const groups = new Map();
  for (const file of files) {
    if (typeof file.name !== 'string' || priority(file.name) === 99 || truthy(file.private)) continue;
    if (file.size !== undefined && !(Number(file.size) > 0)) continue;
    archiveFileUrl(id, file.name); audit.variants++;
    let root = file.name, current = file; const seen = new Set([root]);
    while (current.original && !seen.has(current.original)) { root = current.original; seen.add(root); current = byName.get(root) || {}; }
    const previous = groups.get(root);
    if (!previous || priority(file.name) < priority(previous.name)) groups.set(root, file);
  }
  const tracks = [...groups].map(([canonical, file]) => {
    const original = byName.get(canonical) || file;
    const artist = text(file.artist || original.artist || file.creator || original.creator || metadata.creator) || 'Không rõ nghệ sĩ';
    const title = text(file.title || original.title) || file.name.replace(/\.[^.]+$/, '').replace(/_/g, ' ');
    const subjects = array(metadata.subject).flatMap(value => String(value).split(';')).map(value => value.trim()).filter(Boolean);
    return {
      archive_id: archiveHash(`${id}\0${canonical}`), catalog_source: 'archive', title,
      duration_ms: Math.round(seconds(file.length || original.length) * 1000),
      genre: text(file.genre) || subjects.find(value => /ambient|drone|experimental|electronic|soundscape/i.test(value)) || '',
      cover_url: `https://archive.org/services/img/${id}`, audio_url: archiveFileUrl(id, file.name), imported_at: fetchedAt,
      archive_metadata: { collection, item_id: id, file_name: file.name, canonical_file: canonical,
        artist, album: text(file.album || original.album || metadata.title), item_url: audit.itemUrl, license_url: license.url, license_label: license.label,
        format: file.format || file.name.split('.').at(-1), size: Number(file.size) || null,
        md5: file.md5 || '', sha1: file.sha1 || '', release_date: text(metadata.date),
        track_number: Number.parseInt(file.track, 10) || null, subjects, region: 'INTL', fetched_at: fetchedAt }
    };
  });
  audit.tracks = tracks.length; audit.trackIds = tracks.map(track => track.archive_id).sort(); audit.license = license; if (!tracks.length) audit.reason = 'no_supported_public_audio';
  return { audit, tracks };
}
