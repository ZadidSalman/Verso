import mongoose, { Document, Schema } from 'mongoose';

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACES
// ─────────────────────────────────────────────────────────────────────────────

export interface IFollow extends Document {
  _id: mongoose.Types.ObjectId;
  followerId: mongoose.Types.ObjectId;
  followingId: mongoose.Types.ObjectId;
  isMutual: boolean;
  createdAt: Date;
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEMA
// ─────────────────────────────────────────────────────────────────────────────

const FollowSchema = new Schema<IFollow>(
  {
    followerId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    followingId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    isMutual: {
      type: Boolean,
      default: false,
      index: true,
    },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// INDEXES
// ─────────────────────────────────────────────────────────────────────────────

// Unique compound index: one follow relationship per pair
FollowSchema.index({ followerId: 1, followingId: 1 }, { unique: true });

// Index for finding who follows a user
FollowSchema.index({ followingId: 1 });

// Index for finding mutual follows
FollowSchema.index({ followerId: 1, isMutual: 1 });

// ─────────────────────────────────────────────────────────────────────────────
// EXPORT
// ─────────────────────────────────────────────────────────────────────────────

export const Follow = mongoose.model<IFollow>('Follow', FollowSchema);
