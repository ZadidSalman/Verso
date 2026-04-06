import { GoogleAuth } from 'google-auth-library';
import axios from 'axios';

const FCM_PROJECT_ID = process.env.FCM_PROJECT_ID;
const FCM_SCOPES = ['https://www.googleapis.com/auth/firebase.messaging'];

const auth = new GoogleAuth({
  scopes: FCM_SCOPES,
  credentials: process.env.GOOGLE_APPLICATION_CREDENTIALS
    ? JSON.parse(process.env.GOOGLE_APPLICATION_CREDENTIALS)
    : undefined,
});

/**
 * Get an OAuth2 access token for FCM HTTP v1 API.
 */
async function getAccessToken(): Promise<string> {
  const client = await auth.getClient();
  const token = await client.getAccessToken();
  return token.token!;
}

/**
 * Send a push notification via FCM HTTP v1 API.
 *
 * @param token - The device FCM registration token
 * @param title - Notification title
 * @param body - Notification body
 * @param data - Optional key-value data payload for tap routing
 */
export async function sendPushNotification(
  token: string,
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<boolean> {
  if (!FCM_PROJECT_ID) {
    console.error('[FCM] FCM_PROJECT_ID not set — skipping push');
    return false;
  }

  try {
    const accessToken = await getAccessToken();
    const url = `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`;

    const payload: Record<string, unknown> = {
      message: {
        token,
        notification: { title, body },
      },
    };

    if (data && Object.keys(data).length > 0) {
      (payload.message as Record<string, unknown>).data = data;
    }

    const response = await axios.post(url, payload, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
    });

    return response.status === 200;
  } catch (error: any) {
    const status = error?.response?.status;

    // Token no longer valid — caller should clean it up
    if (status === 404 || status === 400) {
      console.warn(`[FCM] Invalid/expired token: ${token}`);
      throw new Error('INVALID_TOKEN');
    }

    console.error('[FCM] Failed to send push:', error?.message ?? error);
    return false;
  }
}

/**
 * Send to multiple tokens — returns map of token → success.
 */
export async function sendPushToMultiple(
  tokens: string[],
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<Map<string, boolean>> {
  const results = new Map<string, boolean>();

  for (const token of tokens) {
    try {
      const ok = await sendPushNotification(token, title, body, data);
      results.set(token, ok);
    } catch {
      results.set(token, false);
    }
  }

  return results;
}
