import { Request, Response } from 'express';
import { Comment } from '../models/Comment.model';
import { Poem } from '../models/Poem.model';
import mongoose from 'mongoose';

// ─────────────────────────────────────────────────────────────────────────────
// CREATE a comment
// ─────────────────────────────────────────────────────────────────────────────

export async function createComment(req: Request, res: Response): Promise<void> {
  try {
    const { targetId, targetType, content, parentCommentId } = req.body;

    if (!targetId || !targetType || !content) {
      res.status(400).json({ message: 'Target, type, and content are required.' });
      return;
    }

    if (content.length > 1000) {
      res.status(400).json({ message: 'Comment is too long. Maximum 1,000 characters.' });
      return;
    }

    if (!mongoose.Types.ObjectId.isValid(targetId)) {
      res.status(400).json({ message: 'Invalid target ID.' });
      return;
    }

    const comment = await Comment.create({
      targetId,
      targetType,
      authorId: req.user!._id,
      content,
      parentCommentId: parentCommentId || null,
    });

    // Increment counter on target
    if (targetType === 'poem') {
      await Poem.findByIdAndUpdate(targetId, { $inc: { commentsCount: 1 } });
    }

    // Populate author info
    const populated = await Comment.findById(comment._id).populate(
      'authorId',
      'displayName username avatarUrl isVerifiedPoet'
    );

    res.status(201).json({ comment: formatComment(populated!) });
  } catch (error) {
    console.error('Failed to create comment:', error);
    res.status(500).json({ message: 'Could not add your words. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET comments for a target
// ─────────────────────────────────────────────────────────────────────────────

export async function getComments(req: Request, res: Response): Promise<void> {
  try {
    const targetId = req.params.targetId as string;
    const { targetType, cursor, limit = '20' } = req.query;

    if (!targetId || !targetType) {
      res.status(400).json({ message: 'Target ID and type are required.' });
      return;
    }

    if (!mongoose.Types.ObjectId.isValid(targetId)) {
      res.status(400).json({ message: 'Invalid target ID.' });
      return;
    }

    const query: Record<string, unknown> = {
      targetId,
      targetType,
      parentCommentId: null, // Only top-level comments
    };

    if (cursor) {
      query.createdAt = { $lt: new Date(cursor as string) };
    }

    const comments = await Comment.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit as string) + 1)
      .populate('authorId', 'displayName username avatarUrl isVerifiedPoet');

    const hasMore = comments.length > parseInt(limit as string);
    if (hasMore) comments.pop();

    const nextCursor = hasMore && comments.length > 0
      ? comments[comments.length - 1].createdAt.toISOString()
      : null;

    res.status(200).json({
      items: comments.map(formatComment),
      nextCursor,
      hasMore,
    });
  } catch (error) {
    console.error('Failed to get comments:', error);
    res.status(500).json({ message: 'Could not fetch comments.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE a comment
// ─────────────────────────────────────────────────────────────────────────────

export async function deleteComment(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid comment ID.' });
      return;
    }

    const comment = await Comment.findById(id);
    if (!comment) {
      res.status(404).json({ message: 'This comment has been taken away.' });
      return;
    }

    // Only the author can delete
    if (comment.authorId.toString() !== req.user!._id) {
      res.status(403).json({ message: 'This is not your comment to delete.' });
      return;
    }

    // Delete all replies first
    await Comment.deleteMany({ parentCommentId: id });

    // Delete the comment
    await Comment.deleteOne({ _id: id });

    // Decrement counter on target
    if (comment.targetType === 'poem') {
      await Poem.findByIdAndUpdate(comment.targetId, { $inc: { commentsCount: -1 } });
    }

    res.status(200).json({ message: 'Your words have returned to silence.' });
  } catch (error) {
    console.error('Failed to delete comment:', error);
    res.status(500).json({ message: 'Could not delete your comment. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: Format comment with author info
// ─────────────────────────────────────────────────────────────────────────────

function formatComment(comment: any) {
  return {
    id: comment._id.toString(),
    targetId: comment.targetId.toString(),
    targetType: comment.targetType,
    author: {
      id: comment.authorId._id.toString(),
      displayName: comment.authorId.displayName,
      username: comment.authorId.username,
      avatarUrl: comment.authorId.avatarUrl,
      isVerifiedPoet: comment.authorId.isVerifiedPoet,
    },
    content: comment.content,
    parentCommentId: comment.parentCommentId?.toString() ?? null,
    likesCount: comment.likesCount,
    createdAt: comment.createdAt,
    updatedAt: comment.updatedAt,
  };
}
