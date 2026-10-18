import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';

const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const outputDir = 'e:\\HOCKY7\\PBL6\\SORANA-CODE\\Sonara\\screenshots';

if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

async function run() {
  console.log('Launching browser...');
  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-web-security']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 412, height: 915, deviceScaleFactor: 2 });

  console.log('Navigating to http://localhost:8080/#/ ...');
  await page.goto('http://localhost:8080/#/', { waitUntil: 'networkidle0', timeout: 30000 });
  
  // Wait for Flutter Web skia/html renderer
  await new Promise(r => setTimeout(r, 4000));

  const shotPath = path.join(outputDir, '01_kham_pha_home.png');
  await page.screenshot({ path: shotPath });
  console.log('Saved:', shotPath);

  await browser.close();
}

run().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
