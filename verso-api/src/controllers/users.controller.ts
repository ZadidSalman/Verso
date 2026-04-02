import { Request, Response } from 'express';
import { User } from '../models/User.model';

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE ENDPOINTS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * GET /api/users/me
 * Get current user's profile
 */
export async function getProfile(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user?._id;
    if (!userId) {
      res.status(401).json({ message: 'Not authenticated.' });
      return;
    }

    const user = await User.findById(userId).select('-password -otpCode -refreshTokens');
    if (!user) {
      res.status(404).json({ message: 'User not found.' });
      return;
    }

    res.json({ user });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

/**
 * PUT /api/users/me
 * Update current user's profile
 */
export async function updateProfile(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user?._id;
    if (!userId) {
      res.status(401).json({ message: 'Not authenticated.' });
      return;
    }

    const { displayName, bio } = req.body;

    const user = await User.findByIdAndUpdate(
      userId,
      {
        ...(displayName !== undefined && { displayName }),
        ...(bio !== undefined && { bio }),
      },
      { new: true }
    ).select('-password -otpCode -refreshTokens');

    if (!user) {
      res.status(404).json({ message: 'User not found.' });
      return;
    }

    res.json({ user });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING ENDPOINTS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * PUT /api/users/me/onboarding
 * Update onboarding preferences (username, moods, language)
 */
export async function updateOnboarding(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user?._id;
    if (!userId) {
      res.status(401).json({ message: 'Not authenticated.' });
      return;
    }

    const { username, preferredMoods, preferredLanguage, hasCompletedOnboarding } = req.body;

    // If username is being set, validate it
    if (username) {
      // Validate format
      const usernameRegex = /^[a-z0-9_]{3,20}$/;
      if (!usernameRegex.test(username.toLowerCase())) {
        res.status(400).json({
          message: 'Username must be 3-20 characters and contain only letters, numbers, and underscores.',
        });
        return;
      }

      // Check availability
      const existingUser = await User.findOne({
        username: username.toLowerCase(),
        _id: { $ne: userId },
      });
      if (existingUser) {
        res.status(409).json({ message: 'This username is already taken.' });
        return;
      }
    }

    // Validate moods if provided
    const validMoods = ['melancholic', 'romantic', 'joyful', 'angry', 'peaceful', 'nostalgic', 'mysterious', 'spiritual'];
    if (preferredMoods && Array.isArray(preferredMoods)) {
      if (preferredMoods.some((mood: string) => !validMoods.includes(mood))) {
        res.status(400).json({ message: 'Invalid mood selection.' });
        return;
      }
      if (preferredMoods.length > 3) {
        res.status(400).json({ message: 'Maximum 3 moods can be selected.' });
        return;
      }
    }

    // Validate language if provided
    if (preferredLanguage && !['en', 'bn', 'both'].includes(preferredLanguage)) {
      res.status(400).json({ message: 'Invalid language selection.' });
      return;
    }

    const user = await User.findByIdAndUpdate(
      userId,
      {
        ...(username && { username: username.toLowerCase() }),
        ...(preferredMoods && { preferredMoods }),
        ...(preferredLanguage && { preferredLanguage }),
        ...(hasCompletedOnboarding !== undefined && { hasCompletedOnboarding }),
      },
      { new: true }
    ).select('-password -otpCode -refreshTokens');

    if (!user) {
      res.status(404).json({ message: 'User not found.' });
      return;
    }

    res.json({ user });
  } catch (error) {
    console.error('Update onboarding error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

/**
 * GET /api/users/check-username
 * Check if a username is available
 */
export async function checkUsername(req: Request, res: Response): Promise<void> {
  try {
    const { u: username } = req.query;

    if (!username || typeof username !== 'string') {
      res.status(400).json({ message: 'Username is required.' });
      return;
    }

    // Validate format
    const usernameRegex = /^[a-z0-9_]{3,20}$/;
    if (!usernameRegex.test(username.toLowerCase())) {
      res.json({ available: false, reason: 'invalid' });
      return;
    }

    const existingUser = await User.findOne({ username: username.toLowerCase() });
    res.json({ available: !existingUser });
  } catch (error) {
    console.error('Check username error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FCM TOKEN ENDPOINTS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * PUT /api/users/me/fcm-token
 * Update FCM token for push notifications
 */
export async function updateFcmToken(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user?._id;
    if (!userId) {
      res.status(401).json({ message: 'Not authenticated.' });
      return;
    }

    const { fcmToken } = req.body;

    if (!fcmToken || typeof fcmToken !== 'string') {
      res.status(400).json({ message: 'FCM token is required.' });
      return;
    }

    await User.findByIdAndUpdate(userId, { fcmToken });

    res.json({ success: true });
  } catch (error) {
    console.error('Update FCM token error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC PROFILE ENDPOINTS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * GET /api/users/:username
 * Get user profile by username (public)
 */
export async function getPublicProfile(req: Request, res: Response): Promise<void> {
  try {
    const usernameParam = req.params.username;
    const username = Array.isArray(usernameParam)
      ? usernameParam[0]
      : usernameParam;

    if (!username) {
      res.status(400).json({ message: 'Username is required.' });
      return;
    }

    const user = await User.findOne({ username: username.toLowerCase() }).select(
      'username displayName avatarUrl coverUrl bio followersCount followingCount poemsCount isVerifiedPoet createdAt'
    );

    if (!user) {
      res.status(404).json({ message: 'User not found.' });
      return;
    }

    res.json({ user });
  } catch (error) {
    console.error('Get public profile error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}
