import { Request, Response } from 'express';
import { Poem, IPoem } from '../models/Poem.model';
import { User } from '../models/User.model';
import mongoose from 'mongoose';

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: Populate poem with author info
// ─────────────────────────────────────────────────────────────────────────────

function poemWithAuthor(poem: IPoem) {
  return {
    id: poem._id.toString(),
    authorId: poem.authorId.toString(),
    title: poem.title,
    content: poem.content,
    slug: poem.slug,
    language: poem.language,
    mood: poem.mood,
    tags: poem.tags,
    category: poem.category,
    genre: poem.genre,
    isAnonymous: poem.isAnonymous,
    isUnsent: poem.isUnsent,
    unsentTo: poem.unsentTo,
    status: poem.status,
    audioUrl: poem.audioUrl,
    videoUrl: poem.videoUrl,
    coverImageUrl: poem.coverImageUrl,
    likesCount: poem.likesCount,
    commentsCount: poem.commentsCount,
    savesCount: poem.savesCount,
    readsCount: poem.readsCount,
    trendingScore: poem.trendingScore,
    wordCount: poem.wordCount,
    lineCount: poem.lineCount,
    publishedAt: poem.publishedAt,
    createdAt: poem.createdAt,
    updatedAt: poem.updatedAt,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE a poem
// ─────────────────────────────────────────────────────────────────────────────

export async function createPoem(req: Request, res: Response): Promise<void> {
  try {
    const {
      title,
      content,
      language,
      mood,
      tags,
      category,
      genre,
      isAnonymous,
      isUnsent,
      unsentTo,
      status,
    } = req.body;

    if (!title || !content) {
      res.status(400).json({ message: 'Title and content are required.' });
      return;
    }

    if (content.length > 10000) {
      res.status(400).json({ message: 'Poem is too long. Maximum 10,000 characters.' });
      return;
    }

    const poem = await Poem.create({
      authorId: req.user!._id,
      title,
      content,
      language: language || 'en',
      mood: mood || [],
      tags: tags || [],
      category,
      genre,
      isAnonymous: isAnonymous || false,
      isUnsent: isUnsent || false,
      unsentTo,
      status: status || 'draft',
    });

    // Increment user's poem count
    await User.findByIdAndUpdate(req.user!._id, { $inc: { poemsCount: 1 } });

    const populated = await Poem.findById(poem._id).select('-__v');
    if (!populated) {
      res.status(500).json({ message: 'Failed to retrieve created poem.' });
      return;
    }

    res.status(201).json({ poem: poemWithAuthor(populated) });
  } catch (error) {
    console.error('Failed to create poem:', error);
    res.status(500).json({ message: 'Could not save your words. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET a single poem by ID
// ─────────────────────────────────────────────────────────────────────────────

export async function getPoem(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid poem ID.' });
      return;
    }

    const poem = await Poem.findById(id);
    if (!poem) {
      res.status(404).json({ message: 'This poem has been taken away.' });
      return;
    }

    // Only show published poems to non-authors
    if (poem.status !== 'published' && req.user?._id !== poem.authorId.toString()) {
      res.status(404).json({ message: 'This poem has been taken away.' });
      return;
    }

    res.status(200).json({ poem: poemWithAuthor(poem) });
  } catch (error) {
    console.error('Failed to get poem:', error);
    res.status(500).json({ message: 'Could not find this poem.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPDATE a poem (author only)
// ─────────────────────────────────────────────────────────────────────────────

export async function updatePoem(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid poem ID.' });
      return;
    }

    const poem = await Poem.findById(id);
    if (!poem) {
      res.status(404).json({ message: 'This poem has been taken away.' });
      return;
    }

    // Only the author can update
    if (poem.authorId.toString() !== req.user!._id) {
      res.status(403).json({ message: 'This is not your poem to edit.' });
      return;
    }

    const allowedUpdates = [
      'title', 'content', 'language', 'mood', 'tags',
      'category', 'genre', 'isAnonymous', 'isUnsent', 'unsentTo', 'status',
    ];

    const updates: Record<string, unknown> = {};
    for (const key of allowedUpdates) {
      if (req.body[key] !== undefined) {
        updates[key] = req.body[key];
      }
    }

    // Validate content length if updating
    if (updates.content && (updates.content as string).length > 10000) {
      res.status(400).json({ message: 'Poem is too long. Maximum 10,000 characters.' });
      return;
    }

    Object.assign(poem, updates);
    await poem.save();

    res.status(200).json({ poem: poemWithAuthor(poem), message: 'Your words have been reshaped.' });
  } catch (error) {
    console.error('Failed to update poem:', error);
    res.status(500).json({ message: 'Could not update your poem. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE a poem (author only)
// ─────────────────────────────────────────────────────────────────────────────

export async function deletePoem(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid poem ID.' });
      return;
    }

    const poem = await Poem.findById(id);
    if (!poem) {
      res.status(404).json({ message: 'This poem has been taken away.' });
      return;
    }

    // Only the author can delete
    if (poem.authorId.toString() !== req.user!._id) {
      res.status(403).json({ message: 'This is not your poem to delete.' });
      return;
    }

    await Poem.deleteOne({ _id: id });

    // Decrement user's poem count
    await User.findByIdAndUpdate(req.user!._id, { $inc: { poemsCount: -1 } });

    res.status(200).json({ message: 'Your poem has been returned to the silence.' });
  } catch (error) {
    console.error('Failed to delete poem:', error);
    res.status(500).json({ message: 'Could not delete your poem. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PUBLISH a draft poem
// ─────────────────────────────────────────────────────────────────────────────

export async function publishPoem(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid poem ID.' });
      return;
    }

    const poem = await Poem.findById(id);
    if (!poem) {
      res.status(404).json({ message: 'This poem has been taken away.' });
      return;
    }

    // Only the author can publish
    if (poem.authorId.toString() !== req.user!._id) {
      res.status(403).json({ message: 'This is not your poem to publish.' });
      return;
    }

    if (poem.status === 'published') {
      res.status(400).json({ message: 'This poem is already published.' });
      return;
    }

    poem.status = 'published';
    poem.publishedAt = new Date();
    await poem.save();

    res.status(200).json({ poem: poemWithAuthor(poem), message: 'Your words are now in the world.' });
  } catch (error) {
    console.error('Failed to publish poem:', error);
    res.status(500).json({ message: 'Could not publish your poem. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET all poems by username
// ─────────────────────────────────────────────────────────────────────────────

export async function getPoemsByUsername(req: Request, res: Response): Promise<void> {
  try {
    const { username } = req.params;
    const { limit = '20', cursor } = req.query;

    const user = await User.findOne({ username: username.toLowerCase() });
    if (!user) {
      res.status(404).json({ message: 'This poet has not been found.' });
      return;
    }

    const query: Record<string, unknown> = {
      authorId: user._id,
      status: 'published',
    };

    if (cursor) {
      query.publishedAt = { $lt: new Date(cursor as string) };
    }

    const poems = await Poem.find(query)
      .sort({ publishedAt: -1 })
      .limit(parseInt(limit as string) + 1)
      .select('-__v');

    const hasMore = poems.length > parseInt(limit as string);
    if (hasMore) poems.pop();

    const nextCursor = hasMore && poems.length > 0
      ? poems[poems.length - 1].publishedAt?.toISOString() ?? null
      : null;

    res.status(200).json({
      items: poems.map(poemWithAuthor),
      nextCursor,
      hasMore,
    });
  } catch (error) {
    console.error('Failed to get poems by username:', error);
    res.status(500).json({ message: 'Could not find these poems.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INCREMENT reads count (public, called after 5s dwell)
// ─────────────────────────────────────────────────────────────────────────────

export async function trackRead(req: Request, res: Response): Promise<void> {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid poem ID.' });
      return;
    }

    await Poem.findByIdAndUpdate(id, { $inc: { readsCount: 1 } });

    res.status(200).json({ message: 'ok' });
  } catch (error) {
    console.error('Failed to track read:', error);
    res.status(500).json({ message: 'Could not track read.' });
  }
}
