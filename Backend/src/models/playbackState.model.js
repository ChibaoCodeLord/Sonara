import mongoose from 'mongoose';

const playbackStateSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    current_track_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Track',
      default: null,
    },
    position_ms: {
      type: Number,
      default: 0,
    },
    is_playing: {
      type: Boolean,
      default: false,
    },
    repeat_mode: {
      type: String,
      enum: ['off', 'track', 'context'],
      default: 'off',
    },
    shuffle: {
      type: Boolean,
      default: false,
    },
    queue: {
      type: mongoose.Schema.Types.Mixed,
      default: [],
    },
    updated_at: {
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

export const PlaybackState = mongoose.model(
  'PlaybackState',
  playbackStateSchema,
  'playback_states'
);
