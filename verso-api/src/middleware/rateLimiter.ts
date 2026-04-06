import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';
import { Request, Response, NextFunction } from 'express';

// ─────────────────────────────────────────────────────────────────────────────
// UPSTASH REDIS CLIENT
// ─────────────────────────────────────────────────────────────────────────────

let redis: Redis | null = null;

function getRedis(): Redis {
  if (!redis) {
    const url = process.env.UPSTASH_REDIS_REST_URL;
    const token = process.env.UPSTASH_REDIS_REST_TOKEN;

    if (!url || !token) {
      console.warn('⚠️  Upstash Redis not configured — rate limiting disabled');
      // Return a no-op client that always allows requests
      redis = new Redis({ url: 'https://placeholder.upstash.io', token: 'placeholder' });
    } else {
      redis = new Redis({ url, token });
    }
  }
  return redis;
}

// ─────────────────────────────────────────────────────────────────────────────
// RATE LIMITER FACTORY
// ─────────────────────────────────────────────────────────────────────────────

export interface RateLimitConfig {
  key: string;
  limit: number;
  window: string;
  poeticMessage?: string;
}

const limiters = new Map<string, Ratelimit>();

export function createRateLimiter(key: string, limit: number, window: string): Ratelimit {
  const cacheKey = `${key}:${limit}:${window}`;

  if (!limiters.has(cacheKey)) {
    limiters.set(cacheKey, new Ratelimit({
      redis: getRedis(),
      limiter: Ratelimit.slidingWindow(limit, window as Parameters<typeof Ratelimit.slidingWindow>[1]),
      prefix: `verso:${key}`,
    }));
  }

  return limiters.get(cacheKey)!;
}

// ─────────────────────────────────────────────────────────────────────────────
// PREDEFINED RATE LIMITERS
// ─────────────────────────────────────────────────────────────────────────────

export const rateLimiters = {
  poemPublish: createRateLimiter('poem_publish', 10, '1 h'),
  comment: createRateLimiter('comment', 30, '1 h'),
  follow: createRateLimiter('follow', 50, '1 h'),
  message: createRateLimiter('message', 100, '1 h'),
  like: createRateLimiter('like', 100, '1 h'),
  thought: createRateLimiter('thought', 20, '1 h'),
  storyPart: createRateLimiter('story_part', 15, '1 h'),
  auth: createRateLimiter('auth', 10, '15 m'),
};

// ─────────────────────────────────────────────────────────────────────────────
// MIDDLEWARE FACTORY
// ─────────────────────────────────────────────────────────────────────────────

const POETIC_429 = 'The well runs dry. Rest your quill and return when the waters rise again.';

export function rateLimit(
  limiter: Ratelimit,
  keyFn?: (req: Request) => string,
  message?: string
) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const identifier = keyFn
      ? keyFn(req)
      : (req.user?._id ?? req.ip ?? 'anonymous');

    try {
      const { success, reset, remaining, limit } = await limiter.limit(identifier);

      // Set rate limit headers
      res.set({
        'X-RateLimit-Limit': String(limit),
        'X-RateLimit-Remaining': String(remaining),
        'X-RateLimit-Reset': String(reset),
      });

      if (!success) {
        res.set('Retry-After', String(Math.ceil((reset - Date.now()) / 1000)));
        res.status(429).json({ message: message ?? POETIC_429 });
        return;
      }

      next();
    } catch (error) {
      // If Redis is unavailable, allow the request through (fail-open)
      console.warn('⚠️  Rate limiter error — allowing request:', error);
      next();
    }
  };
}
