import jwt from 'jsonwebtoken';
import { User } from '../models/user.model.js';
import { ApiError } from '../utils/apiError.js';
import { ENV } from '../config/env.js';

const generateToken = (id) => {
  return jwt.sign({ id }, ENV.JWT_SECRET, {
    expiresIn: ENV.JWT_EXPIRES_IN,
  });
};

export const register = async ({ name, email, password }) => {
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    throw new ApiError(400, 'Địa chỉ email này đã được sử dụng!');
  }

  const user = await User.create({ name, email, password });
  const token = generateToken(user._id);

  return {
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      avatar: user.avatar,
    },
    token,
  };
};

export const login = async ({ email, password }) => {
  if (!email || !password) {
    throw new ApiError(400, 'Vui lòng cung cấp đầy đủ email và mật khẩu!');
  }

  const user = await User.findOne({ email }).select('+password');
  if (!user || !(await user.comparePassword(password))) {
    throw new ApiError(401, 'Email hoặc mật khẩu không chính xác!');
  }

  const token = generateToken(user._id);

  return {
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      avatar: user.avatar,
    },
    token,
  };
};

export const getProfile = async (userId) => {
  const user = await User.findById(userId).populate('favoriteSongs');
  if (!user) {
    throw new ApiError(404, 'Không tìm thấy người dùng!');
  }
  return user;
};
