import { describe, it, expect, vi, beforeEach } from 'vitest';
import type { Request, Response, NextFunction } from 'express';

import { requireAuth } from '../src/middleware/auth.middleware';
import { verifyAccessToken } from '../src/utils/jwt';

vi.mock('../src/utils/jwt', () => ({
  verifyAccessToken: vi.fn(),
}));

const mockedVerifyAccessToken = vi.mocked(verifyAccessToken);

function createResponseMock() {
  const json = vi.fn();
  const status = vi.fn(() => ({ json }));
  return { status, json };
}

describe('requireAuth middleware', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns 401 when authorization header is missing', async () => {
    const req = { headers: {} } as Request;
    const resMock = createResponseMock();
    const res = resMock as unknown as Response;
    const next = vi.fn() as NextFunction;

    await requireAuth(req, res, next);

    expect(resMock.status).toHaveBeenCalledWith(401);
    expect(resMock.json).toHaveBeenCalledWith({ message: 'Authentication required.' });
    expect(next).not.toHaveBeenCalled();
  });

  it('sets req.user and calls next for a valid token', async () => {
    mockedVerifyAccessToken.mockReturnValue({
      sub: 'user-123',
      email: 'poet@verso.app',
    });

    const req = {
      headers: { authorization: 'Bearer valid-token' },
    } as Request;
    const resMock = createResponseMock();
    const res = resMock as unknown as Response;
    const next = vi.fn() as NextFunction;

    await requireAuth(req, res, next);

    expect(mockedVerifyAccessToken).toHaveBeenCalledWith('valid-token');
    expect(req.user).toEqual({ _id: 'user-123', email: 'poet@verso.app' });
    expect(next).toHaveBeenCalledOnce();
    expect(resMock.status).not.toHaveBeenCalled();
  });

  it('returns 401 when token is invalid', async () => {
    mockedVerifyAccessToken.mockImplementation(() => {
      throw new Error('invalid token');
    });

    const req = {
      headers: { authorization: 'Bearer bad-token' },
    } as Request;
    const resMock = createResponseMock();
    const res = resMock as unknown as Response;
    const next = vi.fn() as NextFunction;

    await requireAuth(req, res, next);

    expect(mockedVerifyAccessToken).toHaveBeenCalledWith('bad-token');
    expect(resMock.status).toHaveBeenCalledWith(401);
    expect(resMock.json).toHaveBeenCalledWith({
      message: 'Token expired or invalid. Please log in again.',
    });
    expect(next).not.toHaveBeenCalled();
  });
});
