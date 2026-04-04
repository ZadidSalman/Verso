import { Router } from 'express';
import {
  createPoem,
  getPoem,
  updatePoem,
  deletePoem,
  publishPoem,
  getPoemsByUsername,
  trackRead,
} from '../controllers/poem.controller';
import { optionalAuth, requireAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Public routes
// ─────────────────────────────────────────────────────────────────────────────

// Get all poems by username
router.get('/by/:username', getPoemsByUsername);

// Track read (after 5s dwell)
router.post('/:id/read', trackRead);

// ─────────────────────────────────────────────────────────────────────────────
// Optionally authenticated routes
// ─────────────────────────────────────────────────────────────────────────────

// Get a single poem by ID
router.get('/:id', optionalAuth, getPoem);

// ─────────────────────────────────────────────────────────────────────────────
// Authenticated routes (author only)
// ─────────────────────────────────────────────────────────────────────────────

// Create a poem
router.post('/', requireAuth, createPoem);

// Update a poem
router.put('/:id', requireAuth, updatePoem);

// Delete a poem
router.delete('/:id', requireAuth, deletePoem);

// Publish a draft poem
router.post('/:id/publish', requireAuth, publishPoem);

export default router;
