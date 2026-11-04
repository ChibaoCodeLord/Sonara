const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const output = process.env.UI_ARCHIVE_OUTPUT || path.resolve('ui-review-artifacts/archive');
const origin = process.env.UI_ORIGIN || 'http://127.0.0.1:5173';
const report = { errors: [], layouts: [], audioMocked: false, iframeRequests: [] };
fs.mkdirSync(output, { recursive: true });
let browser;
(async () => {
  try {
    browser = await chromium.launch({ channel: 'chrome', headless: true, args: ['--autoplay-policy=no-user-gesture-required'] });
    const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
    page.on('pageerror', error => report.errors.push(error.message));
    page.on('request', request => { if (/youtube\.com\/(iframe_api|embed\/)/.test(request.url())) report.iframeRequests.push(request.url()); });
    await page.addInitScript(() => { const RealAudio = window.Audio; window.Audio = function(...args) { const audio = new RealAudio(...args); window.__audio = audio; return audio; }; window.Audio.prototype = RealAudio.prototype; });
    const statusResponse = await page.request.get(`${origin}/api/v1/catalog/archive/status?collection=restingbell`);
    const status = (await statusResponse.json()).data; report.catalog = status;
    assert.equal(status.complete, true); assert.equal(status.reconciliation.sameTrackIds, true);
    await page.goto(`${origin}/youtube?source=archive&collection=restingbell`);
    await page.getByRole('heading', { name: 'Resting Bell', exact: true }).waitFor();
    await page.evaluate(async () => {
      // Vite HMR appends timestamps; importing a different URL creates a second store.
      const loaded = name => performance.getEntriesByType('resource').map(entry => entry.name).find(url => new URL(url).pathname === `/src/store/${name}.js`);
      window.__remote = (await import(loaded('useRemoteCatalogStore'))).useRemoteCatalogStore;
      window.__player = (await import(loaded('usePlayerStore'))).usePlayerStore;
    });
    await page.waitForFunction(() => !['idle', 'loading'].includes(window.__remote.getState().status), null, { timeout: 60000 });
    report.remote = await page.evaluate(() => ({ status: window.__remote.getState().status, error: window.__remote.getState().error, count: window.__remote.getState().tracks.length }));
    assert.equal(report.remote.status, 'ready', JSON.stringify(report.remote));
    const tracks = await page.evaluate(() => window.__remote.getState().tracks.filter(track => track.provider === 'archive' && track.collection === 'restingbell'));
    assert.equal(tracks.length, status.reconciliation.actualTracks); assert.equal(new Set(tracks.map(track => track.id)).size, tracks.length);
    await page.getByText(`${tracks.length} bài hát · ${tracks.length} bài có audio trực tiếp`, { exact: true }).waitFor();
    assert.equal(await page.locator('.youtube-track-card').count(), 48);
    assert.equal(await page.locator('.youtube-track-card a[href^="http"]').count(), 0);
    await page.getByRole('button', { name: /Xem thêm bài hát/ }).click(); assert.equal(await page.locator('.youtube-track-card').count(), 96);
    const track = tracks.find(track => track.durationSeconds > 60 && /\.mp3$/i.test(track.audioUrl)); assert(track);
    await page.getByRole('textbox', { name: 'Tìm trong kho nhạc' }).fill(track.title);
    await page.locator('.youtube-track-card').filter({ has: page.getByRole('link', { name: track.title, exact: true }) }).getByRole('button', { name: `Phát ${track.title}`, exact: true }).first().click();
    await page.waitForFunction(id => window.__player.getState().currentSong?.id === id && !window.__audio.paused && window.__audio.currentTime >= 2, track.id, { timeout: 120000 });
    report.playback = await page.evaluate(() => ({ title: window.__player.getState().currentSong.title, time: window.__audio.currentTime, duration: window.__audio.duration, url: window.__audio.currentSrc }));
    await page.evaluate(() => window.__player.getState().seekTo(35));
    await page.waitForFunction(() => window.__audio.currentTime >= 35 && window.__audio.currentTime < 45);
    await page.evaluate(() => window.__player.getState().pause()); assert.equal(await page.evaluate(() => window.__audio.paused), true);
    assert.equal(await page.locator('iframe').count(), 0); assert.deepEqual(report.iframeRequests, []);
    await page.getByRole('textbox', { name: 'Tìm trong kho nhạc' }).fill('');
    for (const [width, height] of [[1440,900],[1366,600],[768,1024],[375,812],[320,568]]) {
      await page.setViewportSize({ width, height });
      const layout = await page.evaluate(() => { const main = document.querySelector('main'); return { viewport: innerWidth, doc: document.documentElement.scrollWidth, main: main.clientWidth, scroll: main.scrollWidth }; });
      assert(layout.doc <= width + 1 && layout.scroll <= layout.main + 1, JSON.stringify(layout)); report.layouts.push(layout);
      await page.getByRole('heading', { name: 'Nghe nhạc', exact: true }).scrollIntoViewIfNeeded();
      if ([1440,375].includes(width)) await page.screenshot({ path: path.join(output, `archive-${width}.png`) });
    }
    await page.goto(`${origin}/track/${track.id}`);
    await page.getByRole('heading', { name: track.title, exact: true }).waitFor();
    await page.getByRole('link', { name: `Giấy phép: ${track.licenseLabel} ↗`, exact: true }).waitFor();
    assert.deepEqual(report.errors, []); report.complete = true;
    console.log(JSON.stringify(report, null, 2));
  } finally { fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify(report, null, 2)); await browser?.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
