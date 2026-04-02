import jwt from 'jsonwebtoken';
import crypto from 'crypto';

export interface JwtPayload {
  sub: string;
  email: string;
}

/**
 * Sign a short-lived access token (15 minutes)
 */
export const signAccessToken = (payload: JwtPayload): string =>
  jwt.sign(payload, process.env.JWT_ACCESS_SECRET!, { expiresIn: '15m' });

/**
 * Sign a long-lived refresh token (30 days)
 */
export const signRefreshToken = (payload: JwtPayload): string =>
  jwt.sign(payload, process.env.JWT_REFRESH_SECRET!, { expiresIn: '30d' });

/**
 * Verify and decode an access token
 */
export const verifyAccessToken = (token: string): JwtPayload =>
  jwt.verify(token, process.env.JWT_ACCESS_SECRET!) as JwtPayload;

/**
 * Verify and decode a refresh token
 */
export const verifyRefreshToken = (token: string): JwtPayload =>
  jwt.verify(token, process.env.JWT_REFRESH_SECRET!) as JwtPayload;

/**
 * Hash a token using SHA-256 for secure storage
 * We store hashed refresh tokens, not the raw tokens
 */
export const hashToken = (raw: string): string =>
  crypto.createHash('sha256').update(raw).digest('hex');

/**
 * Generate a 6-digit OTP for email verification
 */
export const generateOtp = (): string =>
  String(Math.floor(100000 + Math.random() * 900000));

/**
 * Calculate refresh token expiry date (30 days from now)
 */
export const refreshTokenExpiresAt = (): Date => {
  const date = new Date();
  date.setDate(date.getDate() + 30);
  return date;
};

/**
 * Calculate OTP expiry date (10 minutes from now)
 */
export const otpExpiresAt = (): Date => {
  const date = new Date();
  date.setMinutes(date.getMinutes() + 10);
  return date;
};
