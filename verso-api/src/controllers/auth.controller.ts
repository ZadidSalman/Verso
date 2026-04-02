import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { User } from '../models/User.model';
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
  hashToken,
  generateOtp,
  refreshTokenExpiresAt,
  otpExpiresAt,
} from '../utils/jwt';
import { sendOtpEmail, sendPasswordResetOtp, sendWelcomeEmail } from '../services/email.service';

// Maximum refresh tokens per user (keeps last 5)
const MAX_REFRESH_TOKENS = 5;

function logDevOtp(context: string, email: string, otp: string): void {
  if (process.env.ENABLE_DEV_OTP_LOG === 'true') {
    console.log(`[DEV_OTP] context=${context} email=${email} otp=${otp}`);
  }
}

/**
 * POST /api/auth/register
 * Register a new user - sends OTP email for verification
 */
export async function register(req: Request, res: Response): Promise<void> {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      res.status(400).json({ message: 'Email and password are required.' });
      return;
    }
    if (password.length < 8) {
      res.status(400).json({ message: 'Password must be at least 8 characters.' });
      return;
    }

    // Check for existing verified user
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser?.emailVerified) {
      res.status(409).json({ message: 'An account with this email already exists.' });
      return;
    }

    // Generate OTP
    const otp = generateOtp();
    const hashedOtp = await bcrypt.hash(otp, 10);
    logDevOtp('register', email.toLowerCase(), otp);

    if (existingUser) {
      // Update existing unverified user
      existingUser.password = password; // Will be hashed by pre-save hook
      existingUser.otpCode = hashedOtp;
      existingUser.otpExpiry = otpExpiresAt();
      existingUser.otpAttempts = 0;
      await existingUser.save();
    } else {
      // Create new user
      await User.create({
        email: email.toLowerCase(),
        password, // Will be hashed by pre-save hook
        otpCode: hashedOtp,
        otpExpiry: otpExpiresAt(),
        otpAttempts: 0,
      });
    }

    // Send OTP email (don't await - fire and forget)
    sendOtpEmail(email, otp).catch(console.error);

    res.status(200).json({ message: 'Verification code sent to your email.' });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

/**
 * POST /api/auth/verify-otp
 * Verify email with OTP code
 */
