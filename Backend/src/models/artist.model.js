import mongoose from 'mongoose';

const artistSchema = new mongoose.Schema(
  {
    source_key: { type: String },
    revision: {type:Number,default:0},
    catalog_metadata: { type: mongoose.Schema.Types.Mixed },
    spotify_id: { type: String },
    musicbrainz_id: { type: String },
    musicbrainz_url: { type: String },
    spotify_url: { type: String },
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
artistSchema.index({ source_key: 1 }, { unique: true, partialFilterExpression: { source_key: { $type: 'string' } } });
artistSchema.index({ spotify_id: 1 }, { unique: true, partialFilterExpression: { spotify_id: { $type: 'string' } } });
artistSchema.index({ musicbrainz_id: 1 }, { unique: true, partialFilterExpression: { musicbrainz_id: { $type: 'string' } } });

export const Artist = mongoose.model('Artist', artistSchema, 'artists');
