import { Router } from 'express';
import { getFeed } from '../controllers/feed.controller';
import { optionalAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Feed routes
// ─────────────────────────────────────────────────────────────────────────────

// GET /api/feed — paginated feed with optional mood/language/type filters
// Query params: cursor, limit, mood, language, type
router.get('/', optionalAuth, getFeed);

export default router;
