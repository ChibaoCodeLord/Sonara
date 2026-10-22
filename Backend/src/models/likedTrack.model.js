import mongoose from 'mongoose';

const likedTrackSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    track_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Track',
      required: true,
      index: true,
    },
    added_at: {
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

// Ràng buộc duy nhất: Một user chỉ like 1 track 1 lần
likedTrackSchema.index({ user_id: 1, track_id: 1 }, { unique: true });

export const LikedTrack = mongoose.model('LikedTrack', likedTrackSchema, 'liked_tracks');
