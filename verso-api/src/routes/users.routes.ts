import { Router } from 'express';
import multer from 'multer';
import {
  getProfile,
  updateProfile,
  updateOnboarding,
  checkUsername,
  updateFcmToken,
  getPublicProfile,
  uploadAvatar,
  uploadCover,
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
const imageUpload = multer({
  dest: 'uploads/',
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  },
});

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

// Avatar upload
router.post('/me/avatar', requireAuth, imageUpload.single('avatar'), uploadAvatar);

// Cover photo upload
router.post('/me/cover', requireAuth, imageUpload.single('cover'), uploadCover);

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
