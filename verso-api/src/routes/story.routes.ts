import { Router } from 'express';
import { createStory, getStory, getStoryParts, getStoryPart, addStoryPart, getTrendingStories } from '../controllers/story.controller';
import { requireAuth, optionalAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Story routes
// ─────────────────────────────────────────────────────────────────────────────

// Get trending stories
router.get('/trending', getTrendingStories);

// Create a story
router.post('/', requireAuth, createStory);

// Get a story by ID
router.get('/:id', optionalAuth, getStory);

// Get all parts of a story
router.get('/:id/parts', optionalAuth, getStoryParts);

// Add a part to a story
router.post('/:id/parts', requireAuth, addStoryPart);

// Get a single story part
router.get('/:id/part/:partId', optionalAuth, getStoryPart);

export default router;
