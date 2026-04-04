import { Router } from 'express';
import { createComment, getComments, deleteComment } from '../controllers/comment.controller';
import { optionalAuth, requireAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Comment routes
// ─────────────────────────────────────────────────────────────────────────────

// Create a comment
router.post('/', requireAuth, createComment);

// Get comments for a target
router.get('/:targetId', optionalAuth, getComments);

// Delete a comment
router.delete('/:id', requireAuth, deleteComment);

export default router;
