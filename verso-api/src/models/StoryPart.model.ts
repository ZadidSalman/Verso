import mongoose, { Document, Schema } from 'mongoose';

export interface IStoryPart extends Document {
  _id: mongoose.Types.ObjectId;
  storyId: mongoose.Types.ObjectId;
  authorId: mongoose.Types.ObjectId;
  partNumber: number;
  title: string;
  content: string;
  coverImageUrl?: string;
  language: 'en' | 'bn';
  mood: string[];
  parentPartId?: mongoose.Types.ObjectId;
  branchLabel?: string;
  status: 'draft' | 'published';
  isCollabContribution: boolean;
  likesCount: number;
  commentsCount: number;
  readsCount: number;
  publishedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const StoryPartSchema = new Schema<IStoryPart>(
  {
    storyId: { type: Schema.Types.ObjectId, ref: 'Story', required: true, index: true },
    authorId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    partNumber: { type: Number, required: true },
    title: { type: String, required: true, trim: true, maxlength: 200 },
    content: { type: String, required: true },
    coverImageUrl: String,
    language: { type: String, enum: ['en', 'bn'], default: 'en' },
    mood: { type: [String], default: [] },
    parentPartId: { type: Schema.Types.ObjectId, ref: 'StoryPart', default: null },
    branchLabel: { type: String, trim: true },
    status: { type: String, enum: ['draft', 'published'], default: 'draft' },
    isCollabContribution: { type: Boolean, default: false },
    likesCount: { type: Number, default: 0 },
    commentsCount: { type: Number, default: 0 },
    readsCount: { type: Number, default: 0 },
    publishedAt: { type: Date },
  },
  { timestamps: true }
);

StoryPartSchema.index({ storyId: 1, partNumber: 1 });
StoryPartSchema.index({ storyId: 1, publishedAt: -1 });

StoryPartSchema.pre('save', function () {
  if (this.isModified('status') && this.status === 'published' && !this.publishedAt) {
    this.publishedAt = new Date();
  }
});

export const StoryPart = mongoose.model<IStoryPart>('StoryPart', StoryPartSchema);
