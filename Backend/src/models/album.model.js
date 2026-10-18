import mongoose from 'mongoose';

const albumSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Tiêu đề album là bắt buộc'],
      trim: true,
      index: true,
    },
    album_type: {
      type: String,
      default: 'album',
      trim: true,
    },
    cover_url: {
      type: String,
      default: '',
    },
    release_date: {
      type: Date,
      default: null,
    },
    label: {
      type: String,
      default: '',
      trim: true,
    },
    total_tracks: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: false,
    versionKey: false,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

albumSchema.index({ title: 'text' });

export const Album = mongoose.model('Album', albumSchema, 'albums');
