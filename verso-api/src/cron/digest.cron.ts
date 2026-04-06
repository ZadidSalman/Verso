import cron from 'node-cron';
import { sendWeeklyDigest } from '../services/digest.service';

/**
 * Weekly digest cron job — runs every Monday at 9:00 AM UTC.
 */
export function startDigestCron(): void {
  // '0 9 * * 1' = every Monday at 9:00 AM UTC
  cron.schedule('0 9 * * 1', async () => {
    console.log('[Cron] Starting weekly digest job...');
    try {
      const result = await sendWeeklyDigest();
      console.log('[Cron] Weekly digest finished:', result);
    } catch (err) {
      console.error('[Cron] Weekly digest failed:', err);
    }
  });

  console.log('[Cron] Weekly digest cron registered (Monday 9AM UTC)');
}
