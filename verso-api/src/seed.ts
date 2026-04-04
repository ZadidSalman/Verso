/**
 * Seed script — populates MongoDB with dummy data for testing.
 *
 * Usage:
 *   npx ts-node src/seed.ts
 *
 * ⚠️ This will DELETE existing data in all collections.
 */

import 'dotenv/config';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

import { User } from './models/User.model';
import { Poem } from './models/Poem.model';
import { Story } from './models/Story.model';
import { StoryPart } from './models/StoryPart.model';
import { Follow } from './models/Follow.model';
import { Like } from './models/Like.model';
import { Comment } from './models/Comment.model';
import { Notification } from './models/Notification.model';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG
// ─────────────────────────────────────────────────────────────────────────────

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/verso';
const HASHED_PASSWORD = '$2a$10$X7VpZqJZqJZqJZqJZqJZqO.0.0.0.0.0.0.0.0.0.0.0.0.0'; // "password123"

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────

async function seed() {
  console.log('🌱 Connecting to MongoDB...');
  await mongoose.connect(MONGODB_URI);

  // Clear all collections
  console.log('🧹 Clearing existing data...');
  await Promise.all([
    User.deleteMany({}),
    Poem.deleteMany({}),
    Story.deleteMany({}),
    StoryPart.deleteMany({}),
    Follow.deleteMany({}),
    Like.deleteMany({}),
    Comment.deleteMany({}),
    Notification.deleteMany({}),
  ]);

  // ── USERS ────────────────────────────────────────────────────────────────
  console.log('👤 Creating users...');
  const users = await User.insertMany([
    {
      email: 'riya@verso.test',
      password: HASHED_PASSWORD,
      displayName: 'Riya Sen',
      username: 'riya',
      avatarUrl: 'https://i.pravatar.cc/150?u=riya',
      isVerifiedPoet: true,
      bio: 'Poet of monsoons and midnight thoughts.',
      poemsCount: 5,
      followersCount: 3,
      followingCount: 2,
      hasCompletedOnboarding: true,
      selectedMoods: ['melancholy', 'hope', 'love'],
      preferredLanguage: 'en',
      fcmToken: 'test-fcm-token-riya',
    },
    {
      email: 'arjun@verso.test',
      password: HASHED_PASSWORD,
      displayName: 'Arjun Das',
      username: 'arjun',
      avatarUrl: 'https://i.pravatar.cc/150?u=arjun',
      isVerifiedPoet: false,
      bio: 'Words are my only truth.',
      poemsCount: 3,
      followersCount: 2,
      followingCount: 1,
      hasCompletedOnboarding: true,
      selectedMoods: ['anger', 'defiance'],
      preferredLanguage: 'en',
      fcmToken: 'test-fcm-token-arjun',
    },
    {
      email: 'nadia@verso.test',
      password: HASHED_PASSWORD,
      displayName: 'Nadia Rahman',
      username: 'nadia',
      avatarUrl: 'https://i.pravatar.cc/150?u=nadia',
      isVerifiedPoet: true,
      bio: 'বাংলা কবিতা আমার হৃদয়।',
      poemsCount: 4,
      followersCount: 1,
      followingCount: 3,
      hasCompletedOnboarding: true,
      selectedMoods: ['nostalgia', 'longing'],
      preferredLanguage: 'bn',
      fcmToken: 'test-fcm-token-nadia',
    },
    {
      email: 'test@verso.test',
      password: HASHED_PASSWORD,
      displayName: 'Test Poet',
      username: 'testpoet',
      isVerifiedPoet: false,
      poemsCount: 0,
      followersCount: 0,
      followingCount: 0,
      hasCompletedOnboarding: true,
      selectedMoods: ['wonder'],
      preferredLanguage: 'en',
      fcmToken: 'test-fcm-token-test',
    },
  ]);

  const [riya, arjun, nadia, testPoet] = users;
  console.log(`   Created ${users.length} users.`);

  // ── POEMS ────────────────────────────────────────────────────────────────
  console.log('📝 Creating poems...');
  const poems = await Poem.insertMany([
    {
      authorId: riya._id,
      title: 'Monsoon Confession',
      content: `The rain speaks in a language\nonly the earth understands.\n\nI tried to translate it\nbut my words drowned\nbefore they reached the page.\n\nSo I sit,\nand let the clouds\nwrite on my skin.`,
      slug: 'monsoon-confession-1a2b3c',
      language: 'en',
      mood: ['melancholy', 'love'],
      tags: ['rain', 'nature', 'confession'],
      status: 'published',
      likesCount: 12,
      commentsCount: 3,
      readsCount: 45,
      trendingScore: 8.5,
      wordCount: 38,
      lineCount: 12,
      publishedAt: new Date(Date.now() - 86400000 * 2),
    },
    {
      authorId: riya._id,
      title: 'Unsent Letter',
      content: `I wrote your name\non the fogged window of a departing train.\n\nThe glass cleared.\nThe name vanished.\n\nJust like us.`,
      slug: 'unsent-letter-4d5e6f',
      language: 'en',
      mood: ['longing', 'loss'],
      tags: ['love', 'loss'],
      isUnsent: true,
      unsentTo: 'someone who left',
      status: 'published',
      likesCount: 8,
      commentsCount: 1,
      readsCount: 32,
      trendingScore: 6.2,
      wordCount: 24,
      lineCount: 7,
      publishedAt: new Date(Date.now() - 86400000 * 5),
    },
    {
      authorId: arjun._id,
      title: 'Concrete Jungle',
      content: `They built towers of glass\nand called it progress.\n\nI see mirrors\nreflecting the same old hunger.\n\nThe streets remember\nwhen the soil breathed.\n\nNow even the pigeons\nwalk with purpose.`,
      slug: 'concrete-jungle-7g8h9i',
      language: 'en',
      mood: ['anger', 'defiance'],
      tags: ['city', 'progress', 'nature'],
      status: 'published',
      likesCount: 15,
      commentsCount: 5,
      readsCount: 67,
      trendingScore: 9.1,
      wordCount: 36,
      lineCount: 10,
      publishedAt: new Date(Date.now() - 86400000 * 1),
    },
    {
      authorId: nadia._id,
      title: 'স্মৃতির নদী',
      content: `স্মৃতির নদী বয়ে চলে\nঅবিরাম, অথৈ জলে।\n\nকূল খুঁজে পাই না,\nতবু ভাসি, তবু যাই।\n\nকেননা এই স্রোতেই\nআমার পরিচয়।`,
      slug: 'smritir-nodi-jk0lmn',
      language: 'bn',
      mood: ['nostalgia'],
      tags: ['memory', 'river'],
      status: 'published',
      likesCount: 20,
      commentsCount: 7,
      readsCount: 89,
      trendingScore: 9.8,
      wordCount: 18,
      lineCount: 7,
      publishedAt: new Date(Date.now() - 86400000 * 3),
    },
    {
      authorId: nadia._id,
      title: 'Dusk in Dhaka',
      content: `The call to prayer\nweaves through rickshaw bells\nand frying oil.\n\nA symphony of chaos\nthat I call home.`,
      slug: 'dusk-in-dhaka-op1qrs',
      language: 'en',
      mood: ['nostalgia', 'wonder'],
      tags: ['dhaka', 'home'],
      status: 'published',
      likesCount: 11,
      commentsCount: 2,
      readsCount: 41,
      trendingScore: 7.3,
      wordCount: 22,
      lineCount: 6,
      publishedAt: new Date(Date.now() - 86400000 * 4),
    },
    {
      authorId: testPoet._id,
      title: 'First Verse',
      content: `I don't know if this is poetry\nor just noise.\n\nBut it's mine.`,
      slug: 'first-verse-tu2vwx',
      language: 'en',
      mood: ['wonder'],
      tags: ['beginning'],
      status: 'published',
      likesCount: 2,
      commentsCount: 0,
      readsCount: 5,
      trendingScore: 1.0,
      wordCount: 12,
      lineCount: 4,
      publishedAt: new Date(Date.now() - 3600000),
    },
  ]);
  console.log(`   Created ${poems.length} poems.`);

  // ── STORIES ──────────────────────────────────────────────────────────────
  console.log('📖 Creating stories...');
  const story = await Story.create({
    authorId: riya._id,
    title: 'The Last Monsoon',
    description: 'A story about the last rainy season before everything changed.',
    language: 'en',
    mood: ['melancholy', 'hope'],
    genre: 'literary-fiction',
    storyMode: 'linear',
    collabMode: 'none',
    status: 'ongoing',
    partsCount: 2,
    followersCount: 5,
    totalReads: 120,
    trendingScore: 7.8,
    publishedAt: new Date(Date.now() - 86400000 * 10),
    lastPartAt: new Date(Date.now() - 86400000 * 1),
  });

  await StoryPart.insertMany([
    {
      storyId: story._id,
      authorId: riya._id,
      partNumber: 1,
      title: 'The Gathering Clouds',
      content: `The sky had been grey for three weeks straight. Not the gentle grey of winter mornings, but a heavy, oppressive grey that pressed against the windows like a living thing.\n\nAmara stood on the balcony and watched the first drops fall. They hit the concrete with a sound like tiny fists knocking.`,
      language: 'en',
      mood: ['melancholy'],
      status: 'published',
      likesCount: 8,
      commentsCount: 2,
      readsCount: 67,
      publishedAt: new Date(Date.now() - 86400000 * 10),
    },
    {
      storyId: story._id,
      authorId: riya._id,
      partNumber: 2,
      title: 'What the Rain Carried',
      content: `By the second week, the streets had become rivers. Not the romantic kind you see in films — these were brown, churning things that carried away everything people had tried to hold onto.\n\nAmara watched a child's shoe float past her door. Just one shoe. She wondered about the other.`,
      language: 'en',
      mood: ['melancholy', 'hope'],
      status: 'published',
      likesCount: 5,
      commentsCount: 1,
      readsCount: 43,
      publishedAt: new Date(Date.now() - 86400000 * 1),
    },
  ]);
  console.log(`   Created 1 story with 2 parts.`);

  // ── FOLLOWS ──────────────────────────────────────────────────────────────
  console.log('🤝 Creating follows...');
  await Follow.insertMany([
    { followerId: arjun._id, followingId: riya._id, isMutual: false },
    { followerId: nadia._id, followingId: riya._id, isMutual: false },
    { followerId: testPoet._id, followingId: riya._id, isMutual: false },
    { followerId: riya._id, followingId: arjun._id, isMutual: true },
    { followerId: riya._id, followingId: nadia._id, isMutual: false },
    { followerId: nadia._id, followingId: arjun._id, isMutual: false },
    { followerId: testPoet._id, followingId: arjun._id, isMutual: false },
    { followerId: testPoet._id, followingId: nadia._id, isMutual: false },
  ]);
  console.log('   Created 8 follow relationships.');

  // ── LIKES ────────────────────────────────────────────────────────────────
  console.log('❤️ Creating likes...');
  await Like.insertMany([
    { userId: arjun._id, targetId: poems[0]._id, targetType: 'poem' },
    { userId: nadia._id, targetId: poems[0]._id, targetType: 'poem' },
    { userId: riya._id, targetId: poems[2]._id, targetType: 'poem' },
    { userId: testPoet._id, targetId: poems[2]._id, targetType: 'poem' },
    { userId: arjun._id, targetId: poems[3]._id, targetType: 'poem' },
  ]);
  console.log('   Created 5 likes.');

  // ── COMMENTS ─────────────────────────────────────────────────────────────
  console.log('💬 Creating comments...');
  await Comment.insertMany([
    {
      targetId: poems[0]._id,
      targetType: 'poem',
      authorId: arjun._id,
      content: 'This made me feel something I cannot name.',
      likesCount: 3,
    },
    {
      targetId: poems[0]._id,
      targetType: 'poem',
      authorId: nadia._id,
      content: 'The rain speaks better than most poets. You captured it well.',
      likesCount: 1,
    },
    {
      targetId: poems[2]._id,
      targetType: 'poem',
      authorId: riya._id,
      content: 'The pigeons line hit me hard. Brilliant.',
      likesCount: 2,
    },
  ]);
  console.log('   Created 3 comments.');

  // ── NOTIFICATIONS ────────────────────────────────────────────────────────
  console.log('🔔 Creating notifications...');
  await Notification.insertMany([
    {
      recipientId: riya._id,
      type: 'new_follower',
      actorId: arjun._id,
      entityId: null,
      entityType: null,
      poeticMessage: 'A new reader has found their way to your words.',
      isRead: false,
    },
    {
      recipientId: riya._id,
      type: 'poem_liked',
      actorId: nadia._id,
      entityId: poems[0]._id,
      entityType: 'poem',
      poeticMessage: 'Someone paused on your poem tonight.',
      isRead: false,
    },
    {
      recipientId: riya._id,
      type: 'comment',
      actorId: arjun._id,
      entityId: poems[0]._id,
      entityType: 'poem',
      poeticMessage: 'Someone added a voice to your poem.',
      isRead: true,
    },
    {
      recipientId: arjun._id,
      type: 'new_follower',
      actorId: riya._id,
      entityId: null,
      entityType: null,
      poeticMessage: 'A new reader has found their way to your words.',
      isRead: false,
    },
    {
      recipientId: testPoet._id,
      type: 'poem_liked',
      actorId: riya._id,
      entityId: poems[5]._id,
      entityType: 'poem',
      poeticMessage: 'Someone paused on your poem tonight.',
      isRead: false,
    },
  ]);
  console.log('   Created 5 notifications.');

  // ── UPDATE COUNTERS ──────────────────────────────────────────────────────
  console.log('📊 Updating user counters...');
  await User.findByIdAndUpdate(riya._id, {
    followersCount: 3,
    followingCount: 2,
    poemsCount: 2,
  });
  await User.findByIdAndUpdate(arjun._id, {
    followersCount: 2,
    followingCount: 1,
    poemsCount: 1,
  });
  await User.findByIdAndUpdate(nadia._id, {
    followersCount: 1,
    followingCount: 3,
    poemsCount: 2,
  });

  // ── DONE ─────────────────────────────────────────────────────────────────
  console.log('\n✅ Seed complete!');
  console.log('\n📋 Test accounts:');
  console.log('   Email: riya@verso.test     | Password: password123');
  console.log('   Email: arjun@verso.test    | Password: password123');
  console.log('   Email: nadia@verso.test    | Password: password123');
  console.log('   Email: test@verso.test     | Password: password123');
  console.log('\n📊 Summary:');
  console.log(`   Users:    ${await User.countDocuments()}`);
  console.log(`   Poems:    ${await Poem.countDocuments()}`);
  console.log(`   Stories:  ${await Story.countDocuments()}`);
  console.log(`   Parts:    ${await StoryPart.countDocuments()}`);
  console.log(`   Follows:  ${await Follow.countDocuments()}`);
  console.log(`   Likes:    ${await Like.countDocuments()}`);
  console.log(`   Comments: ${await Comment.countDocuments()}`);
  console.log(`   Notifs:   ${await Notification.countDocuments()}`);

  await mongoose.disconnect();
  console.log('\n👋 Disconnected from MongoDB.');
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
