import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../utils/jwt';

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      user?: {
        _id: string;
        email: string;
      };
    }
  }
}

/**
 * Require authentication - returns 401 if no valid token
 */
export async function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];

  if (!token) {
    res.status(401).json({ message: 'Authentication required.' });
    return;
  }

  try {
    const payload = verifyAccessToken(token);
    req.user = { _id: payload.sub, email: payload.email };
    next();
  } catch {
    res.status(401).json({ message: 'Token expired or invalid. Please log in again.' });
  }
}

/**
 * Optional authentication - continues even without valid token
 * Sets req.user if token is valid, otherwise leaves it undefined
 */
export async function optionalAuth(
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];

  if (token) {
    try {
      const payload = verifyAccessToken(token);
      req.user = { _id: payload.sub, email: payload.email };
    } catch {
      // Token invalid - continue without user
    }
  }

  next();
}
