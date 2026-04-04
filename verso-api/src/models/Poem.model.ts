import mongoose, { Document, Schema } from 'mongoose';

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACES
// ─────────────────────────────────────────────────────────────────────────────

export interface IPoem extends Document {
  _id: mongoose.Types.ObjectId;
  authorId: mongoose.Types.ObjectId;
  title: string;
  content: string;
  slug: string;
  language: 'en' | 'bn';
  mood: string[];
  tags: string[];
  category?: string;
  genre?: string;
  isAnonymous: boolean;
  isUnsent: boolean;
  unsentTo?: string;
  promptId?: mongoose.Types.ObjectId;
  status: 'draft' | 'published' | 'archived';
  audioUrl?: string;
  videoUrl?: string;
  coverImageUrl?: string;
  likesCount: number;
  commentsCount: number;
  savesCount: number;
  readsCount: number;
  trendingScore: number;
  wordCount: number;
  lineCount: number;
  publishedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEMA
// ─────────────────────────────────────────────────────────────────────────────

const PoemSchema = new Schema<IPoem>(
  {
    authorId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 200,
    },
    content: {
      type: String,
      required: true,
    },
    slug: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      index: true,
    },
    language: {
      type: String,
      enum: ['en', 'bn'],
      default: 'en',
      index: true,
    },
    mood: {
      type: [String],
      default: [],
      index: true,
    },
    tags: {
      type: [String],
      default: [],
      index: true,
    },
    category: {
      type: String,
      trim: true,
    },
    genre: {
      type: String,
      trim: true,
    },
    isAnonymous: {
      type: Boolean,
      default: false,
    },
    isUnsent: {
      type: Boolean,
      default: false,
    },
    unsentTo: {
      type: String,
      trim: true,
    },
    promptId: {
      type: Schema.Types.ObjectId,
      ref: 'Prompt',
    },
    status: {
      type: String,
      enum: ['draft', 'published', 'archived'],
      default: 'draft',
      index: true,
    },
    audioUrl: String,
    videoUrl: String,
    coverImageUrl: String,
    likesCount: { type: Number, default: 0 },
    commentsCount: { type: Number, default: 0 },
    savesCount: { type: Number, default: 0 },
    readsCount: { type: Number, default: 0 },
    trendingScore: { type: Number, default: 0, index: true },
    wordCount: { type: Number, default: 0 },
    lineCount: { type: Number, default: 0 },
    publishedAt: { type: Date, index: true },
  },
  {
    timestamps: true,
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// INDEXES
// ─────────────────────────────────────────────────────────────────────────────

PoemSchema.index({ trendingScore: -1 });
PoemSchema.index({ publishedAt: -1 });
PoemSchema.index({ authorId: 1, publishedAt: -1 });
PoemSchema.index({ mood: 1, trendingScore: -1 });
PoemSchema.index({ language: 1, trendingScore: -1 });
PoemSchema.index({ status: 1, publishedAt: -1 });
PoemSchema.index({ videoUrl: 1, trendingScore: -1 });

// ─────────────────────────────────────────────────────────────────────────────
// MIDDLEWARE
// ─────────────────────────────────────────────────────────────────────────────

PoemSchema.pre('save', function () {
  // Auto-generate slug from title + last 6 chars of _id
  if (this.isModified('title') || this.isNew) {
    const titleSlug = this.title
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .trim();
    const idSuffix = this._id.toString().slice(-6);
    this.slug = `${titleSlug}-${idSuffix}`;
  }

  // Auto-compute word count
  if (this.isModified('content')) {
    this.wordCount = this.content
      .split(/\s+/)
      .filter((w: string) => w.length > 0).length;
    this.lineCount = this.content
      .split('\n')
      .filter((l: string) => l.trim().length > 0).length;
  }

  // Set publishedAt when status first becomes published
  if (this.isModified('status') && this.status === 'published' && !this.publishedAt) {
    this.publishedAt = new Date();
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// EXPORT
// ─────────────────────────────────────────────────────────────────────────────

export const Poem = mongoose.model<IPoem>('Poem', PoemSchema);
