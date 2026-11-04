const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const output = process.env.UI_SCREENS_OUTPUT || path.resolve('ui-review-artifacts/screens');
fs.mkdirSync(output, { recursive:true });
const server = spawn(process.execPath, ['node_modules/vite/bin/vite.js','preview','--host','127.0.0.1','--port','5201','--strictPort'], { stdio:'pipe',windowsHide:true });
const origin = 'http://127.0.0.1:5201';
const report = { layouts:[], flows:[], errors:[], stage:'startup' };
server.stderr.on('data',chunk=>process.stderr.write(chunk));
let page;
async function go(route) { report.stage = route; await page.goto(origin+route,{waitUntil:'domcontentloaded'}); await page.locator('h1, .ui-empty h2').first().waitFor(); }
async function check(condition, label) { assert(condition,label); report.flows.push(label); }
async function fillLabel(label,value) { await page.getByLabel(label,{exact:true}).fill(value); }
(async () => {
  let browser;
  try {
    await new Promise((resolve,reject) => { const timer=setTimeout(()=>reject(new Error('Vite startup timed out')),15000); server.stdout.on('data',data=>{if(data.toString().includes('Local:')){clearTimeout(timer);resolve();}});server.on('error',reject);server.on('exit',code=>reject(new Error(`Vite exited ${code}`))); });
    browser = await chromium.launch({headless:true,channel:process.env.UI_BROWSER || 'chrome'});
    const readyResponse=await fetch(origin);assert(readyResponse.ok,'Vite HTTP server is ready');console.log('Vite HTTP ready');
    const freshPage = async () => {
      if (page) await page.close();
      page = await browser.newPage();
      page.on('pageerror',error=>report.errors.push(error.message));
      page.on('crash',()=>report.errors.push('Browser renderer crashed'));
      await page.addInitScript(()=>{if(navigator.mediaDevices)navigator.mediaDevices.getUserMedia=async()=>{throw new DOMException('Denied by UI test','NotAllowedError');};});
    };
    await freshPage();
    const routes = ['/', '/charts','/library','/search?q=Sonara','/profile','/activity','/import','/youtube','/youtube?region=VN','/youtube?region=INTL','/playlist/playlist_youtube_vietnam','/playlist/playlist_youtube_international','/track/yt_FN7ALfpGxiI','/track/yt_Llw9Q6akRo4','/artist/artist_vu','/playlist/playlist_ai_mix_01','/playlist/playlist_liked_songs','/album/album_bau_troi_moi','/track/song_bau_troi_moi','/browse','/category/indie','/collection/mixes','/collection/albums','/collection/artists','/collection/recommended','/history','/notifications','/user/sonara','/user/me','/settings','/settings?tab=playback','/settings?tab=billing','/premium','/checkout?plan=individual','/checkout/result?status=failed&plan=individual','/podcasts','/show/cham-mot-nhip','/episode/ep-lang-nghe','/help','/legal/privacy','/welcome','/login','/signup','/forgot-password','/reset-password','/missing-page'];
    const sizes = process.env.UI_QUICK ? [[375,812],[1366,600]] : [[1440,900],[1366,600],[1024,768],[768,1024],[375,812],[320,568],[812,375]];
    for(const [width,height] of (process.env.UI_FLOWS_ONLY ? [] : sizes)) {
      await freshPage();
      await page.setViewportSize({width,height});
      for(const route of routes) {
        await go(route);
        const layout=await page.evaluate(()=>{
          const main=document.querySelector('main'),footer=document.querySelector('.bottom-player'),auth=document.querySelector('.ui-auth');
          return {width:innerWidth,height:innerHeight,documentWidth:document.documentElement.scrollWidth,mainWidth:main?.clientWidth,mainScrollWidth:main?.scrollWidth,footerWidth:footer?.clientWidth,footerScrollWidth:footer?.scrollWidth,mainBottom:main?.getBoundingClientRect().bottom,footerTop:footer?.getBoundingClientRect().top,footerBottom:footer?.getBoundingClientRect().bottom,authWidth:auth?.clientWidth,authScrollWidth:auth?.scrollWidth};
        });
        assert(layout.documentWidth<=width+1,`Document overflow ${width} ${route} ${JSON.stringify(layout)}`);
        if(layout.mainWidth){assert(layout.mainScrollWidth<=layout.mainWidth+1,`Main overflow ${width} ${route} ${JSON.stringify(layout)}`);assert(layout.footerScrollWidth<=layout.footerWidth+1,`Player overflow ${width} ${route}`);assert(Math.abs(layout.mainBottom-layout.footerTop)<=1,`Player overlaps ${route}`);assert(Math.abs(layout.footerBottom-height)<=1,`Player outside viewport ${route}`);}
        if(layout.authWidth)assert(layout.authScrollWidth<=layout.authWidth+1,`Auth overflow ${width} ${route}`);
        report.layouts.push({route,...layout});
        if([1440,375].includes(width)&&['/library','/premium','/login','/album/album_bau_troi_moi','/browse','/show/cham-mot-nhip'].includes(route))await page.screenshot({path:path.join(output,`${route.split('?')[0].replaceAll('/','-').slice(1)}-${width}.png`)});
      }
      console.log(`Layout passed: ${width}x${height}, ${routes.length} routes`);
    }
    await freshPage();
    await page.setViewportSize({width:1440,height:900});
    await go('/library');
    await page.getByRole('button',{name:'Tạo playlist',exact:true}).click();
    await page.getByRole('dialog',{name:'Mang âm nhạc theo bạn'}).waitFor();
    await check(true,'Guest create playlist opens login prompt');
    await page.keyboard.press('Escape');
    await go('/signup');
    await fillLabel('Bạn muốn được gọi là gì?','Sonara Tester');await fillLabel('Địa chỉ email','tester@example.test');await fillLabel('Mật khẩu (mẫu)','demo-test-123');
    await page.getByRole('checkbox').check();await page.getByRole('button',{name:'Tạo tài khoản trải nghiệm',exact:true}).click();
    await page.waitForURL(origin+'/');
    await check((await page.evaluate(()=>JSON.parse(localStorage.getItem('sonara-workspace-v1')).state.session.demo))===true,'Demo signup creates local session without storing password');
    assert(!(await page.evaluate(()=>localStorage.getItem('sonara-workspace-v1'))).includes('demo-test-123'));
    await go('/library');await page.getByRole('button',{name:'Tạo playlist',exact:true}).click();
    await fillLabel('Tên playlist','Chiều bình yên');await fillLabel('Mô tả','Một tuyển tập từ giao diện thử nghiệm.');await page.getByRole('dialog').getByRole('button',{name:'Tạo playlist',exact:true}).click();
    await page.waitForURL(/playlist\/playlist_/);const playlistUrl=page.url();
    await page.getByRole('heading',{name:'Chiều bình yên',exact:true}).waitFor();
    await page.getByRole('button',{name:'Thêm bài hát',exact:true}).click();
    await page.getByRole('button',{name:'Thêm Bầu Trời Mới',exact:true}).click();await page.getByRole('button',{name:'Thêm Từng Quen',exact:true}).click();await page.keyboard.press('Escape');
    await check(await page.locator('main .track-row').count()===2,'Create playlist and add two tracks');
    await page.getByRole('button',{name:'Đổi thứ tự',exact:true}).click();await page.getByRole('button',{name:'Chuyển Từng Quen lên',exact:true}).click();await page.getByRole('button',{name:'Xong',exact:true}).click();
    assert((await page.locator('main .track-row').first().innerText()).includes('Từng Quen'));
    await page.getByRole('button',{name:'Tùy chọn playlist',exact:true}).click();await page.getByRole('button',{name:'Chỉnh sửa thông tin',exact:true}).click();await fillLabel('Tên playlist','Những ngày bình yên');await page.getByRole('button',{name:'Lưu thay đổi',exact:true}).click();
    await page.reload();await page.getByRole('heading',{name:'Những ngày bình yên',exact:true}).waitFor();
    await check((await page.locator('main .track-row').first().innerText()).includes('Từng Quen'),'Playlist edits and ordering persist after reload');
    await page.getByRole('button',{name:'Tùy chọn playlist',exact:true}).click();await page.getByRole('button',{name:'Chuyển thành công khai',exact:true}).click();
    await go('/user/me');await page.locator('main').getByRole('link',{name:/Những ngày bình yên/}).waitFor();
    await check(true,'Playlist privacy updates public profile');
    await go('/library');await page.getByRole('button',{name:'Tạo thư mục',exact:true}).click();await fillLabel('Tên thư mục','Cuối tuần');await page.getByRole('dialog').getByRole('button',{name:'Tạo thư mục',exact:true}).click();
    await page.goto(playlistUrl);await page.getByRole('button',{name:'Tùy chọn playlist',exact:true}).click();await page.getByLabel('Thư mục',{exact:true}).selectOption({label:'Cuối tuần'});await page.keyboard.press('Escape');
    await go('/library');await page.getByRole('button',{name:'Cuối tuần',exact:true}).click();await page.locator('main').getByRole('link',{name:/Những ngày bình yên/}).waitFor();
    await check(true,'Create folder and organize playlist');
    await go('/album/album_bau_troi_moi');await page.getByRole('button',{name:'Lưu album',exact:true}).click();
    await go('/library');await page.getByRole('button',{name:'Album',exact:true}).click();assert(await page.locator('main .ui-content-card').count()===1);
    await check(true,'Saved album appears in library');
    await go('/search?q=Sonara');await page.getByRole('button',{name:'Playlist',exact:true}).click();assert(await page.getByRole('region',{name:'Kết quả playlist'}).count()===1);assert(await page.getByRole('region',{name:'Kết quả nghệ sĩ'}).count()===0);
    await check(true,'Search filters album, playlist and other result types');
    await go('/track/song_bau_troi_moi');await page.getByRole('button',{name:'Thao tác bài hát',exact:true}).click();await page.getByRole('button',{name:'Thêm vào playlist',exact:true}).click();await page.getByRole('button',{name:/Những ngày bình yên/}).click();
    await page.getByRole('button',{name:'Mở menu tài khoản',exact:true}).click();await page.getByRole('link',{name:'Hồ sơ của tôi',exact:true}).click();await page.getByRole('button',{name:'Chỉnh sửa hồ sơ',exact:true}).click();await fillLabel('Tên hiển thị','Người nghe Sonara');await page.getByRole('button',{name:'Lưu hồ sơ',exact:true}).click();await page.getByRole('heading',{name:'Xin chào, Người nghe Sonara',exact:true}).waitFor();
    await check(true,'Song menu and profile editor are connected');
    await go('/settings?tab=notifications');const toggle=page.getByRole('switch',{name:'Nhận email cập nhật'});await toggle.click();await page.reload();assert(await toggle.getAttribute('aria-checked')==='true');
    await check(true,'Settings persist after reload');
    await go('/checkout?plan=individual');await page.getByLabel('Kết quả muốn xem',{exact:true}).selectOption('failed');await page.getByRole('checkbox').check();await page.getByRole('button',{name:'Mô phỏng thanh toán'}).click();await page.getByRole('heading',{name:'Giao dịch mẫu chưa thành công'}).waitFor();await page.getByRole('link',{name:'Thử lại',exact:true}).click();await page.getByRole('checkbox').check();await page.getByRole('button',{name:'Mô phỏng thanh toán'}).click();await page.getByRole('heading',{name:'Đã hoàn tất bản xem trước'}).waitFor();
    await check(true,'Checkout failure, retry and success are demo-only');
    await go('/show/cham-mot-nhip');await page.getByRole('button',{name:'Theo dõi podcast',exact:true}).click();await go('/episode/ep-lang-nghe');await page.getByRole('button',{name:'Lưu tập',exact:true}).click();await page.getByRole('slider',{name:'Tiến trình podcast mô phỏng'}).fill('120');await page.reload();assert(await page.getByRole('slider',{name:'Tiến trình podcast mô phỏng'}).inputValue()==='120');
    await check(true,'Follow podcast, save episode and resume progress');
    await go('/');await page.getByTitle('Kết nối thiết bị',{exact:true}).click();await page.getByRole('button',{name:'Tìm thiết bị khác',exact:true}).click();await page.getByRole('heading',{name:'Chưa tìm thấy thiết bị'}).waitFor();await page.keyboard.press('Escape');
    await page.getByTitle('Hàng đợi phát nhạc',{exact:true}).click();await page.getByRole('button',{name:'Xóa hàng đợi',exact:true}).click();await page.getByRole('dialog',{name:'Xóa hàng đợi?',exact:true}).getByRole('button',{name:'Xóa hàng đợi',exact:true}).click();await page.keyboard.press('Escape');
    await check(true,'Device empty state and queue clear confirmation');
    await page.getByRole('button',{name:'Thử tìm kiếm ngay',exact:true}).click();await page.getByRole('button',{name:'Cho phép micro & bắt đầu',exact:true}).click();await page.getByRole('heading',{name:'Quyền micro chưa được cho phép'}).waitFor();await page.getByRole('button',{name:'Xem kết quả minh họa',exact:true}).click();await page.getByText('Đã tìm thấy 3 bài hát tương đồng').waitFor();
    await page.getByRole('button',{name:'Không phải bài này',exact:true}).click();await page.getByRole('heading',{name:'Chưa tìm được bài phù hợp'}).waitFor();await page.keyboard.press('Escape');
    await check(true,'Hum permission denied, demo result and no-match states');
    await page.evaluate(()=>{
      navigator.mediaDevices.getUserMedia=async()=>({getTracks:()=>[{stop(){}}]});
      window.AudioContext=class { constructor(){this.state='running';} createAnalyser(){return {frequencyBinCount:32,getByteFrequencyData:data=>data.fill(0)};} createMediaStreamSource(){return {connect(){}};} close(){this.state='closed';return Promise.resolve();} };
    });
    await page.getByRole('button',{name:'Thử tìm kiếm ngay',exact:true}).click();await page.getByRole('button',{name:'Cho phép micro & bắt đầu',exact:true}).click();await page.getByText('Micro trực tiếp',{exact:true}).waitFor();await page.getByRole('button',{name:'Dừng & Phân tích ngay',exact:true}).click();await page.getByRole('heading',{name:'Chưa nghe rõ giai điệu'}).waitFor();await page.keyboard.press('Escape');
    await check(true,'Silent microphone leads to no-sound recovery instead of a false match');
    await go('/forgot-password');await fillLabel('Địa chỉ email','tester@example.test');await page.getByRole('button',{name:'Xem trước khôi phục'}).click();await page.getByRole('link',{name:'Xem bước đặt mật khẩu'}).click();await fillLabel('Mật khẩu mới (mẫu)','new-demo-123');await page.getByRole('button',{name:'Hoàn tất bước mẫu'}).click();await page.getByRole('heading',{name:'Đã hoàn tất bước đặt lại mẫu'}).waitFor();
    await check(true,'Password recovery and reset show truthful demo states');
    await go('/profile');await page.getByRole('button',{name:'Đăng xuất tài khoản',exact:true}).click();await page.getByRole('dialog').getByRole('button',{name:'Đăng xuất',exact:true}).click();await page.waitForURL(origin+'/welcome');
    await check(true,'Account logout returns to welcome');
    await page.setViewportSize({width:375,height:812});await go('/');await page.getByRole('button',{name:'Mở menu',exact:true}).click();await page.locator('#main-navigation').getByRole('link',{name:'Tìm kiếm',exact:true}).click();await page.waitForURL(origin+'/search');assert(await page.locator('.sidebar-open').count()===0);
    await page.getByRole('link',{name:'Khám phá thể loại & tâm trạng',exact:true}).click();await page.waitForURL(origin+'/browse');await check(true,'Compact mobile navigation reaches secondary screens through Search');
    await go('/library');await page.getByRole('link',{name:'Nhập nhạc',exact:true}).click();await page.waitForURL(origin+'/import');await page.getByRole('heading',{name:'YouTube → MP3',exact:true}).waitFor();
    await go('/library');await page.getByRole('navigation',{name:'Hoạt động thư viện',exact:true}).getByRole('link',{name:'Chuỗi nghe nhạc',exact:true}).click();await page.waitForURL(origin+'/activity');
    await go('/library');await page.getByRole('navigation',{name:'Hoạt động thư viện',exact:true}).getByRole('link',{name:'Nghe gần đây',exact:true}).click();await page.waitForURL(origin+'/history');
    await check(true,'Library provides import, listening streak and history without sidebar shortcuts');
    await go('/search');await page.getByRole('link',{name:'Khám phá podcast',exact:true}).click();await page.waitForURL(origin+'/podcasts');
    await go('/search');await page.getByRole('link',{name:'Bảng xếp hạng',exact:true}).click();await page.waitForURL(origin+'/charts');await check(true,'Search provides podcast and charts discovery');
    await page.setViewportSize({width:812,height:375});await page.getByRole('button',{name:'Mở menu',exact:true}).click();
    const likedBounds=await page.locator('#main-navigation').getByRole('link',{name:'Bài hát yêu thích',exact:true}).boundingBox();
    const sidebarBounds=await page.locator('#main-navigation').boundingBox();assert(likedBounds.y+likedBounds.height<=sidebarBounds.y+sidebarBounds.height+1,'Liked playlist remains reachable in landscape menu');
    await page.screenshot({path:path.join(output,'sidebar-landscape.png')});await page.keyboard.press('Escape');await check(true,'Compact sidebar keeps playlist access on short landscape screens');
    await page.setViewportSize({width:320,height:568});await go('/');await page.getByRole('button',{name:'Thử tìm kiếm ngay',exact:true}).click();await page.getByRole('button',{name:'Xem kết quả minh họa',exact:true}).click();
    const humSize=await page.getByRole('dialog',{name:'Tìm bằng giai điệu',exact:true}).evaluate(el=>({width:el.clientWidth,scroll:el.scrollWidth,top:el.getBoundingClientRect().top,bottom:el.getBoundingClientRect().bottom}));
    assert(humSize.scroll<=humSize.width+1,`Hum overflow on small phone: ${JSON.stringify(humSize)}`);assert(humSize.top>=0&&humSize.bottom<=569);
    await page.screenshot({path:path.join(output,'hum-320.png')});await page.keyboard.press('Escape');
    await check(true,'Small phone Hum results remain inside modal bounds');
    assert.deepEqual(report.errors,[],'No browser runtime errors');report.passed=true;console.log(JSON.stringify({layouts:report.layouts.length,flows:report.flows,errors:report.errors},null,2));
  } finally { if(page&&!report.passed){report.failedUrl=page.url();report.failedBody=await page.locator('body').innerText({timeout:2000}).catch(error=>String(error));await page.screenshot({path:path.join(output,'failure.png'),timeout:5000}).catch(()=>{});}fs.writeFileSync(path.join(output,'screen-results.json'),JSON.stringify(report,null,2));await browser?.close();server.kill(); }
})().catch(error=>{console.error(error);process.exitCode=1;});
