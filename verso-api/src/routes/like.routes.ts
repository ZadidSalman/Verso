import { Router } from 'express';
import { likeTarget, unlikeTarget, getLikeStatus } from '../controllers/like.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Like routes
// ─────────────────────────────────────────────────────────────────────────────

// Like a target
router.post('/', requireAuth, likeTarget);

// Unlike a target
router.delete('/:targetId', requireAuth, unlikeTarget);

// Check like status
router.get('/:targetId', requireAuth, getLikeStatus);

export default router;
