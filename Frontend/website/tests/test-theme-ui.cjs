const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const output = process.env.UI_THEME_OUTPUT || path.resolve('ui-review-artifacts/theme');
fs.mkdirSync(output, { recursive: true });
const origin = 'http://127.0.0.1:5219';
const report = { errors: [], layouts: [], contrast: [], checks: [], catalogFixture: true };
const server = spawn(process.execPath, ['node_modules/vite/bin/vite.js', '--host', '127.0.0.1', '--port', '5219', '--strictPort'], { windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
let browser;
const luminance = rgb => rgb.map(c => c / 255).map(c => c <= .04045 ? c / 12.92 : ((c + .055) / 1.055) ** 2.4).reduce((sum, c, i) => sum + c * [.2126,.7152,.0722][i], 0);
const contrast = (fg, bg) => { const a = luminance(fg), b = luminance(bg); return (Math.max(a,b) + .05) / (Math.min(a,b) + .05); };
(async () => {
  try {
    await new Promise((resolve, reject) => { const timer = setTimeout(() => reject(Error('Vite timeout')), 20000); server.on('error', reject); server.stdout.on('data', data => { if (String(data).includes('Local:')) { clearTimeout(timer); resolve(); } }); });
    console.log('Theme UI: Vite ready');
    browser = await chromium.launch({ channel: 'chrome', headless: true });
    const context = await browser.newContext({ colorScheme: 'dark', viewport: { width: 1440, height: 900 } });
    await context.route('**/api/v1/catalog/**', route => route.fulfill({ json: { data: { tracks: [], pagination: { total: 0, totalPages: 0 } } } }));
    const page = await context.newPage(); page.on('pageerror', e => report.errors.push(e.message));
    await page.goto(origin, { waitUntil: 'domcontentloaded' });
    await page.getByRole('button', { name: 'Chuyển sang giao diện sáng' }).click();
    assert.equal(await page.locator('html').getAttribute('data-theme'), 'light');
    assert.equal(await page.evaluate(() => localStorage.getItem('sonara-theme')), 'light');
    const beforeReact = await context.newPage();
    await beforeReact.route('**/src/main.jsx', route => route.abort());
    await beforeReact.goto(origin, { waitUntil: 'domcontentloaded' });
    assert.equal(await beforeReact.locator('html').getAttribute('data-theme'), 'light');
    assert.equal(await beforeReact.evaluate(() => getComputedStyle(document.documentElement).backgroundColor), 'rgb(245, 246, 250)');
    await beforeReact.close(); report.checks.push('Saved palette applies before React loads');
    await page.reload({ waitUntil: 'domcontentloaded' }); await page.getByRole('button', { name: 'Chuyển sang giao diện tối' }).waitFor();
    report.checks.push('Topbar toggle persists across reload');
    console.log('Theme UI: toggle and reload passed');
    await page.goto(`${origin}/settings?tab=appearance`, { waitUntil: 'domcontentloaded' });
    await page.getByRole('radio', { name: 'Theo hệ thống', exact: true }).check();
    await page.emulateMedia({ colorScheme: 'light' }); await page.waitForFunction(() => document.documentElement.dataset.theme === 'light');
    await page.emulateMedia({ colorScheme: 'dark' }); await page.waitForFunction(() => document.documentElement.dataset.theme === 'dark');
    await page.getByRole('radio', { name: 'Sáng', exact: true }).check();
    await page.getByRole('radio', { name: 'Sáng', exact: true }).focus(); await page.keyboard.press('ArrowRight');
    assert.equal(await page.locator('html').getAttribute('data-theme'), 'dark');
    await page.getByRole('radio', { name: 'Sáng', exact: true }).check();
    await page.emulateMedia({ colorScheme: 'dark' }); assert.equal(await page.locator('html').getAttribute('data-theme'), 'light');
    report.checks.push('System changes are followed only in system mode');
    console.log('Theme UI: system preference passed');
    const sibling = await context.newPage(); await sibling.goto(origin, { waitUntil: 'domcontentloaded' });
    await sibling.getByRole('button', { name: 'Chuyển sang giao diện tối' }).click();
    await page.waitForFunction(() => document.documentElement.dataset.theme === 'dark'); await sibling.close();
    report.checks.push('Preference synchronizes across browser tabs');
    console.log('Theme UI: cross-tab sync passed');
    for (const mode of ['light','dark']) {
      await page.goto(`${origin}/settings?tab=appearance`, { waitUntil: 'domcontentloaded' });
      await page.getByRole('radio', { name: mode === 'light' ? 'Sáng' : 'Tối', exact: true }).check();
      for (const [width,height] of [[1440,900],[375,812],[320,568]]) {
        console.log(`Theme UI: ${mode} ${width}px`);
        await page.setViewportSize({ width,height });
        for (const route of ['/', '/charts', '/library', '/settings?tab=appearance', '/profile', '/youtube', '/login', '/browse']) {
          await page.goto(origin + route, { waitUntil: 'domcontentloaded' });
          await page.locator(route === '/login' ? '.ui-auth' : 'main').waitFor();
          const layout = await page.evaluate(() => { const main = document.querySelector('main') || document.querySelector('.ui-auth'); return { viewport: innerWidth, doc: document.documentElement.scrollWidth, main: main.clientWidth, scroll: main.scrollWidth }; });
          assert(layout.doc <= width + 1 && layout.scroll <= layout.main + 1, `${mode} ${route} ${JSON.stringify(layout)}`); report.layouts.push({ mode, route, ...layout });
          if (route === '/' && [1440,375].includes(width)) await page.screenshot({ path: path.join(output, `${mode}-${width}.png`) });
        }
      }
      await page.setViewportSize({ width:1440,height:900 }); await page.goto(`${origin}/settings?tab=appearance`, { waitUntil:'domcontentloaded' });
      await page.getByRole('radio', { name: mode === 'light' ? 'Sáng' : 'Tối', exact:true }).waitFor();
      const tokens = await page.evaluate(() => { const s = getComputedStyle(document.documentElement); return Object.fromEntries(['text-primary','text-muted','text-link','bg-base','bg-card'].map(key => [key,s.getPropertyValue(`--${key}`).trim().split(/\s+/).map(Number)])); });
      for (const text of ['text-primary','text-muted','text-link']) for (const bg of ['bg-base','bg-card']) { const ratio=contrast(tokens[text],tokens[bg]); assert(ratio >= 4.5, `${mode} ${text}/${bg}: ${ratio}`); report.contrast.push({ mode,text,bg,ratio }); }
      await page.locator('header').getByRole('button', { name: 'Thông báo', exact:true }).click(); await page.getByRole('dialog').waitFor();
      await page.screenshot({ path:path.join(output, `${mode}-dialog.png`) }); await page.keyboard.press('Escape');
      await page.getByRole('button', { name:'Mở trình phát toàn màn hình', exact:true }).click(); await page.getByRole('dialog', { name:'Trình phát toàn màn hình' }).waitFor();
      const lyricColor = await page.locator('.fullscreen-lyric-preview').evaluate(element => getComputedStyle(element).color);
      const lyricRgb = lyricColor.match(/[\d.]+/g).slice(0,3).map(Number);
      assert(contrast(lyricRgb, tokens['bg-base']) >= 4.5, `Fullscreen lyric contrast: ${mode} ${lyricColor}`);
      await page.screenshot({ path:path.join(output, `${mode}-player.png`) }); await page.keyboard.press('Escape');
    }
    const blocked = await browser.newContext({ colorScheme:'light' });
    await blocked.addInitScript(() => { Object.defineProperty(window,'localStorage',{get(){throw new DOMException('Blocked','SecurityError');}}); });
    const unavailable = await blocked.newPage(); unavailable.on('pageerror',e=>report.errors.push(e.message));
    await unavailable.goto(`${origin}/login`, { waitUntil:'domcontentloaded' }); await unavailable.getByRole('button',{name:'Chuyển sang giao diện tối'}).click();
    assert.equal(await unavailable.locator('html').getAttribute('data-theme'),'dark'); await blocked.close();
    report.checks.push('Theme still switches when browser storage is blocked');
    assert.deepEqual(report.errors, []); report.complete=true; console.log(JSON.stringify({checks:report.checks,layouts:report.layouts.length,contrast:report.contrast,errors:report.errors}));
  } finally { fs.writeFileSync(path.join(output,'results.json'),JSON.stringify(report,null,2)); await browser?.close(); server.kill(); }
})().catch(e=>{console.error(e);process.exitCode=1;});
