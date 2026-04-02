import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACES
// ─────────────────────────────────────────────────────────────────────────────

export interface IRefreshToken {
  tokenHash: string;
  expiresAt: Date;
  deviceInfo?: string;
  createdAt: Date;
}

export interface IUser extends Document {
  _id: mongoose.Types.ObjectId;
  email: string;
  password: string;
  username?: string;
  displayName?: string;
  avatarUrl?: string;
  coverUrl?: string;
  bio?: string;
  
  // Verification
  emailVerified: boolean;
  otpCode?: string;
  otpExpiry?: Date;
  otpAttempts: number;
  
  // Auth tokens
  refreshTokens: IRefreshToken[];
  fcmToken?: string;
  
  // Preferences
  preferredLanguage: 'en' | 'bn' | 'both';
  preferredMoods: string[];
  hasCompletedOnboarding: boolean;
  
  // Social
  followersCount: number;
  followingCount: number;
  poemsCount: number;
  isVerifiedPoet: boolean;
  
  // Timestamps
  lastActiveAt: Date;
  createdAt: Date;
  updatedAt: Date;
  
  // Methods
  comparePassword(candidate: string): Promise<boolean>;
  compareOtp(candidate: string): Promise<boolean>;
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEMA
// ─────────────────────────────────────────────────────────────────────────────

const RefreshTokenSchema = new Schema<IRefreshToken>({
  tokenHash: { type: String, required: true },
  expiresAt: { type: Date, required: true },
  deviceInfo: { type: String },
  createdAt: { type: Date, default: Date.now },
});

const UserSchema = new Schema<IUser>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
      minlength: 8,
    },
    username: {
      type: String,
      unique: true,
      sparse: true, // Allow multiple nulls
      lowercase: true,
      trim: true,
      minlength: 3,
      maxlength: 20,
      match: /^[a-z0-9_]+$/,
    },
    displayName: {
      type: String,
      trim: true,
      maxlength: 50,
    },
    avatarUrl: String,
    coverUrl: String,
    bio: {
      type: String,
      maxlength: 500,
    },
    
    // Verification
    emailVerified: { type: Boolean, default: false },
    otpCode: String,
    otpExpiry: Date,
    otpAttempts: { type: Number, default: 0 },
    
    // Auth
    refreshTokens: [RefreshTokenSchema],
    fcmToken: String,
    
    // Preferences
    preferredLanguage: {
      type: String,
      enum: ['en', 'bn', 'both'],
      default: 'both',
    },
    preferredMoods: [String],
    hasCompletedOnboarding: { type: Boolean, default: false },
    
    // Social
    followersCount: { type: Number, default: 0 },
    followingCount: { type: Number, default: 0 },
    poemsCount: { type: Number, default: 0 },
    isVerifiedPoet: { type: Boolean, default: false },
    
    // Activity
    lastActiveAt: { type: Date, default: Date.now },
  },
  {
    timestamps: true,
  }
);

// ─────────────────────────────────────────────────────────────────────────────
// INDEXES
// ─────────────────────────────────────────────────────────────────────────────

UserSchema.index({ email: 1 });
UserSchema.index({ username: 1 });
UserSchema.index({ createdAt: -1 });

// ─────────────────────────────────────────────────────────────────────────────
// MIDDLEWARE
// ─────────────────────────────────────────────────────────────────────────────

// Hash password before save
UserSchema.pre('save', async function () {
  if (!this.isModified('password')) return;
  this.password = await bcrypt.hash(this.password, 12);
});

// ─────────────────────────────────────────────────────────────────────────────
// METHODS
// ─────────────────────────────────────────────────────────────────────────────

UserSchema.methods.comparePassword = async function (candidate: string): Promise<boolean> {
  return bcrypt.compare(candidate, this.password);
};

UserSchema.methods.compareOtp = async function (candidate: string): Promise<boolean> {
  if (!this.otpCode) return false;
  return bcrypt.compare(candidate, this.otpCode);
};

// ─────────────────────────────────────────────────────────────────────────────
// EXPORT
// ─────────────────────────────────────────────────────────────────────────────

export const User = mongoose.model<IUser>('User', UserSchema);
