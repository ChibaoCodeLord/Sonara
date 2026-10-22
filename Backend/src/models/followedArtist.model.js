import mongoose from 'mongoose';

const followedArtistSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    artist_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Artist',
      required: true,
      index: true,
    },
    followed_at: {
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

// Ràng buộc duy nhất: Một user chỉ follow 1 artist 1 lần
followedArtistSchema.index({ user_id: 1, artist_id: 1 }, { unique: true });

export const FollowedArtist = mongoose.model('FollowedArtist', followedArtistSchema, 'followed_artists');
