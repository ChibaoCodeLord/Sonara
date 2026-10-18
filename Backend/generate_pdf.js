import fs from 'fs';
import path from 'path';
import puppeteer from 'puppeteer-core';
import { marked } from 'marked';

const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const readmePath = 'e:\\HOCKY7\\PBL6\\SORANA-CODE\\Sonara\\Frontend\\README.md';
const outputPdfPath1 = 'e:\\HOCKY7\\PBL6\\SORANA-CODE\\Sonara\\Sonara_Screens_and_Features_Documentation.pdf';
const outputPdfPath2 = 'e:\\HOCKY7\\PBL6\\SORANA-CODE\\Sonara\\Frontend\\Sonara_Screens_and_Features_Documentation.pdf';

async function generatePdf() {
  console.log('📖 Đang đọc tệp Frontend/README.md...');
  const markdownContent = fs.readFileSync(readmePath, 'utf-8');

  console.log('⚙️ Đang chuyển đổi Markdown sang HTML...');
  const rawHtml = marked.parse(markdownContent);

  const fullHtml = `
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Sonara - Frontend Documentation</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    @page {
      size: A4;
      margin: 18mm 15mm 18mm 15mm;
      @bottom-right {
        content: counter(page) " / " counter(pages);
      }
    }

    * {
      box-sizing: border-box;
      -webkit-print-color-adjust: exact !important;
      print-color-adjust: exact !important;
    }

    body {
      font-family: 'Plus Jakarta Sans', 'Segoe UI', -apple-system, sans-serif;
      font-size: 10pt;
      line-height: 1.6;
      color: #1c1c1e;
      background-color: #ffffff;
      margin: 0;
      padding: 0;
    }

    h1, h2, h3, h4, h5, h6 {
      color: #1a1a1a;
      font-weight: 700;
      page-break-after: avoid;
      break-after: avoid;
    }

    h1 {
      font-size: 20pt;
      color: #9A1B2F;
      border-bottom: 2.5px solid #9A1B2F;
      padding-bottom: 6px;
      margin-top: 0;
      margin-bottom: 14px;
    }

    h2 {
      font-size: 14pt;
      color: #9A1B2F;
      border-bottom: 1px solid #e2d9d9;
      padding-bottom: 4px;
      margin-top: 22px;
      margin-bottom: 10px;
    }

    h3 {
      font-size: 11.5pt;
      color: #2c2c2e;
      margin-top: 16px;
      margin-bottom: 8px;
    }

    h4 {
      font-size: 10.5pt;
      color: #48484a;
      margin-top: 12px;
      margin-bottom: 6px;
    }

    p {
      margin: 6px 0;
      text-align: justify;
    }

    blockquote {
      border-left: 4px solid #9A1B2F;
      background-color: #faf4f5;
      color: #4a151b;
      margin: 12px 0;
      padding: 8px 14px;
      border-radius: 0 6px 6px 0;
      font-style: italic;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin: 12px 0;
      font-size: 8.5pt;
      page-break-inside: avoid;
      break-inside: avoid;
    }

    th {
      background-color: #9A1B2F;
      color: #ffffff;
      font-weight: 600;
      text-align: left;
      padding: 7px 9px;
      border: 1px solid #851627;
    }

    td {
      padding: 6px 9px;
      border: 1px solid #e5e5ea;
      vertical-align: top;
    }

    tr:nth-child(even) {
      background-color: #fbf9f9;
    }

    code {
      font-family: 'JetBrains Mono', Consolas, monospace;
      font-size: 8.5pt;
      background-color: #f2f2f7;
      color: #B3122E;
      padding: 2px 4px;
      border-radius: 4px;
    }

    pre {
      background-color: #1e1e24;
      color: #f4f4f4;
      padding: 10px 14px;
      border-radius: 6px;
      overflow-x: auto;
      font-size: 8pt;
      line-height: 1.45;
      margin: 10px 0;
      page-break-inside: avoid;
      break-inside: avoid;
    }

    pre code {
      background-color: transparent;
      color: inherit;
      padding: 0;
      border-radius: 0;
    }

    ul, ol {
      margin: 6px 0 6px 18px;
      padding: 0;
    }

    li {
      margin-bottom: 3px;
    }

    hr {
      border: 0;
      border-top: 1px dashed #d1d1d6;
      margin: 18px 0;
    }

    a {
      color: #9A1B2F;
      text-decoration: none;
    }

    .cover-badge {
      display: inline-block;
      background: #9A1B2F;
      color: white;
      font-size: 8.5pt;
      font-weight: 700;
      padding: 3px 10px;
      border-radius: 12px;
      margin-bottom: 8px;
    }
  </style>
</head>
<body>
  <div>
    <span class="cover-badge">SONARA SYSTEM SPECIFICATION</span>
    ${rawHtml}
  </div>
</body>
</html>
  `;

  console.log('🚀 Đang khởi chạy Chrome headless để xuất PDF...');
  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-gpu'],
  });

  const page = await browser.newPage();
  await page.setContent(fullHtml, { waitUntil: 'networkidle0' });

  console.log('📄 Đang kết xuất PDF khổ A4 với số trang tự động...');
  const pdfBuffer = await page.pdf({
    format: 'A4',
    printBackground: true,
    margin: {
      top: '20mm',
      bottom: '20mm',
      left: '15mm',
      right: '15mm',
    },
    displayHeaderFooter: true,
    headerTemplate: `
      <div style="font-size: 7.5pt; color: #8e8e93; width: 100%; padding: 0 15mm; display: flex; justify-content: space-between; font-family: sans-serif;">
        <span>Sonara Music Streaming & AI Hum-to-Search</span>
        <span>Tài Liệu Đặc Tả Frontend & Product Roadmap</span>
      </div>
    `,
    footerTemplate: `
      <div style="font-size: 7.5pt; color: #8e8e93; width: 100%; padding: 0 15mm; display: flex; justify-content: space-between; font-family: sans-serif;">
        <span>Trang <span class="pageNumber"></span> / <span class="totalPages"></span></span>
        <span>Bảo mật nội bộ • PBL6</span>
      </div>
    `,
  });

  fs.writeFileSync(outputPdfPath1, pdfBuffer);
  fs.writeFileSync(outputPdfPath2, pdfBuffer);

  await browser.close();
  console.log(`✅ Xuất PDF thành công!`);
  console.log(`1️⃣ File 1: ${outputPdfPath1}`);
  console.log(`2️⃣ File 2: ${outputPdfPath2}`);
}

generatePdf().catch((err) => {
  console.error('❌ Lỗi:', err);
  process.exit(1);
});
