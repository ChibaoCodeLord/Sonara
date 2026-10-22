import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';

const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const outputDir = 'e:\\HOCKY7\\PBL6\\SORANA-CODE\\Sonara\\screenshots';

if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function run() {
  console.log('🚀 Khởi chạy Chrome headless...');
  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-web-security',
      '--disable-gpu',
      '--window-size=412,915',
    ],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 412, height: 915, deviceScaleFactor: 2 });

  console.log('🌐 Đang tải trang chủ Flutter Web...');
  await page.goto('http://localhost:8080/#/', {
    waitUntil: 'domcontentloaded',
    timeout: 45000,
  });

  // Chờ Flutter Web nạp xong hoàn toàn JS bundle và canvas
  console.log('⏳ Đợi Flutter Web nạp xong hoàn toàn (22s)...');
  await sleep(22000);

  // 1. Chụp Tab 0: Khám Phá (Home)
  console.log('📸 1/8 Chụp Màn hình Khám phá (Home)...');
  await page.screenshot({
    path: path.join(outputDir, '01_kham_pha_home.png'),
  });

  // 2. Chuyển sang Tab 1: Thư Viện (Library)
  console.log('👆 Click Tab Thư viện (Library)...');
  await page.mouse.click(123, 875);
  await sleep(2000);
  console.log('📸 2/8 Chụp Màn hình Thư viện (Library)...');
  await page.screenshot({
    path: path.join(outputDir, '02_thu_vien_library.png'),
  });

  // 3. Chuyển sang Tab 2: Xếp Hạng (Charts)
  console.log('👆 Click Tab Xếp hạng (Charts)...');
  await page.mouse.click(288, 875);
  await sleep(2000);
  console.log('📸 3/8 Chụp Màn hình Bảng xếp hạng (Charts)...');
  await page.screenshot({
    path: path.join(outputDir, '03_bang_xep_hang_charts.png'),
  });

  // 4. Chuyển sang Tab 3: Hồ Sơ (Profile)
  console.log('👆 Click Tab Hồ sơ (Profile)...');
  await page.mouse.click(370, 875);
  await sleep(2000);
  console.log('📸 4/8 Chụp Màn hình Hồ sơ (Profile)...');
  await page.screenshot({
    path: path.join(outputDir, '04_ho_so_profile.png'),
  });

  // 5. Chụp Màn hình Thu Âm AI Hum-to-Search (Bấm nút tròn AI HUM trung tâm)
  console.log('👆 Click nút tròn đỏ trung tâm AI HUM...');
  await page.mouse.click(206, 855);
  await sleep(2500);
  console.log('📸 5/8 Chụp Màn hình Thu âm AI Hum-to-Search...');
  await page.screenshot({
    path: path.join(outputDir, '05_thu_am_ai_hum.png'),
  });

  // 6. Nhấn vào Mic trung tâm (206, 260) để kích hoạt phân tích AI sang Hum Result
  console.log('👆 Nhấn Mic trung tâm để phân tích AI...');
  await page.mouse.click(206, 260);
  await sleep(4000);
  console.log('📸 6/8 Chụp Màn hình Kết quả nhận diện (Hum Result)...');
  await page.screenshot({
    path: path.join(outputDir, '06_ket_qua_nhan_dien_hum.png'),
  });

  // 7. Nhấn nút "Nghe bản đầy đủ" hoặc mở /now-playing
  console.log('🌐 Mở màn hình Now Playing...');
  await page.goto('http://localhost:8080/#/now-playing', {
    waitUntil: 'domcontentloaded',
    timeout: 30000,
  });
  await sleep(2500);
  console.log('📸 7/8 Chụp Màn hình Trình phát Now Playing...');
  await page.screenshot({
    path: path.join(outputDir, '07_trinh_phat_now_playing.png'),
  });

  // 8. Chụp Màn hình Chi Tiết Playlist
  console.log('🌐 Mở màn hình Chi tiết Playlist...');
  await page.goto('http://localhost:8080/#/playlist-detail', {
    waitUntil: 'domcontentloaded',
    timeout: 30000,
  });
  await sleep(2500);
  console.log('📸 8/8 Chụp Màn hình Chi tiết Playlist...');
  await page.screenshot({
    path: path.join(outputDir, '08_chi_tiet_playlist.png'),
  });

  console.log('🎉 Hoàn tất chụp thành công toàn bộ 8 màn hình hoàn hảo!');
  await browser.close();
}

run().catch((err) => {
  console.error('❌ Lỗi:', err);
  process.exit(1);
});
