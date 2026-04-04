import { Router } from 'express';
import { getNotifications, markAllAsRead, markAsRead } from '../controllers/notification.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Notification routes
// ─────────────────────────────────────────────────────────────────────────────

// Get notifications
router.get('/', requireAuth, getNotifications);

// Mark all as read
router.put('/read-all', requireAuth, markAllAsRead);

// Mark single as read
router.put('/:id/read', requireAuth, markAsRead);

export default router;
