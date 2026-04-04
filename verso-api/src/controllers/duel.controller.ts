import { Request, Response } from 'express';
import { Duel } from '../models/Duel.model';
import { User } from '../models/User.model';
import { Poem } from '../models/Poem.model';
import { createNotification } from './notification.controller';
import mongoose from 'mongoose';

function formatDuel(duel: any) {
  const totalVotes = duel.votesForChallenger + duel.votesForChallengee;
  const challengerPercent = totalVotes > 0 ? (duel.votesForChallenger / totalVotes) * 100 : 50;
  const challengeePercent = totalVotes > 0 ? (duel.votesForChallengee / totalVotes) * 100 : 50;

  return {
    id: duel._id.toString(),
    theme: duel.theme,
    challengerId: duel.challengerId.toString(),
    challengeeId: duel.challengeeId.toString(),
    challengerPoemId: duel.challengerPoemId?.toString() ?? null,
    challengeePoemId: duel.challengeePoemId?.toString() ?? null,
    status: duel.status,
    votesForChallenger: duel.votesForChallenger,
    votesForChallengee: duel.votesForChallengee,
    challengerPercent: Math.round(challengerPercent),
    challengeePercent: Math.round(challengeePercent),
    totalVotes,
    voterIds: duel.voterIds.map((id: mongoose.Types.ObjectId) => id.toString()),
    winnerId: duel.winnerId?.toString() ?? null,
    endsAt: duel.endsAt,
    createdAt: duel.createdAt,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE a duel
// ─────────────────────────────────────────────────────────────────────────────

export async function createDuel(req: Request, res: Response): Promise<void> {
  try {
    const { challengeeId, theme, challengerPoemId } = req.body;

    if (!challengeeId || !theme || !challengerPoemId) {
      res.status(400).json({ message: 'Challengee, theme, and your poem are required.' });
      return;
    }

    if (challengeeId === req.user!._id.toString()) {
      res.status(400).json({ message: 'You cannot challenge yourself.' });
      return;
    }

    const challengee = await User.findById(challengeeId);
    if (!challengee) {
      res.status(404).json({ message: 'This poet has not been found.' });
      return;
    }

    const poem = await Poem.findById(challengerPoemId);
    if (!poem) {
      res.status(404).json({ message: 'Your poem has not been found.' });
      return;
    }

    const duel = await Duel.create({
      theme,
      challengerId: req.user!._id,
      challengeeId,
      challengerPoemId,
      status: 'pending',
    });

    // Notify challengee
    await createNotification({
      recipientId: challengeeId,
      type: 'duel_invite',
      actorId: req.user!._id.toString(),
      entityId: duel._id.toString(),
      entityType: 'duel',
    });

    res.status(201).json({ duel: formatDuel(duel) });
  } catch (error) {
    console.error('Failed to create duel:', error);
    res.status(500).json({ message: 'Could not issue this challenge. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET a duel by ID
// ─────────────────────────────────────────────────────────────────────────────

export async function getDuel(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid duel ID.' });
      return;
    }

    const duel = await Duel.findById(id);
    if (!duel) {
      res.status(404).json({ message: 'This duel has ended.' });
      return;
    }

    res.status(200).json({ duel: formatDuel(duel) });
  } catch (error) {
    console.error('Failed to get duel:', error);
    res.status(500).json({ message: 'Could not find this duel.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACCEPT a duel
// ─────────────────────────────────────────────────────────────────────────────

export async function acceptDuel(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;
    const { challengeePoemId } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid duel ID.' });
      return;
    }

    const duel = await Duel.findById(id);
    if (!duel) {
      res.status(404).json({ message: 'This duel has ended.' });
      return;
    }

    if (duel.challengeeId.toString() !== req.user!._id.toString()) {
      res.status(403).json({ message: 'This challenge is not for you.' });
      return;
    }

    if (duel.status !== 'pending') {
      res.status(400).json({ message: 'This duel is no longer pending.' });
      return;
    }

    duel.status = 'active';
    duel.challengeePoemId = challengeePoemId || null;
    duel.endsAt = new Date(Date.now() + 48 * 60 * 60 * 1000); // 48 hours
    await duel.save();

    // Notify challenger
    await createNotification({
      recipientId: duel.challengerId.toString(),
      type: 'duel_result',
      actorId: req.user!._id.toString(),
      entityId: id,
      entityType: 'duel',
    });

    res.status(200).json({ duel: formatDuel(duel), message: 'The duel begins.' });
  } catch (error) {
    console.error('Failed to accept duel:', error);
    res.status(500).json({ message: 'Could not accept this duel. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VOTE in a duel
// ─────────────────────────────────────────────────────────────────────────────

export async function voteDuel(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id as string;
    const { side } = req.body; // 'challenger' or 'challengee'

    if (!['challenger', 'challengee'].includes(side)) {
      res.status(400).json({ message: 'Choose a side: challenger or challengee.' });
      return;
    }

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400).json({ message: 'Invalid duel ID.' });
      return;
    }

    const duel = await Duel.findById(id);
    if (!duel) {
      res.status(404).json({ message: 'This duel has ended.' });
      return;
    }

    if (duel.status !== 'active') {
      res.status(400).json({ message: 'This duel is not open for voting.' });
      return;
    }

    if (duel.endsAt && new Date() > duel.endsAt) {
      duel.status = 'completed';
      await duel.save();
      res.status(400).json({ message: 'This duel has ended.' });
      return;
    }

    // Check if user already voted
    if (duel.voterIds.some((vid: mongoose.Types.ObjectId) => vid.toString() === req.user!._id.toString())) {
      res.status(400).json({ message: 'You have already cast your vote.' });
      return;
    }

    // Record vote
    duel.voterIds.push(req.user!._id as any);
    if (side === 'challenger') {
      duel.votesForChallenger += 1;
    } else {
      duel.votesForChallengee += 1;
    }
    await duel.save();

    res.status(200).json({ duel: formatDuel(duel), message: 'Your voice has been heard.' });
  } catch (error) {
    console.error('Failed to vote in duel:', error);
    res.status(500).json({ message: 'Could not cast your vote. Please try again.' });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET active/trending duels
// ─────────────────────────────────────────────────────────────────────────────

export async function getActiveDuels(req: Request, res: Response): Promise<void> {
  try {
    const { limit = '10', cursor } = req.query;

    const query: Record<string, unknown> = { status: 'active' };
    if (cursor) {
      query.createdAt = { $lt: new Date(cursor as string) };
    }

    const duels = await Duel.find(query)
      .sort({ votesForChallenger: -1, votesForChallengee: -1 })
      .limit(parseInt(limit as string) + 1);

    const hasMore = duels.length > parseInt(limit as string);
    if (hasMore) duels.pop();

    res.status(200).json({
      items: duels.map(formatDuel),
      hasMore,
    });
  } catch (error) {
    console.error('Failed to get active duels:', error);
    res.status(500).json({ message: 'Could not find active duels.' });
  }
}
