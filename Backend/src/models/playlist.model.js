import mongoose from 'mongoose';

const playlistSchema = new mongoose.Schema(
  {
    owner_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    name: {
      type: String,
      required: [true, 'Tên playlist là bắt buộc'],
      trim: true,
    },
    description: {
      type: String,
      default: '',
    },
    image_url: {
      type: String,
      default: '',
    },
    is_public: {
      type: Boolean,
      default: true,
    },
    collaborative: {
      type: Boolean,
      default: false,
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

playlistSchema.index({ owner_id: 1, created_at: -1 });

export const Playlist = mongoose.model('Playlist', playlistSchema, 'playlists');
