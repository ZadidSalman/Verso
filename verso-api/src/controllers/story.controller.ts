import { Request, Response } from 'express';
import { Story } from '../models/Story.model';
import { StoryPart } from '../models/StoryPart.model';
import mongoose from 'mongoose';

function storyWithAuthor(story: any) {
  return {
    id: story._id.toString(),
    authorId: story.authorId.toString(),
    author: story.authorId
      ? {
          displayName: story.authorId.displayName,
          username: story.authorId.username,
          avatarUrl: story.authorId.avatarUrl,
          isVerifiedPoet: story.authorId.isVerifiedPoet,
        }
      : null,
    title: story.title,
    description: story.description,
    coverImageUrl: story.coverImageUrl,
    language: story.language,
    mood: story.mood,
    tags: story.tags,
    genre: story.genre,
    isCollab: story.isCollab,
    collabMode: story.collabMode,
    storyMode: story.storyMode,
    status: story.status,
    partsCount: story.partsCount,
    followersCount: story.followersCount,
    totalReads: story.totalReads,
    trendingScore: story.trendingScore,
    publishedAt: story.publishedAt,
    lastPartAt: story.lastPartAt,
    createdAt: story.createdAt,
    updatedAt: story.updatedAt,
  };
}

function partWithAuthor(part: any) {
  return {
    id: part._id.toString(),
    storyId: part.storyId.toString(),
    authorId: part.authorId.toString(),
    author: part.authorId
      ? {
          displayName: part.authorId.displayName,
          username: part.authorId.username,
          avatarUrl: part.authorId.avatarUrl,
          isVerifiedPoet: part.authorId.isVerifiedPoet,
        }
      : null,
    partNumber: part.partNumber,
    title: part.title,
    content: part.content,
    coverImageUrl: part.coverImageUrl,
    language: part.language,
    mood: part.mood,
    parentPartId: part.parentPartId?.toString() ?? null,
    branchLabel: part.branchLabel,
    status: part.status,
    isCollabContribution: part.isCollabContribution,
    likesCount: part.likesCount,
    commentsCount: part.commentsCount,
    readsCount: part.readsCount,
    publishedAt: part.publishedAt,
    createdAt: part.createdAt,
    updatedAt: part.updatedAt,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE a story
// ─────────────────────────────────────────────────────────────────────────────

export async function createStory(req: Request, res: Response): Promise<void> {
  try {
    const { title, description, language, mood, tags, genre, isCollab, collabMode, storyMode } = req.body;

    if (!title) {
      res.status(400).json({ message: 'Title is required.' });
      return;
    }

    const story = await Story.create({
      authorId: req.user!._id,
      title,
      description: description || '',
      language: language || 'en',
      mood: mood || [],
      tags: tags || [],
      genre,
      isCollab: isCollab || false,
      collabMode: collabMode || 'none',
      storyMode: storyMode || 'linear',
      status: 'ongoing',
    });

    const populated = await Story.findById(story._id).populate('authorId', 'displayName username avatarUrl isVerifiedPoet');
    res.status(201).json({ story: storyWithAuthor(populated) });
  } catch (error) {
    console.error('Failed to create story:', error);
    res.status(500).json({ message: 'Could not create your story. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET a story by ID
// ─────────────────────────────────────────────────────────────────────────────

export async function getStory(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid story ID.' });
      return;
    }

    const story = await Story.findById(id).populate('authorId', 'displayName username avatarUrl isVerifiedPoet');
    if (!story) {
      res.status(404).json({ message: 'This story has been taken away.' });
      return;
    }

    res.status(200).json({ story: storyWithAuthor(story) });
  } catch (error) {
    console.error('Failed to get story:', error);
    res.status(500).json({ message: 'Could not find this story.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET all parts of a story
// ─────────────────────────────────────────────────────────────────────────────

export async function getStoryParts(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid story ID.' });
      return;
    }

    const parts = await StoryPart.find({ storyId: id, status: 'published' })
      .sort({ partNumber: 1 })
      .populate('authorId', 'displayName username avatarUrl isVerifiedPoet');

    res.status(200).json({ parts: parts.map(partWithAuthor) });
  } catch (error) {
    console.error('Failed to get story parts:', error);
    res.status(500).json({ message: 'Could not find story parts.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET a single story part
// ─────────────────────────────────────────────────────────────────────────────

export async function getStoryPart(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;
    const partId = req.params.partId as string;
    if (!mongoose.Types.ObjectId.isValid(id) || !mongoose.Types.ObjectId.isValid(partId)) {
      res.status(400).json({ message: 'Invalid ID.' });
      return;
    }

    const part = await StoryPart.findOne({ _id: partId, storyId: id, status: 'published' })
      .populate('authorId', 'displayName username avatarUrl isVerifiedPoet');

    if (!part) {
      res.status(404).json({ message: 'This part has been taken away.' });
      return;
    }

    // Get prev/next parts
    const prevPart = await StoryPart.findOne({ storyId: id, partNumber: part.partNumber - 1, status: 'published' });
    const nextPart = await StoryPart.findOne({ storyId: id, partNumber: part.partNumber + 1, status: 'published' });

    res.status(200).json({
      part: partWithAuthor(part),
      prevPartId: prevPart?._id.toString() ?? null,
      nextPartId: nextPart?._id.toString() ?? null,
    });
  } catch (error) {
    console.error('Failed to get story part:', error);
    res.status(500).json({ message: 'Could not find this part.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD a part to a story
// ─────────────────────────────────────────────────────────────────────────────

export async function addStoryPart(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;
    const { title, content, language, mood, coverImageUrl, parentPartId, branchLabel, status } = req.body;

    if (!title || !content) {
      res.status(400).json({ message: 'Title and content are required.' });
      return;
    }

    const story = await Story.findById(id);
    if (!story) {
      res.status(404).json({ message: 'This story has been taken away.' });
      return;
    }

    const partNumber = (story.partsCount || 0) + 1;

    const part = await StoryPart.create({
      storyId: id,
      authorId: req.user!._id,
      partNumber,
      title,
      content,
      language: language || story.language,
      mood: mood || [],
      coverImageUrl,
      parentPartId,
      branchLabel,
      status: status || 'draft',
    });

    // Update story counters
    await Story.findByIdAndUpdate(id, {
      $inc: { partsCount: 1 },
      lastPartAt: new Date(),
    });

    const populated = await StoryPart.findById(part._id).populate('authorId', 'displayName username avatarUrl isVerifiedPoet');
    res.status(201).json({ part: partWithAuthor(populated) });
  } catch (error) {
    console.error('Failed to add story part:', error);
    res.status(500).json({ message: 'Could not add this part. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET trending stories
// ─────────────────────────────────────────────────────────────────────────────

export async function getTrendingStories(req: Request, res: Response): Promise<void> {
  try {
    const { limit = '10', cursor } = req.query;

    const query: Record<string, unknown> = { status: 'ongoing' };
    if (cursor) {
      query.publishedAt = { $lt: new Date(cursor as string) };
    }

    const stories = await Story.find(query)
      .sort({ trendingScore: -1, lastPartAt: -1 })
      .limit(parseInt(limit as string) + 1)
      .populate('authorId', 'displayName username avatarUrl isVerifiedPoet');

    const hasMore = stories.length > parseInt(limit as string);
    if (hasMore) stories.pop();

    const nextCursor = hasMore && stories.length > 0
      ? stories[stories.length - 1].publishedAt?.toISOString() ?? null
      : null;

    res.status(200).json({
      items: stories.map(storyWithAuthor),
      nextCursor,
      hasMore,
    });
  } catch (error) {
    console.error('Failed to get trending stories:', error);
    res.status(500).json({ message: 'Could not find trending stories.' });
  }
}
