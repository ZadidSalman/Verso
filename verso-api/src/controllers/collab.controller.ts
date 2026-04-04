import { Request, Response } from 'express';
import { CollabPoem } from '../models/CollabPoem.model';
import { createNotification } from './notification.controller';
import { triggerPusherEvent } from '../services/pusher.service';
import mongoose from 'mongoose';

function formatCollabPoem(poem: any) {
  return {
    id: poem._id.toString(),
    title: poem.title,
    language: poem.language,
    originatorId: poem.originatorId.toString(),
    collabType: poem.collabType,
    status: poem.status,
    stanzas: poem.stanzas.map((s: any) => ({
      stanzaId: s.stanzaId.toString(),
      authorId: s.authorId.toString(),
      content: s.content,
      order: s.order,
      isApproved: s.isApproved,
      createdAt: s.createdAt,
    })),
    contributorsCount: poem.contributorsCount,
    mood: poem.mood,
    likesCount: poem.likesCount,
    commentsCount: poem.commentsCount,
    readsCount: poem.readsCount,
    trendingScore: poem.trendingScore,
    createdAt: poem.createdAt,
    updatedAt: poem.updatedAt,
  };
}

export async function createCollabPoem(req: Request, res: Response): Promise<void> {
  try {
    const { title, language, collabType, mood } = req.body;
    if (!title) { res.status(400).json({ message: 'Title is required.' }); return; }

    const poem = await CollabPoem.create({
      title, language: language || 'en', originatorId: req.user!._id,
      collabType: collabType || 'open', status: 'open', mood: mood || [],
    });
    const populated = await CollabPoem.findById(poem._id);
    res.status(201).json({ poem: formatCollabPoem(populated) });
  } catch (error) {
    console.error('Failed to create collab poem:', error);
    res.status(500).json({ message: 'Could not start this collaboration.' });
  }
}

export async function getCollabPoem(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;
    if (!mongoose.Types.ObjectId.isValid(id)) { res.status(400).json({ message: 'Invalid poem ID.' }); return; }
    const poem = await CollabPoem.findById(id);
    if (!poem) { res.status(404).json({ message: 'This poem has been taken away.' }); return; }
    res.status(200).json({ poem: formatCollabPoem(poem) });
  } catch (error) {
    console.error('Failed to get collab poem:', error);
    res.status(500).json({ message: 'Could not find this poem.' });
  }
}

export async function submitStanza(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;
    const { content } = req.body;
    if (!content || content.trim().length === 0) { res.status(400).json({ message: 'Your stanza needs words.' }); return; }
    if (content.length > 2000) { res.status(400).json({ message: 'Stanza too long. Max 2,000 chars.' }); return; }
    if (!mongoose.Types.ObjectId.isValid(id)) { res.status(400).json({ message: 'Invalid poem ID.' }); return; }

    const poem = await CollabPoem.findById(id);
    if (!poem) { res.status(404).json({ message: 'This poem has been taken away.' }); return; }
    if (poem.status === 'closed') { res.status(400).json({ message: 'No longer accepting stanzas.' }); return; }

    const order = poem.stanzas.length + 1;
    poem.stanzas.push({ stanzaId: new mongoose.Types.ObjectId(), authorId: req.user!._id as any, content: content.trim(), order, isApproved: true, createdAt: new Date() });
    poem.contributorsCount = new Set(poem.stanzas.map((s: any) => s.authorId.toString())).size;
    await poem.save();

    await triggerPusherEvent(`collab-${id}`, 'stanza_added', { poemId: id, stanzaOrder: order, authorId: req.user!._id.toString() });
    if (poem.originatorId.toString() !== req.user!._id.toString()) {
      await createNotification({ recipientId: poem.originatorId.toString(), type: 'stanza_added', actorId: req.user!._id.toString(), entityId: id, entityType: 'collab' });
    }

    const updated = await CollabPoem.findById(id);
    res.status(201).json({ poem: formatCollabPoem(updated) });
  } catch (error) {
    console.error('Failed to submit stanza:', error);
    res.status(500).json({ message: 'Could not add your line.' });
  }
}

export async function closeCollabPoem(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;
    if (!mongoose.Types.ObjectId.isValid(id)) { res.status(400).json({ message: 'Invalid poem ID.' }); return; }
    const poem = await CollabPoem.findById(id);
    if (!poem) { res.status(404).json({ message: 'This poem has been taken away.' }); return; }
    if (poem.originatorId.toString() !== req.user!._id.toString()) { res.status(403).json({ message: 'Only the originator can close this.' }); return; }
    poem.status = 'closed';
    await poem.save();
    res.status(200).json({ poem: formatCollabPoem(poem), message: 'The poem is complete.' });
  } catch (error) {
    console.error('Failed to close collab poem:', error);
    res.status(500).json({ message: 'Could not close this poem.' });
  }
}

export async function getTrendingCollabs(req: Request, res: Response): Promise<void> {
  try {
    const { limit = '10', cursor } = req.query;
    const query: Record<string, unknown> = {};
    if (cursor) query.createdAt = { $lt: new Date(cursor as string) };
    const poems = await CollabPoem.find(query).sort({ trendingScore: -1, createdAt: -1 }).limit(parseInt(limit as string) + 1);
    const hasMore = poems.length > parseInt(limit as string);
    if (hasMore) poems.pop();
    res.status(200).json({ items: poems.map(formatCollabPoem), hasMore });
  } catch (error) {
    console.error('Failed to get trending collabs:', error);
    res.status(500).json({ message: 'Could not find collaborative poems.' });
  }
}
