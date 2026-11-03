const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const output = process.env.UI_CATEGORY_OUTPUT || path.resolve('ui-review-artifacts/categories');
const origin = 'http://127.0.0.1:5221';
fs.mkdirSync(output, { recursive: true });
const server = spawn(process.execPath, ['node_modules/vite/bin/vite.js', '--host', '127.0.0.1', '--port', '5221', '--strictPort'], { windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
const report = { errors: [], layouts: [], checks: [], catalogFixture: true };
let browser;
(async () => {
  try {
    await new Promise((resolve, reject) => { const timer=setTimeout(()=>reject(Error('Vite timeout')),20000);server.on('error',reject);server.stdout.on('data',data=>{if(String(data).includes('Local:')){clearTimeout(timer);resolve();}}); });
    browser = await chromium.launch({ channel: 'chrome', headless: true });
    const context=await browser.newContext({viewport:{width:1440,height:900},colorScheme:'dark'});
    await context.route('**/api/v1/catalog/**',route=>route.fulfill({json:{data:{dataset:'category-ui-fixture',tracks:[],pagination:{total:0,totalPages:0}}}}));
    const page=await context.newPage();page.on('pageerror',e=>report.errors.push(e.message));
    for(const mode of ['dark','light']) {
      await page.goto(origin+'/search',{waitUntil:'domcontentloaded'});
      const label=mode==='light'?'Chuyển sang giao diện sáng':'Chuyển sang giao diện tối';
      if(await page.getByRole('button',{name:label,exact:true}).count())await page.getByRole('button',{name:label,exact:true}).click();
      for(const [width,height] of [[1920,1080],[1440,900],[768,1024],[375,812],[320,568]]) {
        await page.setViewportSize({width,height});
        for(const route of ['/search','/browse']) {
          await page.goto(origin+route,{waitUntil:'domcontentloaded'});await page.locator('.genre-card').first().waitFor();
          assert.equal(await page.locator('.genre-card').count(),6);
          for(const card of await page.locator('.genre-card').all()) {
            await card.scrollIntoViewIfNeeded();await card.locator('img').evaluate(img=>img.decode());
            assert(await card.locator('img').evaluate(img=>img.naturalWidth>0&&getComputedStyle(img).visibility!=='hidden'));
            const bounds=await card.evaluate(el=>{const title=el.querySelector('.genre-card-title').getBoundingClientRect(), box=el.getBoundingClientRect();return {title:title.bottom-box.top,height:box.height,scroll:el.scrollWidth,width:el.clientWidth,color:getComputedStyle(el.querySelector('.genre-card-title')).color};});
            assert(bounds.title<=bounds.height&&bounds.scroll<=bounds.width+1);assert.equal(bounds.color,'rgb(255, 255, 255)');
          }
          await page.locator('.genre-card').first().scrollIntoViewIfNeeded();
          const layout=await page.evaluate(()=>({doc:document.documentElement.scrollWidth,viewport:innerWidth,main:document.querySelector('main').clientWidth,scroll:document.querySelector('main').scrollWidth}));
          assert(layout.doc<=width+1&&layout.scroll<=layout.main+1);report.layouts.push({mode,route,...layout});
          if([1920,375].includes(width)&&route==='/search'){await page.locator('main').evaluate(el=>el.scrollTo(0,0));await page.screenshot({path:path.join(output,`${mode}-${width}.png`)});}
        }
      }
    }
    const searches=[['Tâm trạng & Cảm xúc','Ballad'],['Thư giãn & Indie','Indie'],['Tập luyện','Rap'],['Quán Cafe Cuối Tuần','Acoustic'],['V-Pop Mới Nhất','V-Pop'],['Indie Việt & Mộc','Indie']];
    for(const [name,query] of searches){await page.goto(origin+'/search',{waitUntil:'domcontentloaded'});await page.getByRole('button',{name,exact:true}).click();assert.equal(new URL(page.url()).searchParams.get('q'),query);}
    report.checks.push('All six photographic search categories retain their original search action');
    await page.goto(origin+'/browse',{waitUntil:'domcontentloaded'});await page.getByRole('link',{name:'Acoustic',exact:true}).click();await page.getByRole('heading',{name:'Acoustic',exact:true}).waitFor();
    report.checks.push('Browse category links still open their genre page');
    await page.goto(origin+'/search',{waitUntil:'domcontentloaded'});await page.getByRole('button',{name:'Tập luyện',exact:true}).focus();await page.keyboard.press('Enter');assert.equal(new URL(page.url()).searchParams.get('q'),'Rap');
    report.checks.push('Cards remain keyboard operable');
    await page.route('**/images/genres/**',route=>route.abort());await page.goto(origin+'/search',{waitUntil:'domcontentloaded'});await page.locator('.genre-card').first().waitFor();
    assert.equal(await page.getByRole('button',{name:'Tâm trạng & Cảm xúc',exact:true}).count(),1);await page.getByRole('button',{name:'Tâm trạng & Cảm xúc',exact:true}).click();
    assert.equal(new URL(page.url()).searchParams.get('q'),'Ballad');report.checks.push('Image failure retains readable card labels and actions');
    assert.deepEqual(report.errors,[]);report.complete=true;console.log(JSON.stringify({layouts:report.layouts.length,checks:report.checks,errors:report.errors}));
  } finally {fs.writeFileSync(path.join(output,'results.json'),JSON.stringify(report,null,2));await browser?.close();server.kill();}
})().catch(e=>{console.error(e);process.exitCode=1;});
