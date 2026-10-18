import mongoose from 'mongoose';

const albumTrackSchema = new mongoose.Schema(
  {
    album_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Album',
      required: true,
      index: true,
    },
    track_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Track',
      required: true,
      index: true,
    },
    disc_number: {
      type: Number,
      default: 1,
    },
    track_number: {
      type: Number,
      required: true,
    },
  },
  {
    timestamps: false,
    versionKey: false,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

albumTrackSchema.index({ album_id: 1, track_id: 1 });

export const AlbumTrack = mongoose.model('AlbumTrack', albumTrackSchema, 'album_tracks');
