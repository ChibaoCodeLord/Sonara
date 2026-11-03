const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');

const output = process.env.UI_REVIEW_OUTPUT || path.resolve('ui-review-artifacts');
fs.mkdirSync(output, { recursive: true });
const server = spawn(process.execPath, ['node_modules/vite/bin/vite.js', '--host', '127.0.0.1', '--port', '5198', '--strictPort'], { stdio: 'pipe', windowsHide: true });
const report = { layouts: [], interactions: [], errors: [] };
const origin = 'http://127.0.0.1:5198';

(async () => {
  let browser;
  try {
    await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error('Vite startup timed out')), 15000);
      server.stdout.on('data', chunk => { if (chunk.toString().includes('ready in')) { clearTimeout(timer); resolve(); } });
      server.on('error', reject);
      server.on('exit', code => reject(new Error(`Vite exited ${code}`)));
    });
    browser = await chromium.launch({ headless: true, channel: process.env.UI_BROWSER || 'chrome' });
    const page = await browser.newPage();
    page.on('pageerror', error => report.errors.push(error.message));
    // Deny the microphone in automation; Hum must remain usable with its demo visualizer.
    await page.addInitScript(() => { if (navigator.mediaDevices) navigator.mediaDevices.getUserMedia = async () => { throw new Error('Microphone denied for UI test'); }; });
    await page.addInitScript(() => {
      window.Audio = new Proxy(window.Audio, { construct(Target, args) {
        const audio = Reflect.construct(Target, args);
        window.__reviewAudio = audio;
        return audio;
      } });
    });
    const sizes = [[1920,1080], [1366,768], [1366,600], [1024,768], [768,1024], [375,812], [812,375], [320,568]];
    const routes = ['/', '/charts', '/library', '/search?q=Hoang', '/profile', '/playlist/playlist_ai_mix_01', '/artist/artist_vu', '/playlist/playlist_liked_songs'];
    for (const [width, height] of (process.env.UI_INTERACTIONS_ONLY ? [] : sizes)) {
      await page.setViewportSize({ width, height });
      for (const route of routes) {
        await page.goto(origin + route, { waitUntil: 'domcontentloaded' });
        await page.locator('main > div').waitFor();
        const layout = await page.evaluate(() => {
          const main = document.querySelector('main'), footer = document.querySelector('.bottom-player');
          const m = main.getBoundingClientRect(), f = footer.getBoundingClientRect();
          const hero = main.querySelector('.home-hero');
          return { mainWidth: main.clientWidth, mainScrollWidth: main.scrollWidth, footerWidth: footer.clientWidth, footerScrollWidth: footer.scrollWidth, mainBottom: m.bottom, footerTop: f.top, footerBottom: f.bottom, viewportHeight: innerHeight, documentWidth: document.documentElement.scrollWidth, viewportWidth: innerWidth, heroBottom: hero?.getBoundingClientRect().bottom };
        });
        const label = `${width}x${height} ${route}`;
        assert(layout.mainWidth >= Math.min(width - 48, 280), `Main collapsed: ${label}`);
        assert(layout.mainScrollWidth <= layout.mainWidth + 1, `Content overflows: ${label} ${JSON.stringify(layout)}`);
        assert(layout.footerScrollWidth <= layout.footerWidth + 1, `Player overflows: ${label}`);
        assert(layout.documentWidth <= width + 1, `Document overflows: ${label}`);
        assert(Math.abs(layout.mainBottom - layout.footerTop) <= 1, `Player overlaps content: ${label}`);
        assert(Math.abs(layout.footerBottom - height) <= 1, `Player outside viewport: ${label}`);
        if (route === '/' && width >= 1024 && height >= 600) assert(layout.heroBottom < layout.footerTop - 40, `Hero hides next section: ${label}`);
        await page.locator('main').evaluate(el => { el.scrollTop = el.scrollHeight; });
        const reachedEnd = await page.locator('main').evaluate(el => Math.abs(el.scrollHeight - el.clientHeight - el.scrollTop) <= 2);
        assert(reachedEnd, `Cannot reach content end: ${label}`);
        report.layouts.push({ width, height, route, ...layout });
        if (['/', '/profile'].includes(route)) {
          await page.locator('main').evaluate(el => { el.scrollTop = 0; });
          await page.screenshot({ path: path.join(output, `${route === '/' ? 'home' : 'profile'}-${width}x${height}.png`) });
        }
      }
      console.log(`Layout passed: ${width}x${height}, ${routes.length} routes`);
    }
    await page.setViewportSize({ width: 1366, height: 600 });
    await page.goto(origin + '/search?q=Hoang');
    await page.getByRole('button', { name: 'Nghệ sĩ', exact: true }).click();
    assert.equal(await page.getByRole('region', { name: 'Kết quả bài hát' }).count(), 0);
    await page.getByRole('button', { name: 'Hoàng Dũng', exact: true }).click();
    assert(page.url().endsWith('/artist/artist_hoangdung'));
    report.interactions.push('Accent-insensitive artist search and artist filter navigation');
    await page.goto(origin + '/search');
    const search = page.getByRole('textbox', { name: 'Từ khóa tìm kiếm' });
    await search.fill('Bau Troi Moi ');
    await page.waitForFunction(() => document.querySelector('input[aria-label="Từ khóa tìm kiếm"]').value === 'Bau Troi Moi ');
    assert.equal(await search.inputValue(), 'Bau Troi Moi ');
    assert.equal(await page.locator('main .track-row').count(), 1);
    await search.fill('');
    await search.pressSequentially('Bau Troi Moi', { delay: 25 });
    await page.waitForFunction(() => document.querySelector('input[aria-label="Từ khóa tìm kiếm"]').value === 'Bau Troi Moi');
    report.interactions.push('Search preserves spaces and finds Vietnamese song without accents');
    await page.goto(origin + '/library');
    await page.getByRole('button', { name: 'Bài hát đã thích (3)' }).click();
    assert.equal(await page.locator('main .track-row').count(), 3);
    assert.equal(await page.getByRole('heading', { name: 'Danh sách phát', exact: true }).count(), 0);
    await page.locator('main .track-row').first().getByTitle('Bỏ thích').click();
    assert.equal(await page.locator('main .track-row').count(), 2);
    await page.getByRole('button', { name: 'Nghệ sĩ', exact: true }).click();
    assert.equal(await page.getByRole('heading', { name: 'Bài hát yêu thích', exact: true }).count(), 0);
    report.interactions.push('Library filters and favorite count update immediately');
    await page.getByRole('button', { name: 'Vũ.', exact: false }).first().click();
    await page.getByRole('button', { name: 'Đang theo dõi', exact: true }).click();
    await page.locator('#main-navigation').getByRole('link', { name: 'Thư viện', exact: true }).click();
    await page.getByRole('button', { name: 'Nghệ sĩ', exact: true }).click();
    assert.equal(await page.getByRole('button', { name: 'Vũ.', exact: false }).count(), 0);
    report.interactions.push('Following state stays synchronized between artist page and library');
    await page.goto(origin + '/charts');
    await page.getByRole('button', { name: 'Podcast', exact: true }).click();
    assert.equal(await page.locator('main .track-row').count(), 0);
    assert((await page.locator('main').innerText()).includes('Chưa có dữ liệu cho danh mục này'));
    await page.getByRole('button', { name: 'Tổng hợp', exact: true }).click();
    await page.getByRole('button', { name: /Quốc Tế Viral/ }).click();
    assert.equal(await page.locator('main .track-row').count(), 0);
    assert((await page.locator('main').innerText()).includes('Die With A Smile'));
    report.interactions.push('Chart categories filter and international demo does not play unrelated songs');
    await page.goto(origin + '/playlist/playlist_liked_songs');
    assert.equal(await page.locator('#main-navigation').getByRole('link', { name: 'Bài hát yêu thích', exact: true }).count(), 1);
    assert.equal(await page.getByRole('heading', { level: 1 }).innerText(), 'Bài hát yêu thích');
    assert.equal(await page.locator('main .track-row').count(), 2);
    await page.goto(origin + '/playlist/not-found');
    assert((await page.locator('main').innerText()).includes('Không tìm thấy'));
    report.interactions.push('Liked playlist resolves actual favorites; invalid playlist shows empty state');
    await page.goto(origin);
    await page.getByTitle('Hàng đợi phát nhạc').click();
    await page.getByRole('dialog', { name: 'Hàng đợi phát nhạc' }).waitFor();
    assert(await page.locator('footer').getByTitle('Phát', { exact: true }).isVisible());
    await page.keyboard.press('Escape');
    assert.equal(await page.getByRole('dialog').count(), 0);
    await page.getByTitle('Lời bài hát đồng bộ').click();
    await page.getByRole('dialog', { name: 'Lời bài hát', exact: true }).waitFor();
    await page.getByRole('button', { name: /Từng lời hứa năm xưa/ }).click();
    await page.waitForFunction(() => Math.abs(window.__reviewAudio.currentTime - 32) < .5);
    await page.keyboard.press('Escape');
    await page.getByRole('button', { name: 'Mở trình phát toàn màn hình', exact: true }).click();
    await page.getByRole('dialog', { name: 'Trình phát toàn màn hình' }).waitFor();
    const slider = page.getByRole('slider', { name: 'Vị trí phát' }).last();
    await slider.focus();
    await page.keyboard.press('ArrowRight');
    assert(Number(await slider.inputValue()) > 0);
    await page.waitForFunction(() => {
      const input = [...document.querySelectorAll('input[aria-label="Vị trí phát"]')].at(-1);
      return Math.abs(window.__reviewAudio.currentTime - Number(input.value)) < .5;
    });
    await page.keyboard.press('Escape');
    report.interactions.push('Queue, lyrics and fullscreen close with Escape; seeking works from keyboard');
    await page.setViewportSize({ width: 375, height: 812 });
    await page.getByRole('button', { name: 'Mở menu', exact: true }).click();
    await page.locator('#main-navigation').getByRole('link', { name: 'Thư viện', exact: true }).click();
    assert(page.url().endsWith('/library'));
    assert.equal(await page.locator('.sidebar-open').count(), 0);
    report.interactions.push('Mobile navigation opens, navigates and closes');
    await page.getByRole('button', { name: 'Mở menu', exact: true }).click();
    await page.setViewportSize({ width: 1366, height: 768 });
    await page.waitForFunction(() => !document.querySelector('.sidebar-open'));
    await page.locator('#main-navigation').getByRole('link', { name: 'Thư viện', exact: true }).click();
    const scrollTop = await page.locator('main').evaluate(el => el.scrollTop);
    assert.equal(scrollTop, 0);
    report.interactions.push('Resizing to desktop closes mobile menu and navigation resets content scroll');
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto(origin);
    await page.getByRole('button', { name: 'Thử tìm kiếm ngay' }).click();
    const hum = page.getByRole('dialog', { name: 'Tìm bằng giai điệu' });
    await hum.waitFor();
    assert((await hum.innerText()).includes('Một giai điệu là đủ để bắt đầu'));
    const humBox = await hum.boundingBox();
    assert(humBox.y >= 0 && humBox.y + humBox.height <= 813);
    await page.getByRole('button', { name: 'Xem kết quả minh họa', exact: true }).click();
    await hum.getByText('Đã tìm thấy 3 bài hát tương đồng').waitFor();
    const beforeQueue = await page.evaluate(async () => (await import('/src/store/usePlayerStore.js')).usePlayerStore.getState().queue.length);
    await hum.getByTitle('Thêm vào hàng đợi').click();
    const afterQueue = await page.evaluate(async () => (await import('/src/store/usePlayerStore.js')).usePlayerStore.getState().queue.length);
    assert.equal(afterQueue, beforeQueue + 1);
    await page.screenshot({ path: path.join(output, 'hum-results-mobile.png') });
    await page.keyboard.press('Escape');
    await page.getByRole('button', { name: 'Thử tìm kiếm ngay' }).click();
    assert((await hum.innerText()).includes('Một giai điệu là đủ để bắt đầu'));
    await page.keyboard.press('Escape');
    report.interactions.push('Hum fits viewport, previews results without a microphone and resets after reopening');
    await page.emulateMedia({ reducedMotion: 'reduce' });
    assert.equal(await page.locator('.hero-wave span').first().evaluate(el => getComputedStyle(el).animationIterationCount), '1');
    report.interactions.push('Reduced motion respected');
    assert.deepEqual(report.errors, [], 'Browser runtime errors');
    report.passed = true;
    console.log(JSON.stringify({ layouts: report.layouts.length, interactions: report.interactions, errors: report.errors }, null, 2));
  } finally {
    fs.writeFileSync(path.join(output, 'ui-review-results.json'), JSON.stringify(report, null, 2));
    await browser?.close();
    server.kill();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
