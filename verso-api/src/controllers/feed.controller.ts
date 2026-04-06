import { Request, Response } from 'express';
import mongoose from 'mongoose';
import { Poem, IPoem } from '../models/Poem.model';
import { Story, IStory } from '../models/Story.model';
import { Thought, IThought } from '../models/Thought.model';
import { User } from '../models/User.model';

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

function poemWithAuthor(poem: IPoem, author: {
  displayName?: string;
  username?: string;
  avatarUrl?: string;
  isVerifiedPoet: boolean;
}) {
  return {
    id: poem._id.toString(),
    type: 'poem',
    authorId: poem.authorId.toString(),
    author: {
      displayName: poem.isAnonymous ? 'Anonymous' : (author.displayName || author.username || 'Unknown'),
      username: poem.isAnonymous ? undefined : (author.username || 'unknown'),
      avatarUrl: poem.isAnonymous ? undefined : author.avatarUrl,
      isVerifiedPoet: author.isVerifiedPoet,
    },
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

function storyWithAuthor(story: IStory, author: {
  displayName?: string;
  username?: string;
  avatarUrl?: string;
  isVerifiedPoet: boolean;
}) {
  return {
    id: story._id.toString(),
    type: 'story',
    authorId: story.authorId.toString(),
    author: {
      displayName: author.displayName || author.username || 'Unknown',
      username: author.username || 'unknown',
      avatarUrl: author.avatarUrl,
      isVerifiedPoet: author.isVerifiedPoet,
    },
    title: story.title,
    description: story.description,
    coverImageUrl: story.coverImageUrl,
    language: story.language,
    mood: story.mood,
    tags: story.tags,
    genre: story.genre,
    status: story.status,
    partsCount: story.partsCount,
    followersCount: story.followersCount,
    totalReads: story.totalReads,
    trendingScore: story.trendingScore,
    publishedAt: story.publishedAt,
    createdAt: story.createdAt,
    updatedAt: story.updatedAt,
  };
}

function thoughtWithAuthor(thought: IThought, author: {
  displayName?: string;
  username?: string;
  avatarUrl?: string;
  isVerifiedPoet: boolean;
}) {
  return {
    id: thought._id.toString(),
    type: 'thought',
    authorId: thought.authorId.toString(),
    author: {
      displayName: author.displayName || author.username || 'Unknown',
      username: author.username || 'unknown',
      avatarUrl: author.avatarUrl,
      isVerifiedPoet: author.isVerifiedPoet,
    },
    content: thought.content,
    visibility: thought.visibility,
    likesCount: thought.likesCount,
    createdAt: thought.createdAt,
    updatedAt: thought.updatedAt,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// GET mixed feed (poems + stories + thoughts)
// ─────────────────────────────────────────────────────────────────────────────

interface FeedItem {
  type: 'poem' | 'story' | 'thought';
  _id: mongoose.Types.ObjectId;
  authorId: mongoose.Types.ObjectId;
  publishedAt?: Date;
  createdAt: Date;
  trendingScore: number;
}

export async function getFeed(req: Request, res: Response): Promise<void> {
  try {
    const {
      cursor,
      limit = '20',
      mood,
      language,
      type,
    } = req.query;

    const limitNum = Math.min(parseInt(limit as string) || 20, 50);

    // Build queries
    const poemQuery: Record<string, unknown> = { status: 'published' };
    const storyQuery: Record<string, unknown> = { status: { $in: ['ongoing', 'completed'] } };
    const thoughtQuery: Record<string, unknown> = { visibility: 'public' };

    if (mood) {
      const moods = (mood as string).split(',');
      poemQuery.mood = { $in: moods };
      storyQuery.mood = { $in: moods };
    }

    if (language) {
      poemQuery.language = language;
      storyQuery.language = language;
      thoughtQuery.language = language;
    }

    // Type filters
    if (type === 'poems') {
      Object.assign(storyQuery, { status: { $exists: false } });
    }

    // Cursor pagination
    if (cursor) {
      const cursorDate = new Date(cursor as string);
      poemQuery.publishedAt = { $lt: cursorDate };
      storyQuery.publishedAt = { $lt: cursorDate };
      thoughtQuery.createdAt = { $lt: cursorDate };
    }

    // Fetch items
    const [poems, stories, thoughts] = await Promise.all([
      Poem.find(poemQuery).sort({ trendingScore: -1, publishedAt: -1 }).limit(limitNum + 1).select('-__v').lean(),
      Story.find(storyQuery).sort({ trendingScore: -1, publishedAt: -1 }).limit(limitNum + 1).select('-__v').lean(),
      Thought.find(thoughtQuery).sort({ createdAt: -1 }).limit(limitNum + 1).select('-__v').lean(),
    ]);

    // Collect all items
    const allItems: FeedItem[] = [
      ...poems.map(p => ({ type: 'poem' as const, _id: p._id, authorId: p.authorId, publishedAt: p.publishedAt, createdAt: p.createdAt, trendingScore: p.trendingScore || 0 })),
      ...stories.map(s => ({ type: 'story' as const, _id: s._id, authorId: s.authorId, publishedAt: s.publishedAt, createdAt: s.createdAt, trendingScore: s.trendingScore || 0 })),
      ...thoughts.map(t => ({ type: 'thought' as const, _id: t._id, authorId: t.authorId, publishedAt: t.createdAt, createdAt: t.createdAt, trendingScore: 0 })),
    ];

    // Sort by trending score
    allItems.sort((a, b) => b.trendingScore - a.trendingScore);

    const feedItems = allItems.slice(0, limitNum);
    const hasMore = allItems.length > limitNum;

    // Batch fetch authors
    const authorIds = [...new Set(feedItems.map(item => item.authorId.toString()))];
    const authors = authorIds.length > 0
      ? await User.find({ _id: { $in: authorIds.map(id => new mongoose.Types.ObjectId(id)) } }, 'displayName username avatarUrl isVerifiedPoet').lean()
      : [];

    const authorMap = new Map(
      authors.map(a => [
        a._id.toString(),
        {
          displayName: a.displayName,
          username: a.username,
          avatarUrl: a.avatarUrl,
          isVerifiedPoet: a.isVerifiedPoet,
        },
      ])
    );

    // Format response
    const items = feedItems.map((item) => {
      const author = authorMap.get(item.authorId.toString()) || {
        displayName: 'Unknown',
        username: 'unknown',
        avatarUrl: undefined,
        isVerifiedPoet: false,
      };

      if (item.type === 'poem') {
        const poem = poems.find(p => p._id.toString() === item._id.toString());
        return poem ? poemWithAuthor(poem as unknown as IPoem, author) : null;
      } else if (item.type === 'story') {
        const story = stories.find(s => s._id.toString() === item._id.toString());
        return story ? storyWithAuthor(story as unknown as IStory, author) : null;
      } else {
        const thought = thoughts.find(t => t._id.toString() === item._id.toString());
        return thought ? thoughtWithAuthor(thought as unknown as IThought, author) : null;
      }
    }).filter(Boolean);

    const nextCursor = hasMore && items.length > 0
      ? (items[items.length - 1] as { publishedAt?: Date; createdAt: Date }).publishedAt?.toISOString() ?? (items[items.length - 1] as { createdAt: Date }).createdAt.toISOString()
      : null;

    res.status(200).json({
      items,
      nextCursor,
      hasMore,
    });
  } catch (error) {
    console.error('Failed to get feed:', error);
    res.status(500).json({ message: 'The feed is quiet today. Try again soon.' });
  }
}
