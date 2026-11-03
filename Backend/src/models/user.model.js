import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import {password as validatePassword} from '../utils/validation.js';

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: [true, 'Email là bắt buộc'],
      unique: true,
      lowercase: true,
      trim: true,
      maxlength: 254,
      match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, 'Email không hợp lệ'],
    },
    password_hash: {
      type: String,
      required: [true, 'Mật khẩu là bắt buộc'],
      select: false,
      validate: {validator: value=>typeof value==='string'&&value.length>=8&&Buffer.byteLength(value,'utf8')<=72,message:'Mật khẩu cần ít nhất 8 ký tự, tối đa 72 byte UTF-8'},
    },
    display_name: {
      type: String,
      required: [true, 'Tên hiển thị là bắt buộc'],
      trim: true,
      maxlength: [50, 'Tên hiển thị không quá 50 ký tự'],
    },
    avatar_url: {
      type: String,
      default: '',
    },
    role: {type:String,enum:['user','admin'],default:'user'},
    status: {type:String,enum:['active','banned','suspended'],default:'active'},
    token_version: {type:Number,default:0,select:false},
    playlist_revision: {type:Number,default:0,select:false},
    admin_revision: {type:Number,default:0,select:false},
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
  return typeof candidatePassword==='string'&&typeof this.password_hash==='string'&&await bcrypt.compare(candidatePassword, this.password_hash);
};

// Aliases để tương thích với auth controller cũ
userSchema.virtual('name').get(function () {
  return this.display_name;
}).set(function (v) {
  this.display_name = v;
});

userSchema.virtual('password').set(function (v) {
  this.password_hash = validatePassword(v);
});

export const User = mongoose.model('User', userSchema, 'users');
