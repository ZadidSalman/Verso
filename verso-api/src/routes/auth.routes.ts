import { Router } from 'express';
import {
  register,
  verifyOtp,
  login,
  refreshTokens,
  logout,
  forgotPassword,
  resetPassword,
  resendOtp,
} from '../controllers/auth.controller';

const router = Router();

// Public routes
router.post('/register', register);
router.post('/verify-otp', verifyOtp);
router.post('/login', login);
router.post('/refresh', refreshTokens);
router.post('/logout', logout);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);
router.post('/resend-otp', resendOtp);

export default router;
