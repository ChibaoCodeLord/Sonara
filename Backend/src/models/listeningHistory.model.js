import mongoose from 'mongoose';

const listeningHistorySchema = new mongoose.Schema(
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
    played_at: {
      type: Date,
      default: Date.now,
    },
    listened_ms: {
      type: Number,
      default: 0,
    },
    completed: {
      type: Boolean,
      default: false,
    },
    source: {
      type: String,
      default: 'playlist',
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

// Index phục vụ lấy lịch sử nghe gần nhất của user
listeningHistorySchema.index({ user_id: 1, played_at: -1 });

export const ListeningHistory = mongoose.model(
  'ListeningHistory',
  listeningHistorySchema,
  'listening_history'
);
