import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: [true, 'Email là bắt buộc'],
      unique: true,
      lowercase: true,
      trim: true,
    },
    password_hash: {
      type: String,
      required: [true, 'Mật khẩu là bắt buộc'],
      select: false,
    },
    display_name: {
      type: String,
      required: [true, 'Tên hiển thị là bắt buộc'],
      trim: true,
    },
    avatar_url: {
      type: String,
      default: '',
    },
    country: {
      type: String,
      default: 'VN',
      trim: true,
    },
    created_at: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: false,
    versionKey: false,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Tự động hash mật khẩu trước khi lưu vào CSDL
userSchema.pre('save', async function (next) {
  if (!this.isModified('password_hash')) return next();
  this.password_hash = await bcrypt.hash(this.password_hash, 12);
  next();
});

// Phương thức so khớp mật khẩu
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password_hash);
};

// Aliases để tương thích với auth controller cũ
userSchema.virtual('name').get(function () {
  return this.display_name;
}).set(function (v) {
  this.display_name = v;
});

userSchema.virtual('password').set(function (v) {
  this.password_hash = v;
});

export const User = mongoose.model('User', userSchema, 'users');
