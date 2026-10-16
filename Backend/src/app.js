import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'path';

import { ENV } from './config/env.js';
import { ApiError } from './utils/apiError.js';
import { errorHandler } from './middlewares/error.middleware.js';
import rootRouter from './routes/index.js';

const app = express();

// Middlewares bảo mật & ghi log
app.use(helmet({ crossOriginResourcePolicy: false })); // Cho phép stream audio và load hình ảnh qua CORS
app.use(
  cors({
    origin: ENV.CORS_ORIGIN,
    credentials: true,
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (ENV.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Phục vụ các file tĩnh trong thư mục uploads (audio, hình ảnh cover)
app.use('/uploads', express.static(path.resolve('uploads')));

// Định tuyến API phiên bản 1 (/api/v1)
app.use('/api/v1', rootRouter);

// Bắt các route không tồn tại (404)
app.all('*', (req, res, next) => {
  next(new ApiError(404, `Không tìm thấy endpoint: [${req.method}] ${req.originalUrl}`));
});

// Middleware xử lý lỗi toàn cục
app.use(errorHandler);

export default app;
