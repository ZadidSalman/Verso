import { Router } from 'express';
import {
  getProfile,
  updateProfile,
  updateOnboarding,
  checkUsername,
  updateFcmToken,
  getPublicProfile,
} from '../controllers/users.controller';
import {
  followUser,
  unfollowUser,
  getFollowStatus,
  getFollowers,
  getFollowing,
} from '../controllers/follow.controller';
import { optionalAuth, requireAuth } from '../middleware/auth.middleware';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Public routes
// ─────────────────────────────────────────────────────────────────────────────

// Check username availability (optionally authenticated to exclude current user)
router.get('/check-username', optionalAuth, checkUsername);

// Current user profile
router.get('/me', requireAuth, getProfile);
router.put('/me', requireAuth, updateProfile);

// Onboarding
router.put('/me/onboarding', requireAuth, updateOnboarding);

// FCM token
router.put('/me/fcm-token', requireAuth, updateFcmToken);

// ─────────────────────────────────────────────────────────────────────────────
// Follow routes (must be before /:username to avoid conflicts)
// ─────────────────────────────────────────────────────────────────────────────

// Follow a user
router.post('/:id/follow', requireAuth, followUser);

// Unfollow a user
router.delete('/:id/follow', requireAuth, unfollowUser);

// Check follow status (authenticated)
router.get('/:id/follow-status', requireAuth, getFollowStatus);

// Get followers list
router.get('/:id/followers', getFollowers);

// Get following list
router.get('/:id/following', getFollowing);

// ─────────────────────────────────────────────────────────────────────────────
// Public dynamic routes (keep last to avoid shadowing fixed paths)
// ─────────────────────────────────────────────────────────────────────────────

// Get public profile by username
router.get('/:username', getPublicProfile);

export default router;
