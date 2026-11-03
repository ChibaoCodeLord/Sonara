import mongoose from 'mongoose';

const playlistTrackSchema = new mongoose.Schema(
  {
    playlist_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Playlist',
      required: true,
      index: true,
    },
    track_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Track',
      required: true,
      index: true,
    },
    added_by: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    position: {
      type: Number,
      default: 0,
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

playlistTrackSchema.index({ playlist_id: 1, position: 1 });
playlistTrackSchema.index({playlist_id:1,track_id:1},{unique:true});

export const PlaylistTrack = mongoose.model('PlaylistTrack', playlistTrackSchema, 'playlist_tracks');
