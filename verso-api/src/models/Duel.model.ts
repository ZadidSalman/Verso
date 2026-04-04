import mongoose, { Document, Schema } from 'mongoose';

export interface IDuel extends Document {
  _id: mongoose.Types.ObjectId;
  theme: string;
  challengerId: mongoose.Types.ObjectId;
  challengeeId: mongoose.Types.ObjectId;
  challengerPoemId: mongoose.Types.ObjectId;
  challengeePoemId: mongoose.Types.ObjectId | null;
  status: 'pending' | 'active' | 'completed' | 'declined';
  votesForChallenger: number;
  votesForChallengee: number;
  voterIds: mongoose.Types.ObjectId[];
  winnerId: mongoose.Types.ObjectId | null;
  endsAt: Date;
  createdAt: Date;
}

const DuelSchema = new Schema<IDuel>(
  {
    theme: { type: String, required: true, trim: true, maxlength: 100 },
    challengerId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    challengeeId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    challengerPoemId: { type: Schema.Types.ObjectId, ref: 'Poem', required: true },
    challengeePoemId: { type: Schema.Types.ObjectId, ref: 'Poem', default: null },
    status: { type: String, enum: ['pending', 'active', 'completed', 'declined'], default: 'pending', index: true },
    votesForChallenger: { type: Number, default: 0 },
    votesForChallengee: { type: Number, default: 0 },
    voterIds: [{ type: Schema.Types.ObjectId, ref: 'User' }],
    winnerId: { type: Schema.Types.ObjectId, ref: 'User', default: null },
    endsAt: { type: Date, index: true },
  },
  { timestamps: true }
);

DuelSchema.index({ status: 1, endsAt: 1 });
DuelSchema.index({ challengerId: 1, createdAt: -1 });
DuelSchema.index({ challengeeId: 1, createdAt: -1 });

export const Duel = mongoose.model<IDuel>('Duel', DuelSchema);
