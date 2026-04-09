import mongoose, { Document, Schema } from 'mongoose';

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACES
// ─────────────────────────────────────────────────────────────────────────────

export interface IThought extends Document {
  _id: mongoose.Types.ObjectId;
  authorId: mongoose.Types.ObjectId;
  content: string;
  language: 'en' | 'bn';
  visibility: 'public' | 'mutual' | 'private';
  likesCount: number;
  createdAt: Date;
  updatedAt: Date;
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEMA
// ─────────────────────────────────────────────────────────────────────────────

const ThoughtSchema = new Schema<IThought>(
  {
    authorId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    content: {
      type: String,
      required: true,
      maxlength: 280,
    },
    language: {
      type: String,
      enum: ['en', 'bn'],
      default: 'en',
    },
    visibility: {
      type: String,
      enum: ['public', 'mutual', 'private'],
      default: 'public',
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

// Index for feed queries
ThoughtSchema.index({ authorId: 1, createdAt: -1 });
ThoughtSchema.index({ visibility: 1, createdAt: -1 });
ThoughtSchema.index({ visibility: 1, language: 1, createdAt: -1 });

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

export const Thought = mongoose.model<IThought>('Thought', ThoughtSchema);
