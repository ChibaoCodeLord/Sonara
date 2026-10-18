import mongoose from 'mongoose';

const trackSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Tên bài hát là bắt buộc'],
      trim: true,
      index: true,
    },
    duration_ms: {
      type: Number,
      default: 0,
    },
    explicit: {
      type: Boolean,
      default: false,
    },
    isrc: {
      type: String,
      default: '',
      trim: true,
    },
    popularity: {
      type: Number,
      default: 0,
      index: -1,
    },
    preview_url: {
      type: String,
      default: '',
    },
    audio_url: {
      type: String,
      default: '',
    },
    status: {
      type: String,
      enum: ['active', 'unreleased', 'hidden'],
      default: 'active',
    },
  },
  {
    timestamps: false,
    versionKey: false,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

trackSchema.index({ title: 'text' });

export const Track = mongoose.model('Track', trackSchema, 'tracks');
// Alias Song sang Track để không làm gãy các service hiện có
export const Song = Track;
