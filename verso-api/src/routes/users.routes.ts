import { Router } from 'express';
import {
  getProfile,
  updateProfile,
  updateOnboarding,
  checkUsername,
  updateFcmToken,
  getPublicProfile,
} from '../controllers/users.controller';
import { requireAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Public routes
// ─────────────────────────────────────────────────────────────────────────────

// Check username availability (optionally authenticated to exclude current user)
router.get('/check-username', requireAuth, checkUsername);

// Current user profile
router.get('/me', requireAuth, getProfile);
router.put('/me', requireAuth, updateProfile);

// Onboarding
router.put('/me/onboarding', requireAuth, updateOnboarding);

// FCM token
router.put('/me/fcm-token', requireAuth, updateFcmToken);

// ─────────────────────────────────────────────────────────────────────────────
// Public dynamic routes (keep last to avoid shadowing fixed paths)
// ─────────────────────────────────────────────────────────────────────────────

// Get public profile by username
router.get('/:username', getPublicProfile);

export default router;
