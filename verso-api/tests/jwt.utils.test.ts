import { describe, it, expect, beforeEach } from 'vitest';

import {
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  hashToken,
  generateOtp,
} from '../src/utils/jwt';

describe('jwt utils', () => {
  beforeEach(() => {
    process.env.JWT_ACCESS_SECRET = 'test-access-secret';
    process.env.JWT_REFRESH_SECRET = 'test-refresh-secret';
  });

  it('signs and verifies access token', () => {
    const token = signAccessToken({ sub: 'user-1', email: 'poet@verso.app' });
    const payload = verifyAccessToken(token);

    expect(payload.sub).toBe('user-1');
    expect(payload.email).toBe('poet@verso.app');
  });

  it('signs and verifies refresh token', () => {
    const token = signRefreshToken({ sub: 'user-2', email: 'reader@verso.app' });
    const payload = verifyRefreshToken(token);

    expect(payload.sub).toBe('user-2');
    expect(payload.email).toBe('reader@verso.app');
  });

  it('hashes tokens deterministically', () => {
    const raw = 'refresh-token-abc';
    expect(hashToken(raw)).toBe(hashToken(raw));
    expect(hashToken(raw)).not.toBe(hashToken('refresh-token-xyz'));
  });

  it('generates a six-digit otp', () => {
    const otp = generateOtp();
    expect(otp).toMatch(/^\d{6}$/);
  });
});
