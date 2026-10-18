import mongoose from 'mongoose';

const trackArtistSchema = new mongoose.Schema(
  {
    track_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Track',
      required: true,
      index: true,
    },
    artist_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Artist',
      required: true,
      index: true,
    },
    role: {
      type: String,
      default: 'main_artist',
      trim: true,
    },
  },
  {
    timestamps: false,
    versionKey: false,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

trackArtistSchema.index({ track_id: 1, artist_id: 1 });

export const TrackArtist = mongoose.model('TrackArtist', trackArtistSchema, 'track_artists');
