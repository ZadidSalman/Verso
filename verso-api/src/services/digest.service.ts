import mongoose from 'mongoose';
import axios from 'axios';

const FROM_EMAIL = process.env.FROM_EMAIL ?? 'hello@verso.app';
const FROM_NAME = 'Verso';

/**
 * Send the weekly digest email to a single user via Brevo REST API.
 */
export async function sendDigestEmail(
  userId: string,
): Promise<boolean> {
  const user = await User.findById(userId).lean() as any;
  if (!user || !user.digestEnabled) return false;

  const data = await buildDigestData(user);
  if (!data) return false;

  const html = renderDigestEmail(data, user.displayName ?? user.username ?? 'Poet');

  try {
    await axios.post(
      'https://api.brevo.com/v3/smtp/email',
      {
        sender: { email: FROM_EMAIL, name: FROM_NAME },
        to: [{ email: user.email, name: user.displayName ?? user.username }],
        subject: `Your weekly verse · ${data.weekStart} – ${data.weekEnd}`,
        htmlContent: html,
      },
      {
        headers: {
          'api-key': process.env.BREVO_API_KEY,
          'Content-Type': 'application/json',
        },
      }
    );
    return true;
  } catch (err) {
    console.error(`[Digest] Failed to send email to ${user.email}:`, err);
    return false;
  }
}

/**
 * Build the weekly digest data for a given user.
 */
async function buildDigestData(user: any): Promise<DigestData | null> {
  const now = new Date();
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  // Top poems of the week (by likes)
  const topPoems = await Poem.aggregate([
    { $match: { createdAt: { $gte: weekAgo } } },
    { $sort: { likesCount: -1 } },
    { $limit: 5 },
    {
      $lookup: {
        from: 'users',
        localField: 'author',
        foreignField: '_id',
        as: 'authorDoc',
      },
    },
    { $unwind: '$authorDoc' },
    {
      $project: {
        title: 1,
        author: '$authorDoc.displayName',
        likesCount: 1,
      },
    },
  ]);

  // Trending moods this week
  const moodAgg = await Poem.aggregate([
    { $match: { createdAt: { $gte: weekAgo }, mood: { $ne: [] } } },
    { $unwind: '$mood' },
    { $group: { _id: '$mood', count: { $sum: 1 } } },
    { $sort: { count: -1 } },
    { $limit: 3 },
  ]);
  const trendingMoods = moodAgg.map((m: any) => m._id);

  // New followers count for this user
  const FollowModel =
    mongoose.models.Follow ||
    mongoose.model(
      'Follow',
      new mongoose.Schema({
        following: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        createdAt: Date,
      }),
    );

  const newFollowersCount = await FollowModel.countDocuments({
    following: user._id,
    createdAt: { $gte: weekAgo },
  });

  const weekStart = weekAgo.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
  });
  const weekEnd = now.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
  });

  return {
    topPoems: topPoems.slice(0, 5),
    trendingMoods,
    newFollowersCount,
    weekStart,
    weekEnd,
  };
}

/**
 * Render the HTML email body for the weekly digest.
 */
function renderDigestEmail(data: DigestData, username: string): string {
  const poemsHtml = data.topPoems
    .map(
      (p) => `
      <tr>
        <td style="padding: 12px 0; border-bottom: 1px solid #D8E5DC;">
          <strong style="color: #1F6B5A; font-size: 16px;">${p.title}</strong>
          <br />
          <span style="color: #404944; font-size: 14px;">
            by ${p.author} · ${p.likesCount} hearts
          </span>
        </td>
      </tr>
    `,
    )
    .join('');

  const moodsHtml = data.trendingMoods
    .map(
      (m) =>
        `<span style="display:inline-block; background:#A8DACC; color:#00201A; padding:4px 12px; border-radius:4px; margin:4px; font-size:13px;">${m}</span>`,
    )
    .join('');

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8" />
      <style>
        body { font-family: 'DM Sans', sans-serif; color: #1A1C1A; background: #F6FAF8; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 32px 24px; }
        .header { text-align: center; padding-bottom: 24px; border-bottom: 1px solid #D8E5DC; }
        .header h1 { font-family: 'Playfair Display', serif; color: #1F6B5A; margin: 0; font-size: 28px; }
        .header p { color: #404944; margin: 8px 0 0; font-size: 14px; }
        .section { margin-top: 24px; }
        .section h2 { font-family: 'Playfair Display', serif; color: #1F6B5A; font-size: 20px; margin-bottom: 12px; }
        .footer { text-align: center; margin-top: 32px; padding-top: 16px; border-top: 1px solid #D8E5DC; color: #6B7B6E; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>Verso</h1>
          <p>Your weekly verse · ${data.weekStart} – ${data.weekEnd}</p>
        </div>

        <div class="section">
          <p>Hello ${username},</p>
          <p>Here is what stirred this week in the world of verse.</p>
        </div>

        <div class="section">
          <h2>Most Loved Poems</h2>
          <table style="width:100%; border-collapse:collapse;">
            ${poemsHtml || '<tr><td style="padding:12px 0; color:#6B7B6E;">No poems this week — perhaps it is time to write.</td></tr>'}
          </table>
        </div>

        <div class="section">
          <h2>Trending Moods</h2>
          <div>${moodsHtml || '<span style="color:#6B7B6E;">Quiet waters this week.</span>'}</div>
        </div>

        ${data.newFollowersCount > 0 ? `
        <div class="section">
          <h2>New Readers</h2>
          <p style="color:#404944;">${data.newFollowersCount} new ${data.newFollowersCount === 1 ? 'reader joined' : 'readers joined'} your circle this week.</p>
        </div>
        ` : ''}

        <div class="footer">
          <p>Verso — A literary sanctuary</p>
          <p>You are receiving this because you opted in to weekly digests.</p>
        </div>
      </div>
    </body>
    </html>
  `;
}

/**
 * Send weekly digest to all active users.
 * Returns { sent, failed, skipped } counts.
 */
export async function sendWeeklyDigest(): Promise<{
  sent: number;
  failed: number;
  skipped: number;
}> {
  const oneMonthAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

  const users = await User.find({
    digestEnabled: true,
    lastActiveAt: { $gte: oneMonthAgo },
  }).lean();

  let sent = 0;
  let failed = 0;
  let skipped = 0;

  for (const user of users) {
    const ok = await sendDigestEmail((user as any)._id.toString());
    if (ok) sent++;
    else failed++;
  }

  // Users who were inactive — skipped
  const inactiveCount = await User.countDocuments({
    digestEnabled: true,
    $or: [{ lastActiveAt: { $lt: oneMonthAgo } }, { lastActiveAt: null }],
  });
  skipped = inactiveCount;

  console.log(
    `[Digest] Weekly digest complete — sent: ${sent}, failed: ${failed}, skipped: ${skipped}`,
  );

  return { sent, failed, skipped };
}
