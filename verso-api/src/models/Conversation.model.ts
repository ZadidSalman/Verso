import mongoose, { Document, Schema } from 'mongoose';

export interface IConversation extends Document {
  _id: mongoose.Types.ObjectId;
  participantIds: mongoose.Types.ObjectId[];
  conversationKey: string;
  lastMessage: string;
  lastMessageAt: Date;
  unreadCounts: Record<string, number>;
  createdAt: Date;
  updatedAt: Date;
}

const ConversationSchema = new Schema<IConversation>(
  {
    participantIds: [{ type: Schema.Types.ObjectId, ref: 'User', required: true }],
    conversationKey: { type: String, required: true, unique: true, index: true },
    lastMessage: { type: String, default: '' },
    lastMessageAt: { type: Date, default: Date.now, index: true },
    unreadCounts: { type: Map, of: Number, default: {} },
  },
  { timestamps: true }
);

ConversationSchema.index({ participantIds: 1 });

export const Conversation = mongoose.model<IConversation>('Conversation', ConversationSchema);
