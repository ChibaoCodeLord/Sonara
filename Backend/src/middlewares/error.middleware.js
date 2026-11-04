import { ENV } from '../config/env.js';

export const errorHandler = (err, req, res, next) => {
  if(res.headersSent)return res.destroy();
  let error = { ...err };
  error.message = err.message;
  error.statusCode = err.statusCode || (Number.isInteger(err.status)?err.status:500);
  if(err.name==='MulterError'){error.statusCode=err.code==='LIMIT_FILE_SIZE'?413:400;error.message='File tải lên không hợp lệ hoặc vượt giới hạn dung lượng.';}
  if(['MongoServerSelectionError','MongooseServerSelectionError'].includes(err.name)){error.statusCode=503;error.message='Cơ sở dữ liệu chưa sẵn sàng.';}

  // Lỗi cú pháp ID MongoDB không hợp lệ (CastError)
  if (err.name === 'CastError') {
    error.statusCode = 400;
    error.message = `Không tìm thấy tài nguyên với ID: ${err.value}`;
  }

  // Lỗi trùng lặp dữ liệu Unique trong MongoDB (E11000)
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue || {})[0] || 'trường dữ liệu';
    error.statusCode = 400;
    error.message = `Giá trị của ${field} đã tồn tại trong hệ thống!`;
  }

  // Lỗi Validation Mongoose
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((val) => val.message);
    error.statusCode = 400;
    error.message = messages.join('. ');
  }

  // Lỗi xác thực JWT
  if (err.name === 'JsonWebTokenError') {
    error.statusCode = 401;
    error.message = 'Token xác thực không hợp lệ. Vui lòng đăng nhập lại!';
  }

  if (err.name === 'TokenExpiredError') {
    error.statusCode = 401;
    error.message = 'Token xác thực đã hết hạn. Vui lòng đăng nhập lại!';
  }
  if(error.statusCode>=500&&!err.isOperational&&ENV.NODE_ENV!=='development'&&error.statusCode!==503)error.message='Lỗi máy chủ nội bộ.';

  res.status(error.statusCode).json({
    success: false,
    statusCode: error.statusCode,
    message: error.message || 'Lỗi máy chủ nội bộ!',
    ...(ENV.NODE_ENV === 'development' && { stack: err.stack }),
  });
};
