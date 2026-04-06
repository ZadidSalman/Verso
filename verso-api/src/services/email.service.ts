import axios from 'axios';

const FROM_EMAIL = process.env.FROM_EMAIL ?? 'hello@verso.app';
const FROM_NAME = 'Verso';

const baseStyles = `
  body { 
    font-family: 'DM Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    background-color: #F6FAF8;
    margin: 0;
    padding: 40px 20px;
    color: #1A1C1A;
  }
  .container {
    max-width: 480px;
    margin: 0 auto;
    background-color: #FFFFFF;
    border-radius: 16px;
    padding: 40px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  }
  .logo {
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 28px;
    font-weight: 600;
    color: #1F6B5A;
    text-align: center;
    margin-bottom: 32px;
  }
  h1 {
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 24px;
    font-weight: 600;
    color: #1A1C1A;
    margin: 0 0 16px 0;
  }
  p {
    font-size: 16px;
    line-height: 24px;
    color: #404944;
    margin: 0 0 16px 0;
  }
  .otp-code {
    font-family: 'DM Sans', monospace;
    font-size: 32px;
    font-weight: 600;
    letter-spacing: 8px;
    color: #1F6B5A;
    text-align: center;
    background-color: #EDF4F0;
    padding: 20px;
    border-radius: 8px;
    margin: 24px 0;
  }
  .footer {
    font-size: 12px;
    color: #8FA89A;
    text-align: center;
    margin-top: 32px;
    padding-top: 24px;
    border-top: 1px solid #D8E5DC;
  }
  .accent {
    color: #1F6B5A;
  }
`;

function wrapTemplate(content: string): string {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>${baseStyles}</style>
    </head>
    <body>
      <div class="container">
        <div class="logo">Verso</div>
        ${content}
        <div class="footer">
          <p>Where words find their world.</p>
          <p>This email was sent by Verso. If you didn't request this, you can safely ignore it.</p>
        </div>
      </div>
    </body>
    </html>
  `;
}

async function sendEmail(to: string, subject: string, html: string): Promise<void> {
  await axios.post(
    'https://api.brevo.com/v3/smtp/email',
    {
      sender: { email: FROM_EMAIL, name: FROM_NAME },
      to: [{ email: to }],
      subject,
      htmlContent: html,
    },
    {
      headers: {
        'api-key': process.env.BREVO_API_KEY,
        'Content-Type': 'application/json',
      },
    }
  );
}

/**
 * Send OTP verification email
 */
export async function sendOtpEmail(to: string, otp: string): Promise<void> {
  const html = wrapTemplate(`
    <h1>Verify your email</h1>
    <p>Enter this code to begin your journey with Verso:</p>
    <div class="otp-code">${otp}</div>
    <p>This code expires in <strong>10 minutes</strong>.</p>
    <p>If you didn't create a Verso account, you can safely ignore this email.</p>
  `);

  await sendEmail(to, 'Your Verso verification code', html);
  console.log(`OTP email sent to ${to}`);
}

/**
 * Send password reset OTP email
 */
export async function sendPasswordResetOtp(to: string, otp: string): Promise<void> {
  const html = wrapTemplate(`
    <h1>Reset your password</h1>
    <p>We received a request to reset your Verso password. Enter this code to continue:</p>
    <div class="otp-code">${otp}</div>
    <p>This code expires in <strong>10 minutes</strong>.</p>
    <p>If you didn't request a password reset, you can safely ignore this email. Your password will remain unchanged.</p>
  `);

  await sendEmail(to, 'Reset your Verso password', html);
  console.log(`Password reset email sent to ${to}`);
}

/**
 * Send welcome email after first verification
 */
export async function sendWelcomeEmail(to: string, displayName: string): Promise<void> {
  const name = displayName || 'Poet';
  
  const html = wrapTemplate(`
    <h1>Your first page is blank.</h1>
    <p>Welcome, <span class="accent">${name}</span>.</p>
    <p>Every great story starts with an empty page. Verso is now your canvas—a sanctuary where words become worlds and thoughts find their home.</p>
    <p>The poets are waiting. The page is ready.</p>
    <p style="font-style: italic; color: #6B7B6E; margin-top: 24px;">Begin when you're ready. There's no rush here.</p>
  `);

  try {
    await sendEmail(to, 'Your first page is blank.', html);
    console.log(`Welcome email sent to ${to}`);
  } catch (error) {
    console.error('Failed to send welcome email:', error);
  }
}

/**
 * Send weekly digest email
 */
export async function sendWeeklyDigest(
  to: string,
  poems: Array<{ title: string; author: string; snippet: string }>,
  prompt?: string
): Promise<void> {
  const poemsHtml = poems
    .map(
      (p) => `
      <div style="margin-bottom: 24px; padding: 16px; background-color: #EDF4F0; border-radius: 8px; border-left: 3px solid #1F6B5A;">
        <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; margin: 0 0 8px 0; color: #1A1C1A;">${p.title}</h3>
        <p style="font-size: 14px; color: #6B7B6E; margin: 0 0 8px 0;">by ${p.author}</p>
        <p style="font-size: 14px; font-style: italic; color: #404944; margin: 0;">"${p.snippet}..."</p>
      </div>
    `
    )
    .join('');

  const promptSection = prompt
    ? `
      <div style="margin-top: 32px; padding: 20px; background-color: #A8DACC33; border-radius: 8px; text-align: center;">
        <p style="font-size: 12px; color: #6B7B6E; margin: 0 0 8px 0; text-transform: uppercase; letter-spacing: 1px;">This week's writing prompt</p>
        <p style="font-family: 'Playfair Display', serif; font-size: 18px; font-style: italic; color: #1F6B5A; margin: 0;">"${prompt}"</p>
      </div>
    `
    : '';

  const html = wrapTemplate(`
    <h1>This week's poems are waiting for you.</h1>
    <p>The community has been busy. Here are some verses that caught our attention:</p>
    ${poemsHtml}
    ${promptSection}
    <p style="text-align: center; margin-top: 32px;">
      <a href="https://verso.app" style="display: inline-block; background-color: #1F6B5A; color: white; padding: 14px 28px; border-radius: 8px; text-decoration: none; font-weight: 500;">Open Verso</a>
    </p>
  `);

  await sendEmail(to, "This week's poems are waiting for you.", html);
  console.log(`Weekly digest sent to ${to}`);
}
