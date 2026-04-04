import { Request, Response } from 'express';
import { Follow } from '../models/Follow.model';
import { User } from '../models/User.model';
import mongoose from 'mongoose';

// ─────────────────────────────────────────────────────────────────────────────
// FOLLOW a user
// ─────────────────────────────────────────────────────────────────────────────

export async function followUser(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const followerId = req.user!._id;

    // Can't follow yourself
    if (followerId === id) {
      res.status(400).json({ message: 'You cannot follow yourself.' });
      return;
    }

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid user ID.' });
      return;
    }

    // Check if user exists
    const targetUser = await User.findById(id);
    if (!targetUser) {
      res.status(404).json({ message: 'This poet has not been found.' });
      return;
    }

    // Check if already following
    const existing = await Follow.findOne({ followerId, followingId: id });
    if (existing) {
      res.status(400).json({ message: 'You are already following this poet.' });
      return;
    }

    // Create follow relationship
    const follow = await Follow.create({
      followerId,
      followingId: id,
      isMutual: false,
    });

    // Check for reverse follow (mutual)
    const reverseFollow = await Follow.findOne({
      followerId: id,
      followingId: followerId,
    });

    let isMutual = false;
    if (reverseFollow) {
      isMutual = true;
      await Follow.updateOne(
        { _id: reverseFollow._id },
        { $set: { isMutual: true } }
      );
      await Follow.updateOne(
        { _id: follow._id },
        { $set: { isMutual: true } }
      );
    }

    // Increment counts
    await User.findByIdAndUpdate(followerId, { $inc: { followingCount: 1 } });
    await User.findByIdAndUpdate(id, { $inc: { followersCount: 1 } });

    res.status(201).json({
      isFollowing: true,
      isMutual,
      followersCount: targetUser.followersCount + 1,
    });
  } catch (error) {
    console.error('Failed to follow user:', error);
    res.status(500).json({ message: 'Could not follow this poet. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UNFOLLOW a user
// ─────────────────────────────────────────────────────────────────────────────

export async function unfollowUser(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const followerId = req.user!._id;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid user ID.' });
      return;
    }

    // Delete follow relationship
    const deleted = await Follow.findOneAndDelete({
      followerId,
      followingId: id,
    });

    if (!deleted) {
      res.status(404).json({ message: 'You are not following this poet.' });
      return;
    }

    // If was mutual, set reverse follow to non-mutual
    if (deleted.isMutual) {
      await Follow.updateOne(
        { followerId: id, followingId: followerId },
        { $set: { isMutual: false } }
      );
    }

    // Decrement counts
    await User.findByIdAndUpdate(followerId, { $inc: { followingCount: -1 } });
    await User.findByIdAndUpdate(id, { $inc: { followersCount: -1 } });

    res.status(200).json({
      isFollowing: false,
      isMutual: false,
    });
  } catch (error) {
    console.error('Failed to unfollow user:', error);
    res.status(500).json({ message: 'Could not unfollow. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK follow status
// ─────────────────────────────────────────────────────────────────────────────

export async function getFollowStatus(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const followerId = req.user!._id;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid user ID.' });
      return;
    }

    const follow = await Follow.findOne({
      followerId,
      followingId: id,
    });

    res.status(200).json({
      isFollowing: !!follow,
      isMutual: follow?.isMutual ?? false,
    });
  } catch (error) {
    console.error('Failed to get follow status:', error);
    res.status(500).json({ message: 'Could not check follow status.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET followers list
// ─────────────────────────────────────────────────────────────────────────────

export async function getFollowers(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const { limit = '20', cursor } = req.query;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid user ID.' });
      return;
    }

    const query: Record<string, unknown> = { followingId: id };
    if (cursor) {
      query.createdAt = { $lt: new Date(cursor as string) };
    }

    const follows = await Follow.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit as string) + 1)
      .populate('followerId', 'displayName username avatarUrl isVerifiedPoet');

    const hasMore = follows.length > parseInt(limit as string);
    if (hasMore) follows.pop();

    const nextCursor = hasMore && follows.length > 0
      ? follows[follows.length - 1].createdAt.toISOString()
      : null;

    res.status(200).json({
      items: follows.map((f) => ({
        user: f.followerId,
        followedAt: f.createdAt,
        isMutual: f.isMutual,
      })),
      nextCursor,
      hasMore,
    });
  } catch (error) {
    console.error('Failed to get followers:', error);
    res.status(500).json({ message: 'Could not fetch followers.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET following list
// ─────────────────────────────────────────────────────────────────────────────

export async function getFollowing(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;
    const { limit = '20', cursor } = req.query;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid user ID.' });
      return;
    }

    const query: Record<string, unknown> = { followerId: id };
    if (cursor) {
      query.createdAt = { $lt: new Date(cursor as string) };
    }

    const follows = await Follow.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit as string) + 1)
      .populate('followingId', 'displayName username avatarUrl isVerifiedPoet');

    const hasMore = follows.length > parseInt(limit as string);
    if (hasMore) follows.pop();

    const nextCursor = hasMore && follows.length > 0
      ? follows[follows.length - 1].createdAt.toISOString()
      : null;

    res.status(200).json({
      items: follows.map((f) => ({
        user: f.followingId,
        followedAt: f.createdAt,
        isMutual: f.isMutual,
      })),
      nextCursor,
      hasMore,
    });
  } catch (error) {
    console.error('Failed to get following:', error);
    res.status(500).json({ message: 'Could not fetch following.' });
  }
}
