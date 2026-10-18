import mongoose from 'mongoose';

const albumArtistSchema = new mongoose.Schema(
  {
    album_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Album',
      required: true,
      index: true,
    },
    artist_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Artist',
      required: true,
      index: true,
    },
  },
  {
    timestamps: false,
    versionKey: false,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

albumArtistSchema.index({ album_id: 1, artist_id: 1 });

export const AlbumArtist = mongoose.model('AlbumArtist', albumArtistSchema, 'album_artists');
