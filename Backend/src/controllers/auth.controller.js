import * as authService from '../services/auth.service.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const register = asyncHandler(async (req, res) => {
  const result = await authService.register(req.body);
  res
    .status(201)
    .json(new ApiResponse(201, result, 'Đăng ký tài khoản thành công!'));
});

export const login = asyncHandler(async (req, res) => {
  const result = await authService.login(req.body);
  res
    .status(200)
    .json(new ApiResponse(200, result, 'Đăng nhập thành công!'));
});

export const getMe = asyncHandler(async (req, res) => {
  const user = await authService.getProfile(req.user._id);
  res
    .status(200)
    .json(new ApiResponse(200, user, 'Lấy thông tin tài khoản thành công!'));
});
