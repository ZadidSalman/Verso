import { Request, Response } from 'express';
import { Conversation } from '../models/Conversation.model';
import { Message } from '../models/Message.model';
import { User } from '../models/User.model';
import { Poem } from '../models/Poem.model';
import mongoose from 'mongoose';

function formatConversation(conv: any, userId: string) {
  const otherId = conv.participantIds.find((id: string) => id.toString() !== userId);
  return {
    id: conv._id.toString(),
    participantIds: conv.participantIds.map((id: mongoose.Types.ObjectId) => id.toString()),
    conversationKey: conv.conversationKey,
    lastMessage: conv.lastMessage,
    lastMessageAt: conv.lastMessageAt,
    unreadCount: conv.unreadCounts?.get(userId) || 0,
    otherUser: otherId ? { id: otherId.toString() } : null,
    createdAt: conv.createdAt,
    updatedAt: conv.updatedAt,
  };
}

function formatMessage(msg: any) {
  return {
    id: msg._id.toString(),
    conversationId: msg.conversationId.toString(),
    senderId: msg.senderId.toString(),
    content: msg.content,
    type: msg.type,
    readBy: msg.readBy.map((id: mongoose.Types.ObjectId) => id.toString()),
    sentAt: msg.sentAt,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// GET conversations for current user
// ─────────────────────────────────────────────────────────────────────────────

export async function getConversations(req: Request, res: Response): Promise<void> {
  try {
    const conversations = await Conversation.find({
      participantIds: req.user!._id,
    })
      .sort({ lastMessageAt: -1 })
      .populate('participantIds', 'displayName username avatarUrl isVerifiedPoet');

    res.status(200).json({
      conversations: conversations.map((c) => formatConversation(c, req.user!._id.toString())),
    });
  } catch (error) {
    console.error('Failed to get conversations:', error);
    res.status(500).json({ message: 'Could not fetch your conversations.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIND OR CREATE conversation
// ─────────────────────────────────────────────────────────────────────────────

export async function findOrCreateConversation(req: Request, res: Response): Promise<void> {
  try {
    const { otherUserId } = req.body;

    if (!otherUserId) {
      res.status(400).json({ message: 'Other user ID is required.' });
      return;
    }

    if (otherUserId === req.user!._id.toString()) {
      res.status(400).json({ message: 'You cannot message yourself.' });
      return;
    }

    // Create deterministic key (sorted IDs)
    const ids = [req.user!._id.toString(), otherUserId].sort();
    const key = `${ids[0]}_${ids[1]}`;

    let conversation = await Conversation.findOne({ conversationKey: key })
      .populate('participantIds', 'displayName username avatarUrl isVerifiedPoet');

    if (!conversation) {
      conversation = await Conversation.create({
        participantIds: ids,
        conversationKey: key,
        unreadCounts: {},
      });
      conversation = await Conversation.findById(conversation._id)
        .populate('participantIds', 'displayName username avatarUrl isVerifiedPoet');
    }

    res.status(200).json({ conversation: formatConversation(conversation, req.user!._id.toString()) });
  } catch (error) {
    console.error('Failed to find/create conversation:', error);
    res.status(500).json({ message: 'Could not start this conversation.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET messages for a conversation
// ─────────────────────────────────────────────────────────────────────────────

export async function getMessages(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const { cursor, limit = '30' } = req.query;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid conversation ID.' });
      return;
    }

    const query: Record<string, unknown> = { conversationId: id };
    if (cursor) {
      query.sentAt = { $lt: new Date(cursor as string) };
    }

    const messages = await Message.find(query)
      .sort({ sentAt: -1 })
      .limit(parseInt(limit as string) + 1)
      .populate('senderId', 'displayName username avatarUrl');

    const hasMore = messages.length > parseInt(limit as string);
    if (hasMore) messages.pop();

    const nextCursor = hasMore && messages.length > 0
      ? messages[messages.length - 1].sentAt.toISOString()
      : null;

    res.status(200).json({
      messages: messages.map(formatMessage),
      nextCursor,
      hasMore,
    });
  } catch (error) {
    console.error('Failed to get messages:', error);
    res.status(500).json({ message: 'Could not fetch messages.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK conversation as read
// ─────────────────────────────────────────────────────────────────────────────

export async function markConversationRead(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid conversation ID.' });
      return;
    }

    await Conversation.findByIdAndUpdate(id, {
      $set: { [`unreadCounts.${req.user!._id.toString()}`]: 0 },
    });

    res.status(200).json({ message: 'ok' });
  } catch (error) {
    console.error('Failed to mark conversation read:', error);
    res.status(500).json({ message: 'Could not mark as read.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEND a message
// ─────────────────────────────────────────────────────────────────────────────

export async function sendMessage(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const { content, type } = req.body;

    if (!content || content.trim().length === 0) {
      res.status(400).json({ message: 'Message cannot be empty.' });
      return;
    }

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid conversation ID.' });
      return;
    }

    const conversation = await Conversation.findById(id);
    if (!conversation) {
      res.status(404).json({ message: 'This conversation has ended.' });
      return;
    }

    if (!conversation.participantIds.some((pid: mongoose.Types.ObjectId) => pid.toString() === req.user!._id.toString())) {
      res.status(403).json({ message: 'You are not part of this conversation.' });
      return;
    }

    const message = await Message.create({
      conversationId: id,
      senderId: req.user!._id,
      content: content.trim(),
      type: type || 'text',
      readBy: [req.user!._id],
    });

    // Update conversation last message
    conversation.lastMessage = content.trim().substring(0, 100);
    conversation.lastMessageAt = new Date();

    // Increment unread count for other participant
    const otherId = conversation.participantIds.find(
      (pid: mongoose.Types.ObjectId) => pid.toString() !== req.user!._id.toString()
    );
    if (otherId) {
      const currentUnread = conversation.unreadCounts.get(otherId.toString()) || 0;
      conversation.unreadCounts.set(otherId.toString(), currentUnread + 1);
    }
    await conversation.save();

    const populated = await Message.findById(message._id).populate('senderId', 'displayName username avatarUrl');

    res.status(201).json({ message: formatMessage(populated) });
  } catch (error) {
    console.error('Failed to send message:', error);
    res.status(500).json({ message: 'Could not send your message. Please try again.' });
  }
}
