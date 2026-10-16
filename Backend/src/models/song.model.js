import mongoose from 'mongoose';

const songSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Tên bài hát là bắt buộc'],
      trim: true,
    },
    artist: {
      type: String,
      required: [true, 'Tên nghệ sĩ/ca sĩ là bắt buộc'],
      trim: true,
    },
    album: {
      type: String,
      default: 'Single',
      trim: true,
    },
    genre: {
      type: String,
      default: 'Pop',
      trim: true,
    },
    duration: {
      type: Number, // Thời lượng bài hát tính bằng giây (seconds)
      default: 0,
    },
    audioUrl: {
      type: String,
      required: [true, 'Đường dẫn file âm thanh là bắt buộc'],
    },
    coverUrl: {
      type: String,
      default: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop',
    },
    lyrics: {
      type: String,
      default: '',
    },
    playsCount: {
      type: Number,
      default: 0,
    },
    likesCount: {
      type: Number,
      default: 0,
    },
    isTrending: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Tạo index để tìm kiếm bài hát theo tên hoặc nghệ sĩ nhanh chóng
songSchema.index({ title: 'text', artist: 'text' });

export const Song = mongoose.model('Song', songSchema);
