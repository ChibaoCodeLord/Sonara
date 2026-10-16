import mongoose from 'mongoose';
import { ENV } from './env.js';

export const connectDB = async () => {
  try {
    const conn = await mongoose.connect(ENV.MONGO_URI);
    console.log(`[Database] Kết nối MongoDB thành công: ${conn.connection.host}`);
  } catch (error) {
    console.error(`[Database Error] Không thể kết nối MongoDB: ${error.message}`);
    process.exit(1);
  }
};
