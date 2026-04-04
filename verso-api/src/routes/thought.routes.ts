import { Router } from 'express';
import {
  createThought,
  deleteThought,
  getMyThoughts,
} from '../controllers/thought.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

// Get my thoughts (for profile)
router.get('/me/thoughts', requireAuth, getMyThoughts);

// Create a thought
router.post('/', requireAuth, createThought);

// Delete a thought
router.delete('/:id', requireAuth, deleteThought);

export default router;
