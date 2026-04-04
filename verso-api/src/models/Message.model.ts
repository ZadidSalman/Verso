import mongoose, { Document, Schema } from 'mongoose';

export interface IMessage extends Document {
  _id: mongoose.Types.ObjectId;
  conversationId: mongoose.Types.ObjectId;
  senderId: mongoose.Types.ObjectId;
  content: string;
  type: 'text' | 'poemShare' | 'storyShare';
  readBy: mongoose.Types.ObjectId[];
  sentAt: Date;
}

const MessageSchema = new Schema<IMessage>(
  {
    conversationId: { type: Schema.Types.ObjectId, ref: 'Conversation', required: true, index: true },
    senderId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    content: { type: String, required: true },
    type: { type: String, enum: ['text', 'poemShare', 'storyShare'], default: 'text' },
    readBy: [{ type: Schema.Types.ObjectId, ref: 'User' }],
    sentAt: { type: Date, default: Date.now, index: true },
  },
  { timestamps: false }
);

MessageSchema.index({ conversationId: 1, sentAt: -1 });

export const Message = mongoose.model<IMessage>('Message', MessageSchema);
