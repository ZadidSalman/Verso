import { Request, Response } from 'express';
import { Poem, IPoem } from '../models/Poem.model';
import { User } from '../models/User.model';

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: Format poem with author info
// ─────────────────────────────────────────────────────────────────────────────

function poemWithAuthor(poem: IPoem, author: {
  displayName?: string;
  username?: string;
  avatarUrl?: string;
  isVerifiedPoet: boolean;
}) {
  return {
    id: poem._id.toString(),
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

// ─────────────────────────────────────────────────────────────────────────────
// GET paginated feed with mood/language filters
// ─────────────────────────────────────────────────────────────────────────────

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

    // Build query
    const query: Record<string, unknown> = {
      status: 'published',
    };

    // Filter by mood
    if (mood) {
      query.mood = { $in: (mood as string).split(',') };
    }

    // Filter by language
    if (language) {
      query.language = language;
    }

    // Filter by type (poems, stories, thoughts)
    if (type === 'poems') {
      query.videoUrl = { $exists: false };
    }

    // Cursor pagination
    if (cursor) {
      query.publishedAt = { $lt: new Date(cursor as string) };
    }

    // Fetch poems sorted by trending score
    const poems = await Poem.find(query)
      .sort({ trendingScore: -1, publishedAt: -1 })
      .limit(limitNum + 1)
      .select('-__v -content')
      .lean();

    const hasMore = poems.length > limitNum;
    if (hasMore) poems.pop();

    // Batch fetch authors
    const authorIds = [...new Set(poems.map((p) => p.authorId.toString()))];
    const authors = await User.find(
      { _id: { $in: authorIds } },
      'displayName username avatarUrl isVerifiedPoet'
    ).lean();

    const authorMap = new Map(
      authors.map((a) => [
        a._id.toString(),
        {
          displayName: a.displayName,
          username: a.username,
          avatarUrl: a.avatarUrl,
          isVerifiedPoet: a.isVerifiedPoet,
        },
      ])
    );

    // Build response
    const items = poems.map((poem) => {
      const author = authorMap.get(poem.authorId.toString()) || {
        displayName: 'Unknown',
        username: 'unknown',
        avatarUrl: undefined,
        isVerifiedPoet: false,
      };
      return poemWithAuthor(poem as unknown as IPoem, author);
    });

    const nextCursor = hasMore && items.length > 0
      ? items[items.length - 1].publishedAt
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
