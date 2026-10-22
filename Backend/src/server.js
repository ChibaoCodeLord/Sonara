import app from './app.js';
import { ENV } from './config/env.js';
import { connectDB } from './config/db.js';

// Xử lý lỗi uncaughtException (lỗi đồng bộ chưa bắt)
process.on('uncaughtException', (err) => {
  console.error('[Uncaught Exception] Máy chủ gặp sự cố:', err.name, err.message);
  process.exit(1);
});

const startServer = async () => {
  // 1. Kết nối cơ sở dữ liệu MongoDB
  await connectDB();

  // 2. Lắng nghe cổng HTTP
  const server = app.listen(ENV.PORT, () => {
    console.log(`--------------------------------------------------`);
    console.log(` Sonara Music Backend Server is Running!`);
    console.log(` Port: ${ENV.PORT}`);
    console.log(` Mode: ${ENV.NODE_ENV}`);
    console.log(` Health check: http://localhost:${ENV.PORT}/api/v1/health`);
    console.log(`--------------------------------------------------`);
  });

  // Xử lý lỗi unhandledRejection (lỗi Promise bất đồng bộ chưa bắt)
  process.on('unhandledRejection', (err) => {
    console.error('[Unhandled Rejection] Đóng server an toàn:', err.name, err.message);
    server.close(() => {
      process.exit(1);
    });
  });
};

startServer();
