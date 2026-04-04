import { Router } from 'express';
import { createDuel, getDuel, acceptDuel, voteDuel, getActiveDuels } from '../controllers/duel.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Duel routes
// ─────────────────────────────────────────────────────────────────────────────

// Get active duels
router.get('/active', getActiveDuels);

// Create a duel
router.post('/', requireAuth, createDuel);

// Get a duel by ID
router.get('/:id', getDuel);

// Accept a duel
router.post('/:id/accept', requireAuth, acceptDuel);

// Vote in a duel
router.post('/:id/vote', requireAuth, voteDuel);

export default router;
