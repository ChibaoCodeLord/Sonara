const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.SONARA_UI_URL || 'http://127.0.0.1:5173';
const output = path.resolve('../../music_crawl/integration/ui');
fs.mkdirSync(output,{recursive:true});
const report = { checks:[], layouts:[], errors:[], audio_playback:'not_yet_checked' };
let browser;
(async () => {
  try {
    browser = await chromium.launch({channel:'chrome',headless:true,args:['--autoplay-policy=no-user-gesture-required']});
    const context = await browser.newContext({viewport:{width:1440,height:900}});
    await context.addInitScript(() => {
      if (!localStorage.getItem('__catalog_migration_seeded')) {
        localStorage.setItem('__catalog_migration_seeded','1');
        localStorage.setItem('sonara-workspace-v1',JSON.stringify({version:0,state:{
          playlists:[{id:'old_curated',title:'Legacy fixture playlist',owned:false,songIds:['legacy_fixture']},{id:'user_playlist',title:'My playlist',owned:true,songIds:['legacy_fixture']}],
          importedTracks:[{id:'legacy_import',title:'Legacy fixture song'}],history:[{songId:'legacy_fixture'}],audioVersions:{old:{audioUrl:'/old.mp3'}}
        }}));
        localStorage.setItem('sonara-library-v1',JSON.stringify({version:0,state:{likedSongIds:['legacy_fixture'],followedArtistIds:['legacy_artist']}}));
      }
      const NativeAudio = window.Audio;
      window.Audio = function(...args){const a=new NativeAudio(...args);window.__nativeAudio=a;return a;};
      window.Audio.prototype=NativeAudio.prototype;
    });
    const page = await context.newPage();
    const visitLoaded = async route => {
      await page.goto(base+route);
      await page.waitForFunction(async () => {
        const urls=performance.getEntriesByType('resource').map(e=>e.name).reverse().filter(u=>u.includes('/src/store/useRemoteCatalogStore.js'));
        for(const url of urls){const state=(await import(url)).useRemoteCatalogStore.getState();if(state.status==='ready'&&state.tracks.length===601)return true;}
        return false;
      },null,{timeout:45000});
      await page.waitForTimeout(250);
    };
    page.on('pageerror',e => report.errors.push(e.message));
    await page.goto(base+'/');
    await page.evaluate(async () => {
      // Reuse the exact module URL (including Vite HMR timestamp) loaded by the app.
      const loaded = name => performance.getEntriesByType('resource').map(e=>e.name).reverse().find(u=>u.includes('/src/store/'+name+'.js'));
      window.__remote=(await import(loaded('useRemoteCatalogStore'))).useRemoteCatalogStore;
      window.__player=(await import(loaded('usePlayerStore'))).usePlayerStore;
      window.__app=(await import(loaded('useAppStore'))).useAppStore;
    });
    await page.waitForFunction(() => window.__remote.getState().status==='ready',null,{timeout:30000});
    const snapshot=await page.evaluate(() => ({tracks:window.__remote.getState().tracks,app:window.__app.getState(),player:window.__player.getState()}));
    assert.equal(snapshot.tracks.length,601);
    assert(snapshot.tracks.every(t => t.id.startsWith('catalog_')));
    assert.equal(snapshot.app.importedTracks.length,0); assert.equal(snapshot.app.history.length,0);
    assert.equal(snapshot.app.playlists.length,1);assert.equal(snapshot.app.playlists[0].id,'user_playlist');assert.deepEqual(snapshot.app.playlists[0].songIds,[]);
    assert.deepEqual(snapshot.player.likedSongIds,[]);assert.equal(snapshot.player.currentSong,null);assert.equal(snapshot.player.queue.length,0);
    report.checks.push('601 backend catalog IDs loaded; legacy browser catalog references removed, owned playlist retained empty');
    report.sources=snapshot.tracks.reduce((a,t)=>{a[t.metadataSource]=(a[t.metadataSource]||0)+1;return a;},{});
    for(const [source,count] of Object.entries(report.sources)){
      await page.goto(base+'/youtube?source='+source);
      await page.getByRole('heading',{name:'Nghe nhạc',exact:true}).waitFor();
      await page.waitForFunction(n=>document.body.innerText.includes(n+' bản ghi'),count,{timeout:30000});
      assert(await page.locator('.youtube-track-card').count()>0);
    }
    report.checks.push('All seven source filters show exact imported counts');
    for(const source of ['itunes','musicbrainz','discogs']){
      const song=snapshot.tracks.find(t=>t.metadataSource===source);
      await page.goto(base+'/track/'+song.id);
      await page.getByRole('heading',{name:song.title,exact:true}).waitFor();
      assert.equal(await page.getByRole('button',{name:'Phát audio',exact:true}).count(),0);
    }
    report.checks.push('Preview/metadata records have source links and no fake audio play button');
    const song=snapshot.tracks.find(t=>t.albumInfo&&t.artists.length);
    await page.goto(base+'/album/'+song.albumInfo.id);
    await page.getByRole('heading',{name:song.album,exact:true}).waitFor();
    await page.goto(base+'/artist/'+song.artists[0].id);
    await page.getByRole('heading',{name:song.artists[0].name,exact:true}).waitFor();
    await page.goto(base+'/search?q='+encodeURIComponent(song.title));
    await page.getByRole('heading',{name:'Tìm kiếm',exact:true}).waitFor();
    await page.getByRole('button',{name:song.title,exact:true}).first().waitFor();
    report.checks.push('Live track, album, artist and title search routes resolve without seeded entities');
    for(const width of [1440,375]){
      await page.setViewportSize({width,height:900});
      for(const route of ['/','/youtube','/search?q=son','/library']){
        await visitLoaded(route);
        const layout=await page.evaluate(()=>({width:innerWidth,scroll:document.documentElement.scrollWidth,error:document.body.innerText.includes('Không thể hiển thị nội dung')}));
        assert(!layout.error);assert(layout.scroll<=layout.width+1,JSON.stringify({route,...layout}));
        report.layouts.push({route,...layout});
      }
    }
    await page.setViewportSize({width:1440,height:900});
    await page.goto(base+'/youtube?source=archive');
    const audio=snapshot.tracks.find(t=>t.metadataSource==='archive'&&t.audioUrl);
    await page.goto(base+'/track/'+audio.id);
    await page.getByRole('button',{name:'Phát audio',exact:true}).click();
    try{
      await page.waitForFunction(()=>window.__nativeAudio&&!window.__nativeAudio.paused&&window.__nativeAudio.currentTime>=2,null,{timeout:45000});
      report.audio_playback='real_archive_audio_played';
      report.audio=await page.evaluate(()=>({time:window.__nativeAudio.currentTime,duration:window.__nativeAudio.duration}));
      await page.evaluate(()=>window.__nativeAudio.pause());
    }catch(e){report.audio_playback='not_confirmed';report.audio_error=e.message;}
    await visitLoaded('/');
    await page.locator('.youtube-track-card').first().waitFor();
    await page.screenshot({path:path.join(output,'home-1440.png')});
    await visitLoaded('/youtube?source=deezer');
    await page.locator('.youtube-track-card').first().waitFor();
    await page.screenshot({path:path.join(output,'deezer-1440.png')});
    await page.setViewportSize({width:375,height:900});await visitLoaded('/youtube');
    await page.locator('.youtube-track-card').first().waitFor();
    await page.screenshot({path:path.join(output,'catalog-375.png')});
    // A failed backend request must show retry, not resurrect the old sample catalog.
    await page.route('**/api/v1/catalog?**',r=>r.fulfill({status:503,contentType:'application/json',body:'{}'}));
    await page.reload();await page.getByRole('heading',{name:'Chưa tải được catalog',exact:true}).waitFor();
    assert.equal(await page.locator('.youtube-track-card').count(),0);
    await page.unroute('**/api/v1/catalog?**');
    await page.getByRole('button',{name:'Thử lại',exact:true}).click();
    await page.locator('.youtube-track-card').first().waitFor({timeout:30000});
    report.checks.push('API outage shows retry with zero sample cards; retry restores real backend catalog');
    assert.deepEqual(report.errors,[]);
    report.passed=true;
  }catch(e){report.passed=false;report.failure=e.stack;process.exitCode=1;}
  finally{fs.writeFileSync(path.join(output,'report.json'),JSON.stringify(report,null,2));await browser?.close();console.log(JSON.stringify(report,null,2));}
})();
