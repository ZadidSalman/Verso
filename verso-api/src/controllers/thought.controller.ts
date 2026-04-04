import { Request, Response } from 'express';
import { Thought } from '../models/Thought.model';

// ─────────────────────────────────────────────────────────────────────────────
// Create a thought
// ─────────────────────────────────────────────────────────────────────────────

export async function createThought(
  req: Request,
  res: Response
): Promise<void> {
  try {
    const userId = req.user!._id;
    const { content, visibility = 'public' } = req.body;

    if (!content || content.trim().length === 0) {
      res.status(400).json({ error: 'Content is required' });
      return;
    }

    if (content.length > 280) {
      res.status(400).json({ error: 'Thought must be 280 characters or less' });
      return;
    }

    const thought = await Thought.create({
      authorId: userId,
      content: content.trim(),
      visibility,
    });

    res.status(201).json({ thought });
  } catch (error) {
    console.error('[Thought] Create error:', error);
    res.status(500).json({ error: 'Failed to create thought' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Get thoughts (for feed/discover)
// ─────────────────────────────────────────────────────────────────────────────

export async function getThoughts(
  req: Request,
  res: Response
): Promise<void> {
  try {
    const { cursor, limit = '20', visibility } = req.query;
    const limitNum = Math.min(parseInt(limit as string) || 20, 50);
    const userId = req.user?._id;

    // Build query
    const query: Record<string, unknown> = {};

    // If not authenticated, only show public
    if (!userId) {
      query.visibility = 'public';
    } else if (visibility) {
      query.visibility = visibility;
    } else {
      // Show public + mutual (people I follow who follow me)
      query.$or = [
        { visibility: 'public' },
        { visibility: 'mutual', authorId: userId },
      ];
    }

    // Cursor pagination
    if (cursor) {
      query.createdAt = { $lt: new Date(cursor as string) };
    }

    const thoughts = await Thought.find(query)
      .sort({ createdAt: -1 })
      .limit(limitNum + 1)
      .populate('authorId', 'displayName username avatarUrl isVerifiedPoet')
      .lean();

    const hasMore = thoughts.length > limitNum;
    if (hasMore) thoughts.pop();

    res.json({
      items: thoughts,
      nextCursor: hasMore ? thoughts[thoughts.length - 1].createdAt : null,
      hasMore,
    });
  } catch (error) {
    console.error('[Thought] Get error:', error);
    res.status(500).json({ error: 'Failed to fetch thoughts' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Get current user's thoughts (for profile)
// ─────────────────────────────────────────────────────────────────────────────

export async function getMyThoughts(
  req: Request,
  res: Response
): Promise<void> {
  try {
    const userId = req.user!._id;
    const { cursor, limit = '20' } = req.query;
    const limitNum = Math.min(parseInt(limit as string) || 20, 50);

    const query: Record<string, unknown> = { authorId: userId };

    if (cursor) {
      query.createdAt = { $lt: new Date(cursor as string) };
    }

    const thoughts = await Thought.find(query)
      .sort({ createdAt: -1 })
      .limit(limitNum + 1)
      .lean();

    const hasMore = thoughts.length > limitNum;
    if (hasMore) thoughts.pop();

    res.json({
      items: thoughts,
      nextCursor: hasMore ? thoughts[thoughts.length - 1].createdAt : null,
      hasMore,
    });
  } catch (error) {
    console.error('[Thought] Get my thoughts error:', error);
    res.status(500).json({ error: 'Failed to fetch thoughts' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete a thought
// ─────────────────────────────────────────────────────────────────────────────

export async function deleteThought(
  req: Request,
  res: Response
): Promise<void> {
  try {
    const userId = req.user!._id;
    const { id } = req.params;

    const thought = await Thought.findOne({ _id: id, authorId: userId });

    if (!thought) {
      res.status(404).json({ error: 'Thought not found' });
      return;
    }

    await thought.deleteOne();
    res.json({ message: 'Thought deleted' });
  } catch (error) {
    console.error('[Thought] Delete error:', error);
    res.status(500).json({ error: 'Failed to delete thought' });
  }
}
