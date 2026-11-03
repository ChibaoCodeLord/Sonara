const assert=require('node:assert/strict');
const fs=require('node:fs');const path=require('node:path');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const base=process.env.SONARA_UI_URL||'http://127.0.0.1:5173';
const out=path.resolve('../../music_crawl/youtube_bulk/ui');fs.mkdirSync(out,{recursive:true});
const report={errors:[],checks:[]};let browser;
(async()=>{try{
  browser=await chromium.launch({channel:'chrome',headless:true,args:['--autoplay-policy=no-user-gesture-required']});
  const context=await browser.newContext({viewport:{width:1440,height:900}});
  await context.addInitScript(()=>{const Native=window.Audio;window.Audio=function(...args){const a=new Native(...args);window.__audio=a;return a;};window.Audio.prototype=Native.prototype;});
  const page=await context.newPage();page.on('pageerror',e=>report.errors.push(e.message));
  const all=[];let revision;
  for(let attempt=0;attempt<5;attempt++){
    all.length=0;let stable=true,snapshot;
    for(let p=1;p<=100;p++){
      const r=await page.request.get(base+`/api/v1/catalog?limit=100&page=${p}`+(snapshot?'&snapshot='+snapshot:''));assert(r.ok());const {data}=await r.json();
      if(p===1)revision=data.dataset;else if(revision!==data.dataset){stable=false;break;}
      snapshot=data.snapshot;
      all.push(...data.tracks);if(p>=data.pagination.totalPages)break;
    }
    if(stable)break;if(attempt===4)throw new Error('Catalog changes too rapidly for audit snapshot');
  }
  assert(all.length>=303);assert(all.every(t=>Boolean(t.audioUrl)&&t.playbackKind==='full'));
  if(process.env.SONARA_EXPECTED_TRACKS)assert.equal(all.length,Number(process.env.SONARA_EXPECTED_TRACKS));
  report.catalog_total=all.length;report.youtube_total=all.filter(t=>t.metadataSource==='youtube').length;report.dataset=revision;
  report.checks.push('Every displayed record has full audio; preview and metadata-only records are absent');
  const song=all.find(t=>t.metadataSource==='youtube');assert(song);
  const range=await page.request.get(base+song.audioUrl,{headers:{Range:'bytes=0-2047'}});assert.equal(range.status(),206);assert.equal((await range.body()).length,2048);
  await page.goto(base+'/track/'+song.id);await page.getByRole('button',{name:'Phát audio',exact:true}).click();
  await page.waitForFunction(()=>window.__audio&&!window.__audio.paused&&window.__audio.currentTime>=2,null,{timeout:30000});
  report.playback=await page.evaluate(()=>({time:window.__audio.currentTime,duration:window.__audio.duration,source:window.__audio.currentSrc}));
  await page.evaluate(()=>{window.__audio.currentTime=40;});await page.waitForFunction(()=>window.__audio.currentTime>=40);await page.evaluate(()=>window.__audio.pause());
  report.checks.push('Real local YouTube MP3 plays, seeks, pauses and supports HTTP Range');
  await page.goto(base+'/youtube?source=youtube');await page.getByRole('button',{name:'YouTube Audio',exact:true}).waitFor();await page.locator('.youtube-track-card').first().waitFor();
  await page.screenshot({path:path.join(out,'youtube-audio-1440.png')});
  for(const width of [1440,375]){await page.setViewportSize({width,height:900});const size=await page.evaluate(()=>({view:innerWidth,scroll:document.documentElement.scrollWidth}));assert(size.scroll<=size.view+1);}
  await page.screenshot({path:path.join(out,'youtube-audio-375.png')});
  assert.equal(await page.getByText('Có preview tại nguồn',{exact:true}).count(),1); // available filter, with no preview records
  await page.getByRole('button',{name:'Có preview tại nguồn',exact:true}).click();await page.getByRole('heading',{name:'Chưa có nội dung phù hợp',exact:true}).waitFor();
  report.checks.push('YouTube source cards render on desktop/mobile and preview filter returns empty');
  assert.deepEqual(report.errors,[]);report.passed=true;
}catch(e){report.passed=false;report.failure=e.stack;process.exitCode=1;}finally{fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2));await browser?.close();console.log(JSON.stringify(report,null,2));}})();
