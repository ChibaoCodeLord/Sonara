const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const output = process.env.UI_AUDIO_OUTPUT || path.resolve('ui-review-artifacts/audio-native');
fs.mkdirSync(output, { recursive: true });
const report = { realAudio: true, mockedAudio: false, checks: [], layouts: [], errors: [], iframeRequests: [] };
const server = spawn(process.execPath, ['node_modules/vite/bin/vite.js', '--host', '127.0.0.1', '--port', '5218', '--strictPort'], { windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
let browser;
(async () => {
  try {
    await new Promise((resolve, reject) => { const timer = setTimeout(() => reject(new Error('Vite timeout')), 20000); server.once('error', reject); server.stdout.on('data', data => { if (String(data).includes('Local:')) { clearTimeout(timer); resolve(); } }); });
    browser = await chromium.launch({ channel: 'chrome', headless: true, args: ['--autoplay-policy=no-user-gesture-required'] });
    const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
    page.on('pageerror', error => report.errors.push(error.message));
    page.on('request', request => { if (/youtube\.com\/(iframe_api|embed\/)/.test(request.url())) report.iframeRequests.push(request.url()); });
    await page.addInitScript(() => { const RealAudio = window.Audio; window.Audio = function (...args) { const audio = new RealAudio(...args); window.__nativeAudio = audio; return audio; }; window.Audio.prototype = RealAudio.prototype; });
    await page.goto('http://127.0.0.1:5218/youtube?q=Come%20My%20Way');
    await page.getByRole('heading', { name: 'Nghe nhạc', exact: true }).waitFor();
    await page.evaluate(async () => { window.__player = (await import('/src/store/usePlayerStore.js')).usePlayerStore; window.__remote = (await import('/src/store/useRemoteCatalogStore.js')).useRemoteCatalogStore; });
    await page.waitForFunction(() => window.__remote.getState().status === 'ready');
    await page.getByRole('button', { name: 'Phát Come My Way', exact: true }).click();
    await page.waitForFunction(() => window.__nativeAudio && !window.__nativeAudio.paused && window.__nativeAudio.currentTime >= 2, null, { timeout: 90000 });
    const mp3 = await page.evaluate(() => ({ id: window.__player.getState().currentSong.id, currentTime: window.__nativeAudio.currentTime, duration: window.__nativeAudio.duration, audioUrl: window.__player.getState().currentSong.audioUrl }));
    assert.match(mp3.audioUrl, /\/api\/v1\/catalog\/audio\/jobs\//); report.mp3 = mp3;
    report.checks.push('Come My Way plays as a real MP3 in the native audio engine');
    const range = await page.request.get(`http://127.0.0.1:5218${mp3.audioUrl}`, { headers: { Range: 'bytes=0-2047' } });
    assert.equal(range.status(), 206); assert.equal((await range.body()).length, 2048);
    await page.evaluate(() => { const song = window.__player.getState().currentSong; window.__player.getState().playSong({ ...song, provider: 'youtube-audio', audioUrl: undefined }); });
    await page.waitForFunction(() => window.__player.getState().currentSong.provider === 'audio' && !window.__nativeAudio.paused && window.__nativeAudio.currentTime >= 2, null, { timeout: 90000 });
    assert.equal(await page.evaluate(() => window.__player.getState().currentSong.id), mp3.id);
    report.checks.push('On-demand preparation reuses the server MP3 and resumes audio with the same song ID');
    await page.route('**/api/v1/catalog/audio', route => route.fulfill({ status: 503, contentType: 'application/json', body: JSON.stringify({ error: 'Audio tạm thời chưa sẵn sàng.' }) }));
    await page.evaluate(() => { const song = window.__player.getState().currentSong; window.__player.getState().playSong({ ...song, provider: 'youtube-audio', audioUrl: undefined }); });
    await page.getByRole('button', { name: 'Thử lại', exact: true }).waitFor();
    assert.equal(await page.evaluate(() => window.__player.getState().isPlaying), false);
    await page.unroute('**/api/v1/catalog/audio');
    await page.getByRole('button', { name: 'Thử lại', exact: true }).click();
    await page.waitForFunction(() => window.__player.getState().currentSong.provider === 'audio' && !window.__nativeAudio.paused && window.__nativeAudio.currentTime >= 2, null, { timeout: 60000 });
    report.simulatedErrorResponse = true;
    report.checks.push('Conversion failure pauses playback, keeps a retry action and recovers with the real MP3');
    await page.evaluate(() => window.__player.getState().seekTo(35));
    await page.waitForFunction(() => window.__nativeAudio.currentTime >= 35 && window.__nativeAudio.currentTime < 40);
    await page.evaluate(() => window.__player.getState().pause());
    await page.waitForFunction(() => window.__nativeAudio.paused);
    report.checks.push('Native MP3 supports pause and seek; range requests work');
    await page.screenshot({ path: path.join(output, 'mp3-no-video-1440.png') });
    const audius = await page.evaluate(() => window.__remote.getState().tracks.find(track => track.metadataSource === 'audius'));
    assert(audius);
    await page.evaluate(song => window.__player.getState().playSong(song), audius);
    await page.waitForFunction(() => !window.__nativeAudio.paused && window.__nativeAudio.currentTime >= 2, null, { timeout: 60000 });
    report.audius = await page.evaluate(() => ({ title: window.__player.getState().currentSong.title, currentTime: window.__nativeAudio.currentTime, duration: window.__nativeAudio.duration }));
    report.checks.push('Real Audius audio stream plays directly without YouTube');
    assert.equal(await page.locator('iframe, .youtube-player').count(), 0); assert.deepEqual(report.iframeRequests, []);
    for (const [width, height] of [[1440,900],[1366,600],[1024,768],[768,1024],[375,812],[320,568],[812,375]]) {
      await page.setViewportSize({ width, height });
      for (const route of ['/', '/youtube', '/search?q=son%20tung', '/library']) {
        await page.goto('http://127.0.0.1:5218' + route); await page.getByRole('main').waitFor();
        const layout = await page.evaluate(() => { const main = document.querySelector('main'); return { width: innerWidth, doc: document.documentElement.scrollWidth, main: main.clientWidth, scroll: main.scrollWidth }; });
        assert(layout.doc <= width + 1 && layout.scroll <= layout.main + 1, `${route} ${JSON.stringify(layout)}`);
        report.layouts.push({ route, ...layout });
      }
      if (width === 375) await page.screenshot({ path: path.join(output, 'audio-mobile-375.png') });
    }
    assert.deepEqual(report.errors, []); console.log(JSON.stringify(report, null, 2));
  } finally { fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify(report, null, 2)); await browser?.close(); server.kill(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
