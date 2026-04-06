import mongoose from 'mongoose';
import { sendPushNotification } from './fcm.service';

// ─────────────────────────────────────────────────────────────────────────
// Minimal inline schemas — these mirror the real Mongoose models.
// We import the real models in production; these are here so the service
// can compile without circular deps.
// ─────────────────────────────────────────────────────────────────────────

const UserSchema = new mongoose.Schema({
  fcmTokens: [String],
  email: String,
  username: String,
  displayName: String,
  lastPushAt: Date,
});

const NotificationSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  type: String,
  title: String,
  body: String,
  data: mongoose.Schema.Types.Mixed,
  read: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

const User = mongoose.models.User || mongoose.model('User', UserSchema);
const Notification =
  mongoose.models.Notification ||
  mongoose.model('Notification', NotificationSchema);

// ─────────────────────────────────────────────────────────────────────────
// Notification types
// ─────────────────────────────────────────────────────────────────────────

export type NotificationType =
  | 'like'
  | 'comment'
  | 'follow'
  | 'mention'
  | 'message'
  | 'collab_invite'
  | 'duel_challenge'
  | 'system';

// Minimum interval between pushes to the same user (5 minutes)
const PUSH_COOLDOWN_MS = 5 * 60 * 1000;

/**
 * Create an in-app notification record and optionally send a push.
 *
 * Respects a 5-minute cooldown per user to avoid spam.
 */
export async function createNotification(params: {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, string>;
}): Promise<void> {
  const { userId, type, title, body, data } = params;

  // Persist in-app notification
  await Notification.create({
    user: new mongoose.Types.ObjectId(userId),
    type,
    title,
    body,
    data,
  });

  // Check cooldown
  const user = await User.findById(userId).lean() as any;
  if (!user) return;

  if (
    user.lastPushAt &&
    Date.now() - new Date(user.lastPushAt).getTime() < PUSH_COOLDOWN_MS
  ) {
    return; // still in cooldown
  }

  // Collect valid FCM tokens
  const tokens: string[] = (user.fcmTokens ?? []).filter(Boolean);
  if (tokens.length === 0) return;

  // Send push to the most recent token only (avoid duplicate deliveries)
  const latestToken = tokens[tokens.length - 1];

  try {
    const ok = await sendPushNotification(latestToken, title, body, {
      type,
      ...(data ?? {}),
    });

    if (ok) {
      await User.findByIdAndUpdate(userId, { lastPushAt: new Date() });
    }
  } catch (err: any) {
    if (err.message === 'INVALID_TOKEN') {
      // Remove stale token
      await User.findByIdAndUpdate(userId, {
        $pull: { fcmTokens: latestToken },
      });
    }
  }
}

/**
 * Convenience: notify on poem like.
 */
export async function notifyLike(
  poemAuthorId: string,
  likerUsername: string,
  poemId: string,
): Promise<void> {
  await createNotification({
    userId: poemAuthorId,
    type: 'like',
    title: 'A heart found your verse',
    body: `${likerUsername} liked your poem.`,
    data: { poemId },
  });
}

/**
 * Convenience: notify on comment.
 */
export async function notifyComment(
  poemAuthorId: string,
  commenterUsername: string,
  poemId: string,
): Promise<void> {
  await createNotification({
    userId: poemAuthorId,
    type: 'comment',
    title: 'Words echoed yours',
    body: `${commenterUsername} commented on your poem.`,
    data: { poemId },
  });
}

/**
 * Convenience: notify on follow.
 */
export async function notifyFollow(
  followedUserId: string,
  followerUsername: string,
): Promise<void> {
  await createNotification({
    userId: followedUserId,
    type: 'follow',
    title: 'A new reader joins your circle',
    body: `${followerUsername} started following you.`,
    data: { username: followerUsername },
  });
}

/**
 * Convenience: notify on direct message.
 */
export async function notifyMessage(
  recipientId: string,
  senderUsername: string,
  conversationId: string,
): Promise<void> {
  await createNotification({
    userId: recipientId,
    type: 'message',
    title: 'A letter arrived',
    body: `${senderUsername} sent you a message.`,
    data: { conversationId },
  });
}
