import mongoose, { Document, Schema } from 'mongoose';

export interface IStory extends Document {
  _id: mongoose.Types.ObjectId;
  authorId: mongoose.Types.ObjectId;
  title: string;
  description: string;
  coverImageUrl?: string;
  language: 'en' | 'bn';
  mood: string[];
  tags: string[];
  genre?: string;
  isCollab: boolean;
  collabMode: 'invite-only' | 'open' | 'none';
  storyMode: 'linear' | 'branching';
  collabContributorIds: mongoose.Types.ObjectId[];
  status: 'ongoing' | 'completed' | 'abandoned';
  partsCount: number;
  followersCount: number;
  totalReads: number;
  trendingScore: number;
  publishedAt?: Date;
  lastPartAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const StorySchema = new Schema<IStory>(
  {
    authorId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    title: { type: String, required: true, trim: true, maxlength: 200 },
    description: { type: String, trim: true, maxlength: 500 },
    coverImageUrl: String,
    language: { type: String, enum: ['en', 'bn'], default: 'en', index: true },
    mood: { type: [String], default: [], index: true },
    tags: { type: [String], default: [], index: true },
    genre: { type: String, trim: true, index: true },
    isCollab: { type: Boolean, default: false },
    collabMode: { type: String, enum: ['invite-only', 'open', 'none'], default: 'none' },
    storyMode: { type: String, enum: ['linear', 'branching'], default: 'linear' },
    collabContributorIds: [{ type: Schema.Types.ObjectId, ref: 'User' }],
    status: { type: String, enum: ['ongoing', 'completed', 'abandoned'], default: 'ongoing' },
    partsCount: { type: Number, default: 0 },
    followersCount: { type: Number, default: 0 },
    totalReads: { type: Number, default: 0 },
    trendingScore: { type: Number, default: 0, index: true },
    publishedAt: { type: Date, index: true },
    lastPartAt: { type: Date, index: true },
  },
  { timestamps: true }
);

StorySchema.index({ trendingScore: -1 });
StorySchema.index({ authorId: 1, lastPartAt: -1 });
StorySchema.index({ lastPartAt: -1 });
StorySchema.index({ mood: 1, trendingScore: -1 });

StorySchema.pre('save', function () {
  if (this.isModified('status') && this.status === 'ongoing' && !this.publishedAt) {
    this.publishedAt = new Date();
  }
});

export const Story = mongoose.model<IStory>('Story', StorySchema);
