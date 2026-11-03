import mongoose from 'mongoose';

const albumSchema = new mongoose.Schema(
  {
    source_key: { type: String },
    revision: {type:Number,default:0},
    catalog_metadata: { type: mongoose.Schema.Types.Mixed },
    spotify_id: { type: String },
    musicbrainz_id: { type: String },
    musicbrainz_url: { type: String },
    spotify_url: { type: String },
    release_date_precision: { type: String },
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
albumSchema.index({ source_key: 1 }, { unique: true, partialFilterExpression: { source_key: { $type: 'string' } } });
albumSchema.index({ spotify_id: 1 }, { unique: true, partialFilterExpression: { spotify_id: { $type: 'string' } } });
albumSchema.index({ musicbrainz_id: 1 }, { unique: true, partialFilterExpression: { musicbrainz_id: { $type: 'string' } } });

export const Album = mongoose.model('Album', albumSchema, 'albums');
