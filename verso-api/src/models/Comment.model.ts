import mongoose, { Document, Schema } from 'mongoose';

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACES
// ─────────────────────────────────────────────────────────────────────────────

export interface IComment extends Document {
  _id: mongoose.Types.ObjectId;
  targetId: mongoose.Types.ObjectId;
  targetType: 'poem' | 'storyPart' | 'thought';
  authorId: mongoose.Types.ObjectId;
  parentCommentId?: mongoose.Types.ObjectId;
  content: string;
  likesCount: number;
  createdAt: Date;
  updatedAt: Date;
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEMA
// ─────────────────────────────────────────────────────────────────────────────

const CommentSchema = new Schema<IComment>(
  {
    targetId: {
      type: Schema.Types.ObjectId,
      required: true,
      index: true,
    },
    targetType: {
      type: String,
      enum: ['poem', 'storyPart', 'thought'],
      required: true,
      index: true,
    },
    authorId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    parentCommentId: {
      type: Schema.Types.ObjectId,
      ref: 'Comment',
      default: null,
    },
    content: {
      type: String,
      required: true,
      trim: true,
      maxlength: 1000,
    },
    likesCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// INDEXES
// ─────────────────────────────────────────────────────────────────────────────

// Index for fetching comments on a target
CommentSchema.index({ targetId: 1, targetType: 1, createdAt: -1 });

// Index for fetching replies to a comment
CommentSchema.index({ parentCommentId: 1, createdAt: 1 });

// ─────────────────────────────────────────────────────────────────────────────
// EXPORT
// ─────────────────────────────────────────────────────────────────────────────

export const Comment = mongoose.model<IComment>('Comment', CommentSchema);
