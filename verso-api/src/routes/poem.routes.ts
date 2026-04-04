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
} from '../controllers/poem.controller';
import { optionalAuth, requireAuth } from '../middleware/auth.middleware';

const router = Router();
const upload = multer({ dest: 'uploads/', limits: { fileSize: 50 * 1024 * 1024 } });

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

// Upload audio recitation
router.post('/:id/audio', requireAuth, upload.single('audio'), uploadAudio);

export default router;
