import mongoose from 'mongoose';

const trackSchema = new mongoose.Schema(
  {
    source_key: { type: String },
    catalog_dataset: { type: String, index: true },
    catalog_metadata: { type: mongoose.Schema.Types.Mixed },
    spotify_id: { type: String },
    archive_id: { type: String },
    archive_metadata: { type: mongoose.Schema.Types.Mixed },
    audius_id: { type: String },
    audius_metadata: { type: mongoose.Schema.Types.Mixed },
    musicbrainz_id: { type: String },
    musicbrainz_url: { type: String },
    musicbrainz_metadata: { type: mongoose.Schema.Types.Mixed },
    spotify_url: { type: String, default: '' },
    catalog_source: { type: String, default: 'local' },
    imported_at: { type: Date },
    deleted_at: {type:Date,default:null},
    moderation_status: {type:String,enum:['PUBLISHED','BANNED','ARCHIVED','UNRELEASED']},
    revision: {type:Number,default:0},
    audio_cache: { type: mongoose.Schema.Types.Mixed },
    spotify_metadata: { type: mongoose.Schema.Types.Mixed },
    youtube: {
      type: new mongoose.Schema({
        status: { type: String, enum: ['pending', 'matched', 'review', 'unmatched', 'error'], default: 'pending' },
        video_id: String, url: String, embed_url: String, title: String, channel_title: String,
        duration_seconds: Number, match_score: Number, search_provider: String, embed_check: String,
        playback_status: { type: String, enum: ['available', 'blocked', 'unknown'] }, playback_checked_at: Date,
        checked_at: Date, error: String, candidates: { type: [mongoose.Schema.Types.Mixed], default: [] }
      }, { _id: false }),
      default: undefined
    },
    title: {
      type: String,
      required: [true, 'Tên bài hát là bắt buộc'],
      trim: true,
      index: true,
    },
    duration_ms: {
      type: Number,
      default: 0,
    },
    explicit: {
      type: Boolean,
      default: false,
    },
    isrc: {
      type: String,
      default: '',
      trim: true,
    },
    popularity: {
      type: Number,
      default: 0,
      index: -1,
    },
    preview_url: {
      type: String,
      default: '',
    },
    audio_url: {
      type: String,
      default: '',
    },
    cover_url: {
      type: String,
      default: '',
    },
    genre: {
      type: String,
      default: 'Pop',
      trim: true,
      index: true,
    },
    synced_lyrics: {
      type: Array, // Mảng các mốc thời gian Karaoke: [{ time_ms: 12000, text: "Hôm nay trời đẹp..." }]
      default: [],
    },
    status: {
      type: String,
      enum: ['active', 'unreleased', 'hidden'],
      default: 'active',
    },
  },
  {
    timestamps: false,
    versionKey: false,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

trackSchema.index({ title: 'text' });
trackSchema.index({ source_key: 1 }, { unique: true, partialFilterExpression: { source_key: { $type: 'string' } } });
trackSchema.index({ spotify_id: 1 }, { unique: true, partialFilterExpression: { spotify_id: { $type: 'string' } } });
trackSchema.index({ musicbrainz_id: 1 }, { unique: true, partialFilterExpression: { musicbrainz_id: { $type: 'string' } } });
trackSchema.index({ audius_id: 1 }, { unique: true, partialFilterExpression: { audius_id: { $type: 'string' } } });
trackSchema.index({ archive_id: 1 }, { unique: true, partialFilterExpression: { archive_id: { $type: 'string' } } });

export const Track = mongoose.model('Track', trackSchema, 'tracks');
// Alias Song sang Track để không làm gãy các service hiện có
export const Song = Track;
