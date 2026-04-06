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

import { User } from './models/User.model';
import { Poem } from './models/Poem.model';
import { Story } from './models/Story.model';
import { StoryPart } from './models/StoryPart.model';
import { Thought } from './models/Thought.model';
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
    Thought.deleteMany({}),
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
    {
      authorId: arjun._id,
      title: 'Silence Between Notes',
      content: `The piano rests\nbut the music lingers\nin the dust above the keys.\n\nWe are all just\nwaiting to be played.`,
      slug: 'silence-between-notes-yz3abc',
      language: 'en',
      mood: ['melancholy', 'wonder'],
      tags: ['music', 'silence'],
      status: 'published',
      likesCount: 9,
      commentsCount: 2,
      readsCount: 38,
      trendingScore: 6.8,
      wordCount: 22,
      lineCount: 7,
      publishedAt: new Date(Date.now() - 86400000 * 6),
    },
    {
      authorId: nadia._id,
      title: 'অপেক্ষা',
      content: `অপেক্ষা করি তোমার জন্য\nএকটি নিঃশব্দ সন্ধ্যায়।\n\nবাতাস বয়ে যায়,\nপাখিরা ফিরে আসে,\nতবু তুমি আসো না।`,
      slug: 'opekkha-def4gh',
      language: 'bn',
      mood: ['longing', 'nostalgia'],
      tags: ['waiting', 'love'],
      status: 'published',
      likesCount: 18,
      commentsCount: 4,
      readsCount: 72,
      trendingScore: 8.9,
      wordCount: 14,
      lineCount: 6,
      publishedAt: new Date(Date.now() - 86400000 * 7),
    },
    {
      authorId: riya._id,
      title: 'Midnight Garden',
      content: `At midnight the garden blooms\nwith flowers that only open\nfor those who cannot sleep.\n\nI water them with my thoughts\nand they grow tall\nenough to touch the stars.`,
      slug: 'midnight-garden-ij5klm',
      language: 'en',
      mood: ['wonder', 'hope'],
      tags: ['night', 'garden', 'insomnia'],
      status: 'published',
      likesCount: 14,
      commentsCount: 3,
      readsCount: 56,
      trendingScore: 7.9,
      wordCount: 36,
      lineCount: 8,
      publishedAt: new Date(Date.now() - 86400000 * 8),
    },
    {
      authorId: testPoet._id,
      title: 'Echo',
      content: `I shouted into the valley\nand the valley shouted back.\n\nBut it was only my own voice\nreturning to tell me\nI was not alone.`,
      slug: 'echo-nop6qrs',
      language: 'en',
      mood: ['hope', 'wonder'],
      tags: ['echo', 'solitude'],
      status: 'published',
      likesCount: 5,
      commentsCount: 1,
      readsCount: 18,
      trendingScore: 3.2,
      wordCount: 28,
      lineCount: 7,
      publishedAt: new Date(Date.now() - 86400000 * 12),
    },
  ]);
  console.log(`   Created ${poems.length} poems.`);

  // ── STORIES ──────────────────────────────────────────────────────────────
  console.log('📖 Creating stories with 5-9 parts each...');

  const storiesData = [
    {
      author: riya,
      title: 'The Last Monsoon',
      description: 'A story about the last rainy season before everything changed.',
      language: 'en',
      mood: ['melancholy', 'hope'],
      genre: 'literary-fiction',
      parts: [
        { title: 'The Gathering Clouds', content: 'The sky had been grey for three weeks straight. Not the gentle grey of winter mornings, but a heavy, oppressive grey that pressed against the windows like a living thing.\n\nAmara stood on the balcony and watched the first drops fall. They hit the concrete with a sound like tiny fists knocking.' },
        { title: 'What the Rain Carried', content: 'By the second week, the streets had become rivers. Not the romantic kind you see in films — these were brown, churning things that carried away everything people had tried to hold onto.\n\nAmara watched a child\'s shoe float past her door.' },
        { title: 'The Flood', content: 'The water rose slowly, almost politely, as if it was asking permission to enter. But it didn\'t wait for an answer.\n\nAmara moved everything she owned to the second floor.' },
        { title: 'What Was Lost', content: 'When the water finally receded, it left behind a layer of mud and memories. Some things could be cleaned. Others could not.' },
        { title: 'After the Storm', content: 'The sun returned on a Tuesday. By then, Amara had forgotten what dry clothes felt like.' },
      ]
    },
    {
      author: arjun,
      title: 'Neon Nights',
      description: 'A city that never sleeps, a soul that forgot how.',
      language: 'en',
      mood: ['urban', 'loneliness'],
      genre: 'contemporary',
      parts: [
        { title: 'The 3AM Diner', content: 'The coffee was cold but the waitress smiled like she meant it. That was enough for now.' },
        { title: 'Last Train', content: 'The metro doors closed between us. She waved. I didn\'t.' },
        { title: 'Rooftop Views', content: 'From here, the city looked like a circuit board. All lights, no connections.' },
        { title: 'Taxi Fare', content: 'The driver didn\'t ask questions. He just drove in circles while I counted streetlights.' },
        { title: '3AM Calls', content: 'She called at 3AM. I answered at 3AM. Some things are timed by the universe.' },
        { title: 'Dawn Patrol', content: 'The first jogger passed at 5:30. By then, I had already been awake for 24 hours.' },
      ]
    },
    {
      author: nadia,
      title: 'ঢাকার গল্প',
      description: 'Dhaka through different eyes.',
      language: 'bn',
      mood: ['nostalgia', 'home'],
      genre: 'memoir',
      parts: [
        { title: 'লালবাগের দুপুর', content: 'রিকশার ঘণ্টি, মাছ ভাজার গন্ধ, আর মাকে ডাকতে গিয়ে হারিয়ে যাওয়া।' },
        { title: 'বইয়ের দোকান', content: 'নতুন বইয়ের গন্ধ আর পুরনো বন্ধুর মুখ — দুটোই অপেক্ষা করত।' },
        { title: 'বৃষ্টির দিন', content: 'ছাতা উল্টে যায়, জুতা ভিজে যায়, কিন্তু বৃষ্টি থামে না।' },
        { title: 'বন্ধু', content: 'যে বন্ধু সব বলত, যে বন্ধু কিছুই বলত না — দুজনেই দরকার ছিল।' },
        { title: 'ফেরা', content: 'যেখান থেকে এসেছি, সেখানে ফিরে যাওয়ার সময় এলো।' },
        { title: 'স্মৃতি', content: 'মনে পড়ে সব, কিন্তু কথা আর আসে না।' },
      ]
    },
    {
      author: riya,
      title: 'The Letter Never Sent',
      description: 'Words that waited too long.',
      language: 'en',
      mood: ['longing', 'loss'],
      genre: 'epistolary',
      parts: [
        { title: 'Dear You,', content: 'I started this letter a hundred times. Each time, the words rearranged themselves into something else entirely.' },
        { title: 'The First Draft', content: 'Dear You,\n\nI hope this finds you well. That seems like a strange thing to write to someone who was once my entire weather system.' },
        { title: 'The Second Draft', content: 'The paper is soft from folding and unfolding. Each crease tells a story of words I couldn\'t say.' },
        { title: 'The Third Draft', content: 'Remember when we used to watch the sunset from your fire escape? I still watch sunsets. Just not from there.' },
        { title: 'The Final Draft', content: 'Sometimes I think about sending it. Then I remember some letters are better unsent. Some words are better left to the wind.' },
      ]
    },
    {
      author: arjun,
      title: 'Coffee Shop Confessions',
      description: 'Four walls, a thousand stories.',
      language: 'en',
      mood: ['wonder', 'observation'],
      genre: 'slice-of-life',
      parts: [
        { title: 'The Regular', content: 'He orders the same black coffee every morning at 7:15. Today he ordered two. I didn\'t ask why.' },
        { title: 'First Date', content: 'They laughed too loud, spoke too fast, and spilled coffee twice. By the end, they were holding hands.' },
        { title: 'The Writer', content: 'She comes here to write. Her笔记本 is always open, her coffee always cold. She never looks up.' },
        { title: 'The Closure', content: 'Two people sat at the corner table. One cried, one handed tissues. Some endings look like beginnings.' },
        { title: 'The Night Shift', content: 'The coffee shop becomes a different place after 10PM. Quieter. More honest.' },
        { title: 'The Last Cup', content: 'She came in one last time before leaving the city. "Surprise me," she said. So I did.' },
      ]
    },
    {
      author: nadia,
      title: 'Monsoon in Dhaka',
      description: 'When the sky breaks, the city remembers.',
      language: 'bn',
      mood: ['melancholy', 'hope'],
      genre: 'literary-fiction',
      parts: [
        { title: 'প্রথম বৃষ্টি', content: 'প্রথম বৃষ্টির জল পড়লে মনে হয় পুরো শহর নতুন জীবন পায়।' },
        { title: 'রিকশার চাকা', content: 'রিকশার চাকা বৃষ্টির জলে ডুবে যায়, কিন্তু চলতে থাকে।' },
        { title: 'ছাদের আশ্রয়', content: 'ছাদে দাঁড়িয়ে দেখি পুরো শহর ভেসে যাচ্ছে। কিন্তু আমরা ডুবি না।' },
        { title: 'পানি কমলে', content: 'পানি কমলে কাদা রইল। কাদার নিচে স্মৃতি। কাদার নিচে গল্প।' },
        { title: 'নতুন সকাল', content: 'সকাল হলো। শহর নতুন করে শুরু হলো। আমরাও।' },
      ]
    },
    {
      author: riya,
      title: 'The Garden at Midnight',
      description: 'Flowers that only bloom when no one is watching.',
      language: 'en',
      mood: ['wonder', 'magic'],
      genre: 'fantasy',
      parts: [
        { title: 'The Key', content: 'The garden gate is locked. But there\'s a key hidden where the moonflowers grow.' },
        { title: 'Night Bloom', content: 'At midnight, the impossible happens. Flowers open that have no names, colors that have no descriptions.' },
        { title: 'The Keeper', content: 'She\'s been here longer than the garden itself. She remembers when the first seed was planted.' },
        { title: 'What the Flowers Say', content: 'They speak in a language of fragrance and rustling leaves. If you listen, they tell you everything.' },
        { title: 'The Trade', content: '"Give us your saddest memory," the flowers whisper, "and we\'ll give you a night you\'ll never forget."' },
        { title: 'Morning After', content: 'When dawn breaks, the garden is ordinary again. But you remember. You always remember.' },
        { title: 'The Invitation', content: 'She leaves a single nightflower on your pillow. An invitation. A promise.' },
      ]
    },
    {
      author: arjun,
      title: 'Train to Nowhere',
      description: 'A journey that changed direction.',
      language: 'en',
      mood: ['adventure', 'discovery'],
      genre: 'travel',
      parts: [
        { title: 'Platform 9', content: 'The train was supposed to go to Delhi. I got on anyway.' },
        { title: 'The Unexpected Stop', content: 'It stopped at a station that wasn\'t on any map. A voice said, "Those who get off here have forgotten why they started."' },
        { title: 'The Village', content: 'The village had no name. Just houses, and people who looked like they had forgotten how to hurry.' },
        { title: 'The Elder', content: 'An old woman offered me tea. "You\'re looking for something," she said. "It\'s not in Delhi."' },
        { title: 'The Lesson', content: 'I stayed for a week. I learned that sometimes the destination is the journey, and the journey is the destination.' },
        { title: 'The Return', content: 'The same train came back. But I was different. And that made all the difference.' },
      ]
    },
    {
      author: nadia,
      title: 'Kitchen Stories',
      description: 'Recipes of love, loss, and finding home.',
      language: 'bn',
      mood: ['nostalgia', 'family'],
      genre: 'memoir',
      parts: [
        { title: 'চুলার পাশে', content: 'চুলার পাশে দাঁড়িয়ে রান্না শিখেছি। এই শিখনটাই আমার সবচেয়ে বড় শিক্ষা।' },
        { title: 'রেসিপি', content: 'মা বলতেন, "রেসিপি মনে রাখতে হবে না, স্বাদ মনে রাখতে হবে।"' },
        { title: 'একা রান্না', content: 'একা রান্না করতে গিয়ে কাঁদতে হয়। কিন্তু খেতে গিয়ে হাসতেও হয়।' },
        { title: 'খাবার স্মৃতি', content: 'একটা খাবারের গন্ধেই সব কিছু ফিরে আসে। সময়, মানুষ, স্থান।' },
        { title: 'হাতের স্পর্শ', content: 'বাবার হাতের ছোঁয়া, মার হাতের ছোঁয়া — এই দুটো স্পর্শ আলাদা করা যায় না।' },
        { title: 'নতুন প্রজন্ম', content: 'এখন আমি রান্না করি। আমার মেয়েও শিখছে। এভাবেই চলে যায় সব।' },
      ]
    },
    {
      author: riya,
      title: 'The Last Book',
      description: 'When words fail, silence speaks.',
      language: 'en',
      mood: ['contemplation', 'wisdom'],
      genre: 'philosophical',
      parts: [
        { title: 'The Last Page', content: 'She closed the book for the last time. The last page was blank, but she smiled anyway.' },
        { title: 'The Author', content: 'He wrote one book. Then spent the rest of his life living it.' },
        { title: 'The Reader', content: 'Some books are read once. Some books are read a hundred times. Some are never finished.' },
        { title: 'The Annotation', content: 'In the margins, someone had written: "This is where I found myself."' },
        { title: 'The Dedication', content: 'The book was dedicated "To those who never finished reading their own stories."' },
        { title: 'The Ending', content: 'There was no period at the end. Just a long pause, waiting for the reader to continue.' },
        { title: 'The Afterword', content: 'The afterword said: "This book is not the end. It\'s where the real story begins."' },
        { title: 'The Re-read', content: 'Years later, she read it again. The words were the same. But she was different.' },
      ]
    },
  ];

  // Create all stories with their parts
  let totalParts = 0;
  for (const storyData of storiesData) {
    const story = await Story.create({
      authorId: storyData.author._id,
      title: storyData.title,
      description: storyData.description,
      language: storyData.language,
      mood: storyData.mood,
      genre: storyData.genre,
      storyMode: 'linear',
      collabMode: 'none',
      status: storyData.parts.length > 6 ? 'ongoing' : 'completed',
      partsCount: storyData.parts.length,
      followersCount: Math.floor(Math.random() * 10) + 1,
      totalReads: Math.floor(Math.random() * 200) + 50,
      trendingScore: Math.random() * 5 + 5,
      publishedAt: new Date(Date.now() - 86400000 * (storiesData.indexOf(storyData) + 1)),
      lastPartAt: new Date(Date.now() - 86400000),
    });

    const parts = storyData.parts.map((part, index) => ({
      storyId: story._id,
      authorId: storyData.author._id,
      partNumber: index + 1,
      title: part.title,
      content: part.content,
      language: storyData.language,
      mood: storyData.mood,
      status: 'published',
      likesCount: Math.floor(Math.random() * 15) + 1,
      commentsCount: Math.floor(Math.random() * 5),
      readsCount: Math.floor(Math.random() * 100) + 20,
      publishedAt: new Date(Date.now() - 86400000 * (storyData.parts.length - index)),
    }));

    await StoryPart.insertMany(parts);
    totalParts += parts.length;
  }
  console.log(`   Created ${storiesData.length} stories with ${totalParts} parts.`);

  // ── THOUGHTS ──────────────────────────────────────────────────────────────
  console.log('💭 Creating thoughts...');
  const thoughtsData = [
    { author: riya, content: 'Sometimes the most profound poems are the ones we never write.', visibility: 'public', likesCount: 12 },
    { author: riya, content: 'The rain doesn\'t ask permission to fall. Neither should your words.', visibility: 'public', likesCount: 8 },
    { author: arjun, content: 'Silence is not empty. It\'s full of answers we\'re not ready to hear.', visibility: 'public', likesCount: 15 },
    { author: arjun, content: 'We read the same sky but see different stars.', visibility: 'mutual', likesCount: 6 },
    { author: nadia, content: 'কবিতা লিখতে গিয়ে কখনো কখনো মনে হয়, কলমটাই আমাকে লিখছে।', visibility: 'public', likesCount: 20 },
    { author: nadia, content: 'শব্দ নয়, নীরবতাই সবচেয়ে বড় কবিতা।', visibility: 'public', likesCount: 18 },
    { author: testPoet, content: 'Is it still a draft if it\'s the truest thing I\'ve ever written?', visibility: 'public', likesCount: 5 },
    { author: testPoet, content: 'Today I wrote a poem. It rhymed. I\'m not sure if that\'s good or bad.', visibility: 'public', likesCount: 3 },
    { author: riya, content: 'The best lines are the ones we cross out.', visibility: 'public', likesCount: 10 },
    { author: arjun, content: 'Every city has a poem. You just have to listen for it.', visibility: 'public', likesCount: 7 },
    { author: nadia, content: 'ভাষা হারালেও অনুভূতি হারায় না।', visibility: 'private', likesCount: 2 },
    { author: riya, content: 'Not all who wander are lost. Some are just looking for the right metaphor.', visibility: 'public', likesCount: 9 },
    { author: arjun, content: 'The blank page is not empty. It\'s waiting for courage.', visibility: 'public', likesCount: 11 },
    { author: testPoet, content: 'I wrote a poem about clouds. Then it rained. Coincidence?', visibility: 'mutual', likesCount: 4 },
    { author: nadia, content: 'সাদা কাগজে কালো কলম। এটাই সবচেয়ে সত্যিকারের ছবি।', visibility: 'public', likesCount: 14 },
  ];

  const thoughts = await Thought.insertMany(thoughtsData.map(t => ({
    authorId: t.author._id,
    content: t.content,
    visibility: t.visibility,
    likesCount: t.likesCount,
    createdAt: new Date(Date.now() - 86400000 * (thoughtsData.indexOf(t) + 1)),
  })));
  console.log(`   Created ${thoughts.length} thoughts.`);

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
  console.log(`   Thoughts: ${await Thought.countDocuments()}`);
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
