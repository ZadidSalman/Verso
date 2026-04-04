import { Router } from 'express';
import {
  getConversations,
  findOrCreateConversation,
  getMessages,
  markConversationRead,
  sendMessage,
} from '../controllers/conversation.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Conversation routes
// ─────────────────────────────────────────────────────────────────────────────

// Get all conversations
router.get('/', requireAuth, getConversations);

// Find or create conversation
router.post('/', requireAuth, findOrCreateConversation);

// Get messages for a conversation
router.get('/:id/messages', requireAuth, getMessages);

// Mark conversation as read
router.put('/:id/read', requireAuth, markConversationRead);

// Send a message
router.post('/:id/messages', requireAuth, sendMessage);

export default router;
