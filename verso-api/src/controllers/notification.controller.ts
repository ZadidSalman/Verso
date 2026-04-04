import { Request, Response } from 'express';
import { Notification } from '../models/Notification.model';
import mongoose from 'mongoose';

const POETIC_MESSAGES: Record<string, string> = {
  poem_liked: 'Someone paused on your poem tonight.',
  storyPart_liked: 'A reader stopped at your chapter.',
  thought_reacted: 'Your thought touched someone.',
  comment: 'Someone added a voice to your poem.',
  comment_story: 'A reader left a note in the margins of your chapter.',
  new_follower: 'A new reader has found their way to your words.',
  duel_invite: 'A poet has challenged you to a duel.',
  duel_result: 'The readers have spoken. See how your poem fared.',
  stanza_added: 'Someone left a line for your poem.',
  new_story_part: 'A new chapter has arrived. The story continues.',
  story_collab_invite: "You've been invited to write part of a story.",
};

// ─────────────────────────────────────────────────────────────────────────────
// CREATE a notification (internal helper, not exposed as route)
// ─────────────────────────────────────────────────────────────────────────────

export async function createNotification({
  recipientId,
  type,
  actorId,
  entityId,
  entityType,
}: {
  recipientId: string;
  type: string;
  actorId: string;
  entityId?: string;
  entityType?: string;
}) {
  const poeticMessage = POETIC_MESSAGES[type] ?? '';

  return Notification.create({
    recipientId,
    type,
    actorId,
    ...(entityId ? { entityId } : {}),
    ...(entityType ? { entityType } : {}),
    poeticMessage,
    isRead: false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// GET notifications for current user
// ─────────────────────────────────────────────────────────────────────────────

export async function getNotifications(req: Request, res: Response): Promise<void> {
  try {
    const { cursor, limit = '20' } = req.query;

    const query: Record<string, unknown> = { recipientId: req.user!._id };
    if (cursor) {
      query.createdAt = { $lt: new Date(cursor as string) };
    }

    const notifications = await Notification.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit as string) + 1)
      .populate('actorId', 'displayName username avatarUrl');

    const hasMore = notifications.length > parseInt(limit as string);
    if (hasMore) notifications.pop();

    const nextCursor = hasMore && notifications.length > 0
      ? notifications[notifications.length - 1].createdAt.toISOString()
      : null;

    const unreadCount = await Notification.countDocuments({
      recipientId: req.user!._id,
      isRead: false,
    });

    res.status(200).json({
      items: notifications.map(formatNotification),
      nextCursor,
      hasMore,
      unreadCount,
    });
  } catch (error) {
    console.error('Failed to get notifications:', error);
    res.status(500).json({ message: 'Could not fetch your alerts.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK ALL as read
// ─────────────────────────────────────────────────────────────────────────────

export async function markAllAsRead(req: Request, res: Response): Promise<void> {
  try {
    await Notification.updateMany(
      { recipientId: req.user!._id, isRead: false },
      { $set: { isRead: true } }
    );

    res.status(200).json({ message: 'All alerts have been heard.' });
  } catch (error) {
    console.error('Failed to mark all read:', error);
    res.status(500).json({ message: 'Could not mark alerts as read.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK SINGLE as read
// ─────────────────────────────────────────────────────────────────────────────

export async function markAsRead(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid notification ID.' });
      return;
    }

    await Notification.updateOne(
      { _id: id, recipientId: req.user!._id },
      { $set: { isRead: true } }
    );

    res.status(200).json({ message: 'ok' });
  } catch (error) {
    console.error('Failed to mark as read:', error);
    res.status(500).json({ message: 'Could not mark notification as read.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER
// ─────────────────────────────────────────────────────────────────────────────

function formatNotification(n: any) {
  return {
    id: n._id.toString(),
    recipientId: n.recipientId.toString(),
    type: n.type,
    actorId: n.actorId._id.toString(),
    actor: {
      displayName: n.actorId.displayName,
      username: n.actorId.username,
      avatarUrl: n.actorId.avatarUrl,
    },
    entityId: n.entityId?.toString() ?? null,
    entityType: n.entityType,
    poeticMessage: n.poeticMessage,
    isRead: n.isRead,
    createdAt: n.createdAt,
  };
}
