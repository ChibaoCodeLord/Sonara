const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const output = process.env.UI_LIBRARY_OUTPUT || path.resolve('ui-review-artifacts/test-library');
const origin = 'http://127.0.0.1:5222';
const email = 'quocdat19991712@gmail.com';
const workspace = 'sonara-workspace-v1', library = 'sonara-library-v1';
const report = { checks: [], errors: [], liveCatalog: true };
fs.mkdirSync(output, { recursive: true });
let browser, server;
const readState = page => page.evaluate(({ workspace, library }) => ({ app: JSON.parse(localStorage.getItem(workspace)).state, player: JSON.parse(localStorage.getItem(library)).state }), { workspace, library });
async function login(page, address) {
  await page.goto(origin + '/login?next=/library');
  await page.getByRole('textbox', { name: 'Địa chỉ email' }).fill(address);
  await page.getByPlaceholder('Ít nhất 8 ký tự').fill('demo-test-only');
  await page.getByRole('button', { name: 'Đăng nhập trải nghiệm', exact: true }).click();
  await page.getByRole('heading', { name: 'Thư viện cá nhân', exact: true }).waitFor();
}
async function logout(page) {
  await page.getByRole('button', { name: 'Mở menu tài khoản' }).click();
  await page.getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  await page.getByRole('dialog', { name: 'Đăng xuất khỏi bản trải nghiệm?' }).getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  await page.waitForURL('**/welcome');
}
(async () => {
  try {
    const { fetchActiveCatalog } = await import('../src/utils/remoteCatalog.js');
    const { createTestLibrary } = await import('../src/utils/testLibrary.js');
    const catalog = await fetchActiveCatalog(fetch, process.env.CATALOG_API_URL || 'http://127.0.0.1:5000/api/v1/catalog');
    const fixture = createTestLibrary(catalog.tracks, { email, dataset: catalog.dataset });
    assert(fixture); report.catalogCount = catalog.tracks.length; report.seedCounts = fixture.marker.counts;
    server = spawn(process.execPath, ['node_modules/vite/bin/vite.js', '--host', '127.0.0.1', '--port', '5222', '--strictPort'], { windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
    await new Promise((resolve, reject) => { const timer = setTimeout(() => reject(Error('Vite timeout')), 20000); server.on('error', reject); server.stdout.on('data', data => { if (String(data).includes('Local:')) { clearTimeout(timer); resolve(); } }); });
    browser = await chromium.launch({ channel: 'chrome', headless: true });
    const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, colorScheme: 'dark' });
    const page = await context.newPage(); page.on('pageerror', error => report.errors.push(error.message));
    await login(page, email);
    await page.getByText('Đã thêm dữ liệu kiểm thử', { exact: false }).waitFor();
    let state = await readState(page);
    assert.equal(state.app.playlists.length, 4); assert.equal(state.player.likedSongIds.length, 24);
    assert.equal(state.app.savedAlbumIds.length, 5); assert.equal(state.player.followedArtistIds.length, 6); assert.equal(state.app.history.length, 15);
    assert.deepEqual(state.app.listeningActivity, {});
    assert(state.app.playlists.every(p => p.songIds.length === 12 && p.songIds.every(id => catalog.tracks.some(t => t.id === id && t.audioUrl))));
    assert.equal(await page.locator('main a[href^="/album/"]').count(), 5);
    assert.equal(await page.locator('main section').filter({ has: page.getByRole('heading', { name: 'Nghệ sĩ đang theo dõi', exact: true }) }).locator('.ui-content-card').count(), 6);
    await page.screenshot({ path: path.join(output, 'library-dark-desktop.png') });
    report.checks.push('Target login automatically receives 4 playlists with 12 real catalog tracks each, 24 likes, 5 albums, 6 artists, 15 sample history entries and no fabricated streak');
    await page.getByRole('button', { name: 'Nhạc Việt của Đạt', exact: true }).click();
    assert.equal(await page.locator('main a.ui-content-card[href^="/playlist/"]').count(), 2);
    await page.getByRole('button', { name: 'Tất cả thư mục', exact: true }).click();
    const playlist = state.app.playlists[0];
    await page.locator(`main a.ui-content-card[href="/playlist/${playlist.id}"]`).click();
    await page.locator('.track-row').first().waitFor();
    assert.equal(await page.locator('.track-row').count(), 12);
    await page.getByRole('button', { name: 'Tùy chọn playlist', exact: true }).click();
    await page.getByRole('button', { name: 'Chỉnh sửa thông tin', exact: true }).click();
    await page.getByRole('textbox', { name: 'Tên playlist', exact: true }).fill('Playlist Đạt đã chỉnh sửa');
    await page.getByRole('button', { name: 'Lưu thay đổi', exact: true }).click();
    await page.reload(); await page.getByRole('heading', { name: 'Playlist Đạt đã chỉnh sửa', exact: true }).waitFor();
    await page.getByRole('button', { name: 'Tùy chọn playlist', exact: true }).click();
    await page.getByRole('button', { name: 'Xóa playlist', exact: true }).click();
    await page.getByRole('dialog', { name: 'Xóa playlist?', exact: true }).getByRole('button', { name: 'Xóa playlist', exact: true }).click();
    await page.getByRole('heading', { name: 'Thư viện cá nhân', exact: true }).waitFor();
    await page.getByRole('button', { name: 'Bài hát đã thích (24)', exact: true }).click();
    await page.locator('.track-row').first().getByRole('button', { name: 'Bỏ thích', exact: true }).click();
    await page.reload(); await page.getByRole('button', { name: 'Bài hát đã thích (23)', exact: true }).waitFor();
    state = await readState(page); assert.equal(state.app.playlists.length, 3); assert.equal(state.player.likedSongIds.length, 23);
    report.checks.push('Folders filter correctly; playlist editing, deletion and unlike survive reload without re-seeding');
    await page.getByRole('navigation', { name: 'Hoạt động thư viện' }).getByRole('link', { name: 'Nghe gần đây', exact: true }).click();
    await page.getByText('Danh sách có lịch sử nghe mô phỏng', { exact: false }).waitFor();
    await page.locator('.track-row').first().waitFor();
    assert.equal(await page.locator('.track-row').count(), 15);
    await logout(page); await login(page, 'another@example.test');
    state = await readState(page); assert.equal(state.app.playlists.length, 0); assert.equal(state.app.libraryTestSeed, null); assert.equal(state.player.likedSongIds.length, 0);
    await logout(page); await login(page, email);
    await page.getByRole('button', { name: 'Bài hát đã thích (23)', exact: true }).waitFor();
    state = await readState(page); assert.equal(state.app.playlists.length, 3); assert.equal(state.player.likedSongIds.length, 23);
    report.checks.push('Guest and other email do not receive test data; returning to target restores edits');
    await page.setViewportSize({ width: 390, height: 844 });
    await page.getByRole('button', { name: 'Chuyển sang giao diện sáng', exact: true }).click();
    await page.screenshot({ path: path.join(output, 'library-light-mobile.png') });
    assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1 && document.querySelector('main').scrollWidth <= document.querySelector('main').clientWidth + 1));
    await context.close();
    const existing = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
    await existing.addInitScript(({ workspace, library, email }) => {
      if (!localStorage.getItem(workspace)) {
        localStorage.setItem(workspace, JSON.stringify({ version: 2, state: { session: { id: 'me', email, demo: true }, profile: { name: 'Đạt', bio: '', avatar: '/images/catalog-placeholder.svg' }, playlists: [{ id: 'existing_playlist', title: 'Playlist đang có', owned: true, songIds: [], coverUrl: '/images/catalog-placeholder.svg' }] } }));
        localStorage.setItem(library, JSON.stringify({ version: 2, state: { likedSongIds: ['existing_like'], followedArtistIds: [] } }));
      }
    }, { workspace, library, email });
    const existingPage = await existing.newPage(); existingPage.on('pageerror', error => report.errors.push(error.message));
    await existingPage.goto(origin + '/library');
    await existingPage.getByText('Đã thêm dữ liệu kiểm thử', { exact: false }).waitFor();
    state = await readState(existingPage); assert.equal(state.app.playlists.length, 5); assert.equal(state.player.likedSongIds.length, 25);
    assert(state.app.playlists.some(p => p.id === 'existing_playlist')); assert(state.player.likedSongIds.includes('existing_like'));
    await existingPage.reload(); await existingPage.getByText('Đã thêm dữ liệu kiểm thử', { exact: false }).waitFor();
    state = await readState(existingPage); assert.equal(state.app.playlists.length, 5);
    report.checks.push('An already signed-in version-2 session seeds automatically and preserves its existing playlist and likes');
    assert.deepEqual(report.errors, []); report.complete = true;
    console.log(JSON.stringify(report, null, 2));
  } finally {
    fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify(report, null, 2));
    await browser?.close(); server?.kill();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