export async function verifyOtp(req: Request, res: Response): Promise<void> {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      res.status(400).json({ message: 'Email and verification code are required.' });
      return;
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      res.status(400).json({ message: 'Invalid verification code.' });
      return;
    }

    // Check attempt limit
    if (user.otpAttempts >= 5) {
      res.status(429).json({ message: 'Too many attempts. Please request a new code.' });
      return;
    }

    // Check expiry
    if (!user.otpCode || !user.otpExpiry || new Date() > user.otpExpiry) {
      res.status(400).json({ message: 'Verification code has expired. Please request a new one.' });
      return;
    }

    // Verify OTP
    const isValid = await user.compareOtp(otp);
    if (!isValid) {
      user.otpAttempts += 1;
      await user.save();
      res.status(400).json({ message: 'Invalid verification code.' });
      return;
    }

    // Mark as verified
    const isFirstVerification = !user.emailVerified;
    user.emailVerified = true;
    user.otpCode = undefined;
    user.otpExpiry = undefined;
    user.otpAttempts = 0;

    // Generate tokens
    const accessToken = signAccessToken({ sub: user._id.toString(), email: user.email });
    const refreshToken = signRefreshToken({ sub: user._id.toString(), email: user.email });

    // Store hashed refresh token
    user.refreshTokens.push({
      tokenHash: hashToken(refreshToken),
      expiresAt: refreshTokenExpiresAt(),
      deviceInfo: req.headers['user-agent'],
      createdAt: new Date(),
    });

    // Prune to max tokens (keep latest)
    if (user.refreshTokens.length > MAX_REFRESH_TOKENS) {
      user.refreshTokens = user.refreshTokens.slice(-MAX_REFRESH_TOKENS);
    }

    await user.save();

    // Send welcome email for first-time verification
    if (isFirstVerification) {
      sendWelcomeEmail(user.email, user.displayName || 'Poet').catch(console.error);
    }

    res.status(200).json({
      accessToken,
      refreshToken,
      user: {
        _id: user._id,
        email: user.email,
        username: user.username,
        displayName: user.displayName,
        hasCompletedOnboarding: user.hasCompletedOnboarding,
      },
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

/**
 * POST /api/auth/login
 * Login with email and password
 */
export async function login(req: Request, res: Response): Promise<void> {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({ message: 'Email and password are required.' });
      return;
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    
    // Same message for not found or wrong password (prevent enumeration)
    if (!user) {
      res.status(401).json({ message: 'Invalid email or password.' });
      return;
    }

    // Check if email is verified
    if (!user.emailVerified) {
      // Resend OTP
      const otp = generateOtp();
      const hashedOtp = await bcrypt.hash(otp, 10);
      logDevOtp('login_unverified', user.email, otp);
      user.otpCode = hashedOtp;
      user.otpExpiry = otpExpiresAt();
      user.otpAttempts = 0;
      await user.save();
      
      sendOtpEmail(user.email, otp).catch(console.error);
      
      res.status(403).json({
        code: 'EMAIL_NOT_VERIFIED',
        message: 'Please verify your email first. A new code has been sent.',
      });
      return;
    }

    // Verify password
    const isValid = await user.comparePassword(password);
    if (!isValid) {
      res.status(401).json({ message: 'Invalid email or password.' });
      return;
    }

    // Generate tokens
    const accessToken = signAccessToken({ sub: user._id.toString(), email: user.email });
    const refreshToken = signRefreshToken({ sub: user._id.toString(), email: user.email });

    // Store hashed refresh token
    user.refreshTokens.push({
      tokenHash: hashToken(refreshToken),
      expiresAt: refreshTokenExpiresAt(),
      deviceInfo: req.headers['user-agent'],
      createdAt: new Date(),
    });

    // Prune to max tokens
    if (user.refreshTokens.length > MAX_REFRESH_TOKENS) {
      user.refreshTokens = user.refreshTokens.slice(-MAX_REFRESH_TOKENS);
    }

    user.lastActiveAt = new Date();
    await user.save();

    res.status(200).json({
      accessToken,
      refreshToken,
      user: {
        _id: user._id,
        email: user.email,
        username: user.username,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        hasCompletedOnboarding: user.hasCompletedOnboarding,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

/**
 * POST /api/auth/refresh
 * Exchange refresh token for new token pair
 */
export async function refreshTokens(req: Request, res: Response): Promise<void> {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      res.status(400).json({ message: 'Refresh token is required.' });
      return;
    }

    // Verify refresh token signature
    let payload;
    try {
      payload = verifyRefreshToken(refreshToken);
    } catch {
      res.status(401).json({ message: 'Invalid or expired refresh token.' });
      return;
    }

    const user = await User.findById(payload.sub);
    if (!user) {
      res.status(401).json({ message: 'Invalid or expired refresh token.' });
      return;
    }

    // Find the token record
    const tokenHash = hashToken(refreshToken);
    const tokenIndex = user.refreshTokens.findIndex(
      (t) => t.tokenHash === tokenHash && t.expiresAt > new Date()
    );

    if (tokenIndex === -1) {
      res.status(401).json({ message: 'Invalid or expired refresh token.' });
      return;
    }

    // Remove old token
    user.refreshTokens.splice(tokenIndex, 1);

    // Generate new tokens
    const newAccessToken = signAccessToken({ sub: user._id.toString(), email: user.email });
    const newRefreshToken = signRefreshToken({ sub: user._id.toString(), email: user.email });

    // Store new refresh token
    user.refreshTokens.push({
      tokenHash: hashToken(newRefreshToken),
      expiresAt: refreshTokenExpiresAt(),
      deviceInfo: req.headers['user-agent'],
      createdAt: new Date(),
    });

    await user.save();

    res.status(200).json({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    });
  } catch (error) {
    console.error('Refresh tokens error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

/**
 * POST /api/auth/logout
 * Revoke refresh token
 */
export async function logout(req: Request, res: Response): Promise<void> {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      res.status(204).send();
      return;
    }

    let payload;
    try {
      payload = verifyRefreshToken(refreshToken);
    } catch {
      // Invalid token - still return 204 (idempotent)
      res.status(204).send();
      return;
    }

    const user = await User.findById(payload.sub);
    if (user) {
      const tokenHash = hashToken(refreshToken);
      user.refreshTokens = user.refreshTokens.filter((t) => t.tokenHash !== tokenHash);
      await user.save();
    }

    res.status(204).send();
  } catch (error) {
    console.error('Logout error:', error);
    // Always return 204 for logout (idempotent)
    res.status(204).send();
  }
}

/**
 * POST /api/auth/forgot-password
 * Send password reset OTP
 */
export async function forgotPassword(req: Request, res: Response): Promise<void> {
  try {
    const { email } = req.body;

    // Always return 200 (prevents email enumeration)
    res.status(200).json({ message: 'If an account exists, a reset code has been sent.' });

    if (!email) return;

    const user = await User.findOne({ email: email.toLowerCase(), emailVerified: true });
    if (!user) return;

    const otp = generateOtp();
    const hashedOtp = await bcrypt.hash(otp, 10);
    logDevOtp('forgot_password', email.toLowerCase(), otp);
    
    user.otpCode = hashedOtp;
    user.otpExpiry = otpExpiresAt();
    user.otpAttempts = 0;
    await user.save();

    sendPasswordResetOtp(email, otp).catch(console.error);
  } catch (error) {
    console.error('Forgot password error:', error);
    // Don't expose error - already sent 200
  }
}

/**
 * POST /api/auth/reset-password
 * Reset password with OTP
 */
export async function resetPassword(req: Request, res: Response): Promise<void> {
  try {
    const { email, otp, newPassword } = req.body;

    if (!email || !otp || !newPassword) {
      res.status(400).json({ message: 'Email, code, and new password are required.' });
      return;
    }

    if (newPassword.length < 8) {
      res.status(400).json({ message: 'Password must be at least 8 characters.' });
      return;
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      res.status(400).json({ message: 'Invalid reset code.' });
      return;
    }

    // Check attempt limit
    if (user.otpAttempts >= 5) {
      res.status(429).json({ message: 'Too many attempts. Please request a new code.' });
      return;
    }

    // Check expiry
    if (!user.otpCode || !user.otpExpiry || new Date() > user.otpExpiry) {
      res.status(400).json({ message: 'Reset code has expired. Please request a new one.' });
      return;
    }

    // Verify OTP
    const isValid = await user.compareOtp(otp);
    if (!isValid) {
      user.otpAttempts += 1;
      await user.save();
      res.status(400).json({ message: 'Invalid reset code.' });
      return;
    }

    // Update password and revoke all sessions
    user.password = newPassword; // Will be hashed by pre-save hook
    user.otpCode = undefined;
    user.otpExpiry = undefined;
    user.otpAttempts = 0;
    user.refreshTokens = []; // Revoke ALL sessions

    await user.save();

    res.status(200).json({ message: 'Password has been reset. Please log in with your new password.' });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}

/**
 * POST /api/auth/resend-otp
 * Resend verification OTP
 */
export async function resendOtp(req: Request, res: Response): Promise<void> {
  try {
    const { email } = req.body;

    if (!email) {
      res.status(400).json({ message: 'Email is required.' });
      return;
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      // Don't reveal if user exists
      res.status(200).json({ message: 'If an account exists, a new code has been sent.' });
      return;
    }

    if (user.emailVerified) {
      res.status(400).json({ message: 'Email is already verified.' });
      return;
    }

    const otp = generateOtp();
    const hashedOtp = await bcrypt.hash(otp, 10);
    logDevOtp('resend_otp', email.toLowerCase(), otp);
    
    user.otpCode = hashedOtp;
    user.otpExpiry = otpExpiresAt();
    user.otpAttempts = 0;
    await user.save();

    sendOtpEmail(email, otp).catch(console.error);

    res.status(200).json({ message: 'A new verification code has been sent.' });
  } catch (error) {
    console.error('Resend OTP error:', error);
    res.status(500).json({ message: 'Something went wrong. Please try again.' });
  }
}
