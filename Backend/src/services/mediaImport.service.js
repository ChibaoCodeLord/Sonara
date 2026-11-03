import { spawn } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { mkdir, readFile, readdir, writeFile, rename, rm, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export function youtubeUrl(input) {
  let url;
  try { url = new URL(input); } catch { throw new Error('Hãy nhập liên kết YouTube hợp lệ.'); }
  const host = url.hostname.toLowerCase();
  if (url.protocol !== 'https:' || url.port || url.username || url.password || !['youtube.com', 'www.youtube.com', 'm.youtube.com', 'music.youtube.com', 'youtu.be'].includes(host)) throw new Error('Chỉ hỗ trợ liên kết HTTPS của YouTube.');
  const id = host === 'youtu.be' ? url.pathname.slice(1) : url.pathname === '/watch' ? url.searchParams.get('v') : /^\/(shorts|live|embed)\//.test(url.pathname) ? url.pathname.split('/')[2] : '';
  if (!/^[\w-]{11}$/.test(id || '')) throw new Error('Dán liên kết một video, không phải kênh hoặc danh sách phát.');
  return `https://www.youtube.com/watch?v=${id}`;
}

export function runCommand(command, args, { signal, onLine, timeout = 180000, maxOutput = 4 * 1024 * 1024 } = {}) {
  return new Promise((resolve, reject) => {
    if (signal?.aborted) { reject(new Error('cancelled')); return; }
    const child = spawn(command, args, { shell: false, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
    let stdout = '', stderr = '', buffer = '', bytes = 0, failure;
    const stop = message => {
      if (failure) return;
      failure = new Error(message);
      if (process.platform === 'win32' && child.pid) {
        const killer = spawn('taskkill', ['/PID', String(child.pid), '/T', '/F'], { windowsHide: true, shell: false, stdio: 'ignore' });
        killer.on('error', () => child.kill());
      } else child.kill();
    };
    const abort = () => stop('cancelled');
    signal?.addEventListener('abort', abort, { once: true });
    const timer = setTimeout(() => stop('Quá thời gian xử lý. Hãy thử video ngắn hơn.'), timeout);
    const receive = (chunk, error) => {
      bytes += chunk.length;
      if (bytes > maxOutput) { stop('Dữ liệu trả về vượt giới hạn.'); return; }
      if (error) stderr = (stderr + chunk).slice(-16000);
      else stdout += chunk;
      buffer += chunk;
      const lines = buffer.split(/[\r\n]+/); buffer = lines.pop();
      for (const line of lines) onLine?.(line);
    };
    child.stdout.on('data', chunk => receive(chunk.toString(), false));
    child.stderr.on('data', chunk => receive(chunk.toString(), true));
    child.on('error', error => { clearTimeout(timer); signal?.removeEventListener('abort', abort); reject(error); });
    child.on('close', code => {
      clearTimeout(timer);
      signal?.removeEventListener('abort', abort);
      if (failure) reject(failure);
      else if (code !== 0) reject(new Error(stderr || `Tiến trình dừng (${code}).`));
      else resolve(stdout);
    });
  });
}

const defaultRoot = fileURLToPath(new URL('../../temp/media-library/', import.meta.url));
const terminal = new Set(['ready', 'failed', 'cancelled']);
const commonArgs = ['--ignore-config', '--no-plugin-dirs', '--no-playlist', '--no-cache-dir', '--js-runtimes', `node:${process.execPath}`, '--socket-timeout', '15', '--retries', '2', '--fragment-retries', '2'];
export class MediaImports {
  constructor({ root = defaultRoot, runner = runCommand, ytdlp = process.env.YTDLP_PATH || 'yt-dlp', ffmpeg = process.env.FFMPEG_PATH || 'ffmpeg', maxFiles = 30, maxConcurrent = 2, reuseMetadata = false } = {}) {
    if (!Number.isSafeInteger(maxFiles) || maxFiles < 1 || !Number.isSafeInteger(maxConcurrent) || maxConcurrent < 1 || maxConcurrent > 4) throw new Error('Giới hạn media không hợp lệ.');
    this.root = root; this.runner = runner; this.ytdlp = ytdlp; this.ffmpeg = ffmpeg;
    this.maxFiles = maxFiles; this.maxConcurrent = maxConcurrent; this.reuseMetadata = reuseMetadata;
    this.jobs = new Map(); this.controllers = new Map(); this.tasks = new Map(); this.active = 0; this.check = null;
  }
  async init() {
    await mkdir(this.root, { recursive: true });
    for (const name of await readdir(this.root)) {
      if (!/^[a-f\d-]{36}$/.test(name)) continue;
      try {
        const job = JSON.parse(await readFile(path.join(this.root, name, 'job.json'), 'utf8'));
        if (job.id !== name) continue;
        if (!terminal.has(job.status)) { job.status = 'failed'; job.error = 'Dịch vụ đã khởi động lại. Hãy chuyển đổi lại video.'; }
        if (job.status === 'ready') await stat(path.join(this.root, name, 'audio.mp3'));
        this.jobs.set(name, job);
        if (job.status !== 'ready') {
          for (const file of await readdir(path.join(this.root, name))) {
            if (file !== 'job.json') await rm(path.join(this.root, name, file), { recursive: true, force: true });
          }
          await this.persist(job);
        }
      } catch { /* Ignore incomplete manifests; never execute or expose directory names. */ }
    }
  }
  async health() {
    if (!this.check) this.check = Promise.all([this.runner(this.ytdlp, ['--version'], { timeout: 30000 }), this.runner(this.ffmpeg, ['-version'], { timeout: 30000 })])
      .then(([version]) => ({ ready: true, version: version.trim(), maxDuration: 1800 }))
      .catch(() => { this.check = null; return { ready: false, message: 'Không chạy được yt-dlp hoặc FFmpeg. Kiểm tra cấu hình dịch vụ media.', maxDuration: 1800 }; });
    return this.check;
  }
  get(id) { return this.jobs.get(id); }
  async persist(job) {
    const folder = path.join(this.root, job.id);
    await mkdir(folder, { recursive: true });
    await writeFile(path.join(folder, 'job.json.tmp'), JSON.stringify(job));
    await rename(path.join(folder, 'job.json.tmp'), path.join(folder, 'job.json'));
  }
  async create(input) {
    const url = youtubeUrl(input);
    if (this.active >= this.maxConcurrent) throw Object.assign(new Error('Dịch vụ đang bận. Hãy đợi rồi thử lại.'), { status: 429 });
    if ([...this.jobs.values()].filter(job => job.status === 'ready').length + this.active >= this.maxFiles) throw Object.assign(new Error(`Thư viện đã có ${this.maxFiles} tệp. Xóa một tệp trước khi thêm video.`), { status: 409 });
    if (!(await this.health()).ready) throw Object.assign(new Error('Dịch vụ thiếu yt-dlp hoặc FFmpeg.'), { status: 503 });
    // Bound failed/cancelled manifests as well as finished files.
    for (const previous of [...this.jobs.values()]) {
      if (this.jobs.size < this.maxFiles * 2) break;
      if (['failed', 'cancelled'].includes(previous.status) && !this.controllers.has(previous.id)) await this.remove(previous.id);
    }
    // Reserve the slot synchronously after the asynchronous dependency check.
    if (this.active >= this.maxConcurrent) throw Object.assign(new Error('Dịch vụ đang bận. Hãy thử lại sau.'), { status: 429 });
    if ([...this.jobs.values()].filter(job => job.status === 'ready').length + this.active >= this.maxFiles) throw Object.assign(new Error(`Thư viện đã đạt giới hạn ${this.maxFiles} tệp.`), { status: 409 });
    const job = { id: randomUUID(), url, status: 'metadata', progress: 0, createdAt: new Date().toISOString() };
    this.active++;
    this.jobs.set(job.id, job);
    try { await this.persist(job); } catch (error) { this.active--; this.jobs.delete(job.id); throw error; }
    const controller = new AbortController(); this.controllers.set(job.id, controller);
    const task = this.process(job, controller).catch(() => {}).finally(() => this.tasks.delete(job.id));
    this.tasks.set(job.id, task);
    return job;
  }
  async process(job, controller) {
    const folder = path.join(this.root, job.id);
    try {
      const metadata = JSON.parse(await this.runner(this.ytdlp, [...commonArgs, '--dump-single-json', '--skip-download', '--', job.url], { signal: controller.signal, timeout: 60000 }));
      if (controller.signal.aborted) throw new Error('cancelled');
      if (!Number.isFinite(metadata.duration) || metadata.duration <= 0 || metadata.duration > 1800 || metadata.is_live || metadata.live_status === 'is_upcoming') throw new Error('Chỉ hỗ trợ video đã phát hành, dài tối đa 30 phút.');
      job.title = String(metadata.title || 'YouTube audio').slice(0, 200);
      job.artist = String(metadata.uploader || metadata.channel || 'YouTube').slice(0, 120);
      job.metadata = Object.fromEntries(['id','title','track','artist','album','album_artist','track_number','channel_id','channel','uploader','thumbnail','upload_date','license','genre','duration'].filter(key => metadata[key] !== undefined).map(key => [key,metadata[key]]));
      job.duration = metadata.duration; job.status = 'downloading';
      await this.persist(job);
      const args = [...commonArgs, '--newline', '--progress', '--progress-template', 'download:SONARA:%(progress._percent_str)s', '--max-filesize', '100M', '--match-filter', 'duration <= 1800 & !is_live', '-f', 'bestaudio/best', '-x', '--audio-format', 'mp3', '--audio-quality', '192K', ...(this.ffmpeg !== 'ffmpeg' ? ['--ffmpeg-location', this.ffmpeg] : []), '-o', path.join(folder, 'audio.%(ext)s'), '--', job.url];
      if (this.reuseMetadata) {
        const infoPath = path.join(folder, 'download-info.tmp.json');
        await writeFile(infoPath, JSON.stringify(metadata));
        args.splice(-2, 2, '--load-info-json', infoPath);
      }
      await this.runner(this.ytdlp, args, { signal: controller.signal, onLine: line => {
        const match = line.match(/SONARA:\s*([\d.]+)%/);
        if (match) job.progress = Math.min(95, Math.round(Number(match[1]) * .95));
        if (line.includes('[ExtractAudio]')) { job.status = 'converting'; job.progress = 97; }
      } });
      if (controller.signal.aborted) throw new Error('cancelled');
      const file = await stat(path.join(folder, 'audio.mp3'));
      if (!file.size || file.size > 100 * 1024 * 1024) throw new Error('Không tạo được MP3 trong giới hạn 100 MB.');
      job.status = 'ready'; job.progress = 100;
      job.track = { id: `youtube_${job.id}`, title: job.title, artist: job.artist, album: 'YouTube · Thư viện cá nhân', genre: 'YouTube', coverUrl: job.metadata.thumbnail || '/images/catalog-placeholder.svg', audioUrl: `/media-api/jobs/${job.id}/audio`, durationSeconds: Math.round(job.duration), isLossless: false, lyrics: [], sourceUrl: job.url, mediaJobId: job.id };
    } catch (error) {
      job.status = controller.signal.aborted ? 'cancelled' : 'failed';
      job.failureKind = /429|too many requests/i.test(error.message) ? 'rate_limited' : /sign in|not a bot|login required|confirm your age/i.test(error.message) ? 'authentication_required' : /timed? ?out|ENOTFOUND|ECONN|network/i.test(error.message) ? 'network' : 'conversion_failed';
      job.error = job.status === 'cancelled' ? 'Đã hủy chuyển đổi.' : /30 phút|100 MB|thời gian/.test(error.message) ? error.message : 'Không tải được video. Video có thể riêng tư, giới hạn khu vực, hoặc YouTube đang chặn tải. Hãy thử video khác.';
      console.error(`[media:${job.id}] ${String(error.message).slice(0, 1000)}`);
    } finally {
      // Remove intermediates on every outcome; keep only a finished MP3 and manifest.
      try {
        for (const name of await readdir(folder)) {
          if (name !== 'job.json' && !(job.status === 'ready' && name === 'audio.mp3')) await rm(path.join(folder, name), { recursive: true, force: true });
        }
        await this.persist(job);
      } catch (error) { console.error('Không lưu được kết quả media:', error.message); }
      this.controllers.delete(job.id); this.active--;
    }
  }
  async remove(id) {
    const job = this.get(id);
    if (!job) return false;
    const controller = this.controllers.get(id);
    if (controller && !terminal.has(job.status)) { controller.abort(); await this.tasks.get(id); return true; }
    if (controller) await this.tasks.get(id);
    await rm(path.join(this.root, id), { recursive: true, force: true });
    this.jobs.delete(id); return true;
  }
  audioPath(id) { return path.join(this.root, id, 'audio.mp3'); }
}
