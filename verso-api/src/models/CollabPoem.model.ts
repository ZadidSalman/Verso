import mongoose, { Document, Schema } from 'mongoose';

export interface ICollabPoem extends Document {
  _id: mongoose.Types.ObjectId;
  title: string;
  language: 'en' | 'bn';
  originatorId: mongoose.Types.ObjectId;
  collabType: 'open' | 'invite-only';
  status: 'open' | 'closed';
  stanzas: {
    stanzaId: mongoose.Types.ObjectId;
    authorId: mongoose.Types.ObjectId;
    content: string;
    order: number;
    isApproved: boolean;
    createdAt: Date;
  }[];
  contributorsCount: number;
  mood: string[];
  likesCount: number;
  commentsCount: number;
  readsCount: number;
  trendingScore: number;
  createdAt: Date;
  updatedAt: Date;
}

const StanzaSchema = new Schema({
  stanzaId: { type: Schema.Types.ObjectId, default: () => new mongoose.Types.ObjectId() },
  authorId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  content: { type: String, required: true, maxlength: 2000 },
  order: { type: Number, required: true },
  isApproved: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

const CollabPoemSchema = new Schema<ICollabPoem>(
  {
    title: { type: String, required: true, trim: true, maxlength: 200 },
    language: { type: String, enum: ['en', 'bn'], default: 'en', index: true },
    originatorId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    collabType: { type: String, enum: ['open', 'invite-only'], default: 'open' },
    status: { type: String, enum: ['open', 'closed'], default: 'open', index: true },
    stanzas: [StanzaSchema],
    contributorsCount: { type: Number, default: 0 },
    mood: { type: [String], default: [], index: true },
    likesCount: { type: Number, default: 0 },
    commentsCount: { type: Number, default: 0 },
    readsCount: { type: Number, default: 0 },
    trendingScore: { type: Number, default: 0, index: true },
  },
  { timestamps: true }
);

CollabPoemSchema.index({ trendingScore: -1 });
CollabPoemSchema.index({ status: 1, createdAt: -1 });
CollabPoemSchema.index({ originatorId: 1, createdAt: -1 });

export const CollabPoem = mongoose.model<ICollabPoem>('CollabPoem', CollabPoemSchema);
