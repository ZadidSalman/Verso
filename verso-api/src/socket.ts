import { Server as HttpServer } from 'http';
import { Server as SocketServer } from 'socket.io';
import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';

let io: SocketServer | null = null;

export function initSocket(server: HttpServer) {
  io = new SocketServer(server, {
    cors: {
      origin: process.env.CORS_ORIGIN || '*',
      methods: ['GET', 'POST'],
    },
  });

  io.use((socket, next) => {
    const token = socket.handshake.headers.authorization?.replace('Bearer ', '');
    if (!token) return next(new Error('Authentication error'));

    try {
      const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET!) as { id: string };
      socket.data.userId = decoded.id;
      next();
    } catch {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    const userId = socket.data.userId;

    // Join conversation room
    socket.on('join_conversation', (conversationId: string) => {
      socket.join(`conversation:${conversationId}`);
    });

    // Send message
    socket.on('send_message', async (data: { conversationId: string; content: string; type?: string }) => {
      if (!io) return;
      io.to(`conversation:${data.conversationId}`).emit('new_message', {
        ...data,
        senderId: userId,
        sentAt: new Date().toISOString(),
      });
    });

    // Typing indicator
    socket.on('typing', (data: { conversationId: string }) => {
      if (!io) return;
      socket.to(`conversation:${data.conversationId}`).emit('user_typing', {
        userId,
        conversationId: data.conversationId,
      });
    });

    // Stop typing
    socket.on('stop_typing', (data: { conversationId: string }) => {
      if (!io) return;
      socket.to(`conversation:${data.conversationId}`).emit('stop_typing', {
        userId,
        conversationId: data.conversationId,
      });
    });

    // Mark as read
    socket.on('mark_read', (data: { conversationId: string }) => {
      // Handled via REST API for DB persistence
    });

    socket.on('disconnect', () => {
      // Cleanup
    });
  });

  return io;
}

export function getIO(): SocketServer | null {
  return io;
}
