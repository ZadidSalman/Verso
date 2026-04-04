import { Request, Response } from 'express';
import { Like } from '../models/Like.model';
import { Poem } from '../models/Poem.model';
import mongoose from 'mongoose';

// ─────────────────────────────────────────────────────────────────────────────
// LIKE a target
// ─────────────────────────────────────────────────────────────────────────────

export async function likeTarget(req: Request, res: Response): Promise<void> {
  try {
    const { targetId, targetType } = req.body;

    if (!targetId || !targetType) {
      res.status(400).json({ message: 'Target ID and type are required.' });
      return;
    }

    if (!mongoose.Types.ObjectId.isValid(targetId)) {
      res.status(400).json({ message: 'Invalid target ID.' });
      return;
    }

    // Check if already liked
    const existing = await Like.findOne({
      userId: req.user!._id,
      targetId,
      targetType,
    });

    if (existing) {
      res.status(400).json({ message: 'You already liked this.' });
      return;
    }

    // Create like
    await Like.create({
      userId: req.user!._id,
      targetId,
      targetType,
    });

    // Increment counter on target
    if (targetType === 'poem') {
      await Poem.findByIdAndUpdate(targetId, { $inc: { likesCount: 1 } });
    }

    res.status(200).json({ isLiked: true });
  } catch (error) {
    console.error('Failed to like:', error);
    res.status(500).json({ message: 'Could not like this. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UNLIKE a target
// ─────────────────────────────────────────────────────────────────────────────

export async function unlikeTarget(req: Request, res: Response): Promise<void> {
  try {
    const { targetId } = req.params;
    const { targetType } = req.query;

    if (!targetId || !targetType) {
      res.status(400).json({ message: 'Target ID and type are required.' });
      return;
    }

    if (!mongoose.Types.ObjectId.isValid(targetId)) {
      res.status(400).json({ message: 'Invalid target ID.' });
      return;
    }

    const deleted = await Like.findOneAndDelete({
      userId: req.user!._id,
      targetId,
      targetType,
    });

    if (!deleted) {
      res.status(404).json({ message: 'You have not liked this yet.' });
      return;
    }

    // Decrement counter on target
    if (targetType === 'poem') {
      await Poem.findByIdAndUpdate(targetId, { $inc: { likesCount: -1 } });
    }

    res.status(200).json({ isLiked: false });
  } catch (error) {
    console.error('Failed to unlike:', error);
    res.status(500).json({ message: 'Could not unlike. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK if user liked a target
// ─────────────────────────────────────────────────────────────────────────────

export async function getLikeStatus(req: Request, res: Response): Promise<void> {
  try {
    const { targetId } = req.params;
    const { targetType } = req.query;

    if (!targetId || !targetType) {
      res.status(400).json({ message: 'Target ID and type are required.' });
      return;
    }

    if (!mongoose.Types.ObjectId.isValid(targetId)) {
      res.status(400).json({ message: 'Invalid target ID.' });
      return;
    }

    const like = await Like.findOne({
      userId: req.user!._id,
      targetId,
      targetType,
    });

    res.status(200).json({ isLiked: !!like });
  } catch (error) {
    console.error('Failed to get like status:', error);
    res.status(500).json({ message: 'Could not check like status.' });
  }
}
