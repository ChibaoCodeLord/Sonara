import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Vui lòng cung cấp họ và tên'],
      trim: true,
      maxlength: [50, 'Tên không được vượt quá 50 ký tự'],
    },
    email: {
      type: String,
      required: [true, 'Vui lòng cung cấp địa chỉ email'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [
        /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
        'Địa chỉ email không hợp lệ',
      ],
    },
    password: {
      type: String,
      required: [true, 'Vui lòng cung cấp mật khẩu'],
      minlength: [6, 'Mật khẩu phải có ít nhất 6 ký tự'],
      select: false, // Ẩn mật khẩu khi query trừ khi được gọi rõ ràng
    },
    avatar: {
      type: String,
      default: '',
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
    favoriteSongs: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Song',
      },
    ],
  },
  {
    timestamps: true,
  }
);

// Tự động mã hóa mật khẩu trước khi lưu vào CSDL
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Phương thức đối soát mật khẩu người dùng nhập vào
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

export const User = mongoose.model('User', userSchema);
