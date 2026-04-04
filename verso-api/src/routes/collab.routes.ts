import { Router } from 'express';
import { createCollabPoem, getCollabPoem, submitStanza, closeCollabPoem, getTrendingCollabs } from '../controllers/collab.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Collaborative poem routes
// ─────────────────────────────────────────────────────────────────────────────

// Get trending collab poems
router.get('/trending', getTrendingCollabs);

// Create a collab poem
router.post('/', requireAuth, createCollabPoem);

// Get a collab poem by ID
router.get('/:id', getCollabPoem);

// Submit a stanza
router.post('/:id/stanzas', requireAuth, submitStanza);

// Close a collab poem (originator only)
router.post('/:id/close', requireAuth, closeCollabPoem);

export default router;
