import mongoose from 'mongoose';

const artistSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Tên nghệ sĩ là bắt buộc'],
      trim: true,
      index: true,
    },
    image_url: {
      type: String,
      default: '',
    },
    biography: {
      type: String,
      default: '',
    },
    verified: {
      type: Boolean,
      default: false,
    },
    followers_count: {
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

artistSchema.index({ name: 'text' });

export const Artist = mongoose.model('Artist', artistSchema, 'artists');
