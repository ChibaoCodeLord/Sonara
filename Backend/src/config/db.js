import dns from 'node:dns';
import mongoose from 'mongoose';
import { ENV } from './env.js';

// Cấu hình DNS công cộng (Google/Cloudflare) để tránh lỗi querySrv ECONNREFUSED trên mạng gia đình
if (ENV.MONGO_URI && ENV.MONGO_URI.startsWith('mongodb+srv://')) {
  try {
    dns.setServers(['8.8.8.8', '1.1.1.1']);
  } catch (e) {
    // Bỏ qua nếu môi trường không cho phép cấu hình DNS
  }
}

export const connectDB = async () => {
  try {
    const conn = await mongoose.connect(ENV.MONGO_URI);
    console.log(`[Database] Kết nối MongoDB Atlas thành công: ${conn.connection.host}`);
  } catch (error) {
    console.error(`[Database Error] Không thể kết nối MongoDB: ${error.message}`);
    process.exit(1);
  }
};
