import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import mongoose from 'mongoose';

import authRoutes from './routes/auth.routes';
import usersRoutes from './routes/users.routes';
import poemRoutes from './routes/poem.routes';
import feedRoutes from './routes/feed.routes';
import likeRoutes from './routes/like.routes';
import commentRoutes from './routes/comment.routes';
import storyRoutes from './routes/story.routes';
import notificationRoutes from './routes/notification.routes';

// ─────────────────────────────────────────────────────────────────────────────
// APP SETUP
// ─────────────────────────────────────────────────────────────────────────────

const app = express();

// Trust proxy MUST be set before rate limiting for correct IP detection behind Cloudflare/Render
app.set('trust proxy', 1);

// ─────────────────────────────────────────────────────────────────────────────
// MIDDLEWARE
// ─────────────────────────────────────────────────────────────────────────────

// Compression
app.use(compression());

// Security headers
app.use(
  helmet({
    contentSecurityPolicy: false, // Disable CSP for API
  })
);

// CORS
app.use(
  cors({
    origin: process.env.NODE_ENV === 'production' 
      ? ['https://verso.app'] 
      : true, // Allow all origins in development
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  })
);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('dev'));
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTES
// ─────────────────────────────────────────────────────────────────────────────

// Health check
app.get('/health', (_, res) => {
  res.status(200).json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
  });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/poems', poemRoutes);
app.use('/api/feed', feedRoutes);
app.use('/api/likes', likeRoutes);
app.use('/api/comments', commentRoutes);
app.use('/api/stories', storyRoutes);
app.use('/api/notifications', notificationRoutes);

// 404 handler
app.use((_, res) => {
  res.status(404).json({ message: 'Not found.' });
});

// Error handler
app.use((err: Error, _: express.Request, res: express.Response, __: express.NextFunction) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ message: 'Something went wrong. Please try again.' });
});

// ─────────────────────────────────────────────────────────────────────────────
// DATABASE & SERVER
// ─────────────────────────────────────────────────────────────────────────────

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI;
    if (!mongoUri) {
      throw new Error('MONGODB_URI environment variable is not set');
    }

    await mongoose.connect(mongoUri);
    console.log('Connected to MongoDB');

    // Start server
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
      console.log(`Health check: http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  await mongoose.connection.close();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received. Shutting down gracefully...');
  await mongoose.connection.close();
  process.exit(0);
});

startServer();

export default app;
