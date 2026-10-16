import jwt from 'jsonwebtoken';
import { ENV } from '../config/env.js';
import { ApiError } from '../utils/apiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { User } from '../models/user.model.js';

export const protect = asyncHandler(async (req, res, next) => {
  let token;

  // Lấy token từ header Authorization: Bearer <token>
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    throw new ApiError(401, 'Bạn chưa đăng nhập! Vui lòng cung cấp token hợp lệ.');
  }

  // Giải mã token
  const decoded = jwt.verify(token, ENV.JWT_SECRET);

  // Kiểm tra tài khoản người dùng có còn tồn tại không
  const currentUser = await User.findById(decoded.id);
  if (!currentUser) {
    throw new ApiError(401, 'Người dùng sở hữu token này không còn tồn tại.');
  }

  // Gán thông tin người dùng vào request
  req.user = currentUser;
  next();
});

export const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      throw new ApiError(403, 'Bạn không có quyền thực hiện hành động này!');
    }
    next();
  };
};
