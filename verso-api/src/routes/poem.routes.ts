import { Router } from 'express';
import multer from 'multer';
import {
  createPoem,
  getPoem,
  updatePoem,
  deletePoem,
  publishPoem,
  getPoemsByUsername,
  trackRead,
  uploadAudio,
  uploadVideo,
} from '../controllers/poem.controller';
import { optionalAuth, requireAuth } from '../middleware/auth.middleware';
import { rateLimit, rateLimiters } from '../middleware/rateLimiter';
import { sanitizeBody } from '../middleware/sanitize';

const router = Router();
const audioUpload = multer({ dest: 'uploads/', limits: { fileSize: 50 * 1024 * 1024 } });
const videoUpload = multer({ dest: 'uploads/', limits: { fileSize: 200 * 1024 * 1024 } });

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
router.post(
  '/',
  requireAuth,
  sanitizeBody(['title', 'content', 'category', 'genre', 'tags'], {
    allowedTags: ['br', 'p', 'em', 'strong', 'i', 'b'],
    allowedAttributes: {},
  }),
  createPoem
);

// Update a poem
router.put(
  '/:id',
  requireAuth,
  sanitizeBody(['title', 'content', 'category', 'genre', 'tags'], {
    allowedTags: ['br', 'p', 'em', 'strong', 'i', 'b'],
    allowedAttributes: {},
  }),
  updatePoem
);

// Delete a poem
router.delete('/:id', requireAuth, deletePoem);

// Publish a draft poem
router.post(
  '/:id/publish',
  requireAuth,
  rateLimit(rateLimiters.poemPublish),
  publishPoem
);

// Upload audio recitation
router.post('/:id/audio', requireAuth, audioUpload.single('audio'), uploadAudio);

// Upload video recitation
router.post('/:id/video', requireAuth, videoUpload.single('video'), uploadVideo);

export default router;
