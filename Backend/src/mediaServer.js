import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import jwt from 'jsonwebtoken';
import { MediaImports } from './services/mediaImport.service.js';
import { pathToFileURL } from 'node:url';

export function createMediaApp(service) {
  const app = express();
  const origins = (process.env.MEDIA_ORIGINS || 'http://localhost:5173,http://127.0.0.1:5173,http://localhost:4173,http://127.0.0.1:4173,http://localhost:5201,http://127.0.0.1:5201').split(',');
  app.use(helmet({ crossOriginResourcePolicy: false }));
  app.use(cors({ origin: (origin, done) => done(null, !origin || origins.includes(origin)), methods: ['GET', 'POST', 'DELETE'], allowedHeaders: ['Content-Type', 'Authorization', 'X-Sonara-Client'] }));
  app.use(express.json({ limit: '4kb' }));
  app.use((req, res, next) => {
    if (req.headers.origin && !origins.includes(req.headers.origin)) return res.status(403).json({ error: 'Nguồn truy cập không được phép.' });
    if (['POST', 'DELETE'].includes(req.method)) {
      if (req.get('X-Sonara-Client') !== 'website') return res.status(403).json({ error: 'Thiếu mã nhận diện ứng dụng.' });
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Yêu cầu xác thực tài khoản hợp lệ.' });
      }
      try {
        req.user = jwt.verify(authHeader.split(' ')[1], process.env.JWT_SECRET || 'sonara_secret_key_default');
      } catch {
        return res.status(401).json({ error: 'Token xác thực không hợp lệ hoặc đã hết hạn.' });
      }
    }
    next();
  });
  const wrap = fn => (req, res, next) => Promise.resolve(fn(req, res)).catch(next);
  app.get('/media-api/health', wrap(async (_req, res) => res.json(await service.health())));
  app.post('/media-api/jobs', wrap(async (req, res) => {
    if (typeof req.body.url !== 'string' || req.body.url.length > 2048) return res.status(400).json({ error: 'Liên kết không hợp lệ.' });
    try { res.status(202).json(await service.create(req.body.url)); }
    catch (error) { res.status(error.status || 400).json({ error: error.message }); }
  }));
  app.get('/media-api/jobs/:id', (req, res) => { const job = service.get(req.params.id); return job ? res.json(job) : res.status(404).json({ error: 'Không tìm thấy tác vụ. Tệp có thể đã bị xóa.' }); });
  app.delete('/media-api/jobs/:id', wrap(async (req, res) => res.status(await service.remove(req.params.id) ? 204 : 404).end()));
  app.get('/media-api/jobs/:id/audio', (req, res) => {
    if (service.get(req.params.id)?.status !== 'ready') return res.status(404).json({ error: 'Tệp âm thanh chưa sẵn sàng.' });
    res.type('audio/mpeg').sendFile(service.audioPath(req.params.id), error => { if (error && !res.headersSent) res.status(404).end(); });
  });
  app.use((error, _req, res, _next) => { console.error(error.message); res.status(error.status || 500).json({ error: 'Dịch vụ gặp lỗi. Hãy thử lại.' }); });
  return app;
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const service = new MediaImports();
  await service.init();
  const server = createMediaApp(service).listen(Number(process.env.MEDIA_PORT || 5001), '127.0.0.1', () => console.log('Sonara media: http://127.0.0.1:' + (process.env.MEDIA_PORT || 5001)));
  const stop = () => { for (const controller of service.controllers.values()) controller.abort(); server.close(); };
  process.on('SIGINT', stop); process.on('SIGTERM', stop);
}
