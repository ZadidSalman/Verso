# Verso — Skill Reference (Flutter Edition)
> Phase-by-phase build procedures with concrete Dart/Flutter code patterns.
> Follow these steps to build features consistently and correctly.
> Do not start a Phase until the previous Phase checklist is fully green.

---

# PHASE 0 — Project Setup, Custom Auth & Design Foundation

**Done when:** `GET /health` returns 200. Register→OTP→Verify→Onboarding works on physical Android device.

---

## Step 0.1 — Flutter Project Init

```bash
flutter create verso --org app.verso --platforms android
cd verso
# Verify blank project runs BEFORE adding any dependencies
flutter run
```

## Step 0.2 — pubspec.yaml Dependencies

> Flutter SDK: **3.32.x stable channel**
> ⚠️ PINNED packages — do not upgrade without checking compatibility:
>   `flutter_riverpod ^3.3.1` · `dio ^5.9.2` · `socket_io_client ^3.1.4`
>   `firebase_core ^4.3.0` ↔ `firebase_messaging ^15.0.0` (FlutterFire BoM pair)

```yaml
dependencies:
  flutter:
    sdk: flutter

  go_router:                   # LATEST

  flutter_riverpod: ^3.3.1     # PINNED — Riverpod 3.x API (StateNotifierProvider removed)
  riverpod_annotation: ^3.3.1  # PINNED — must match flutter_riverpod major

  dio: ^5.9.2                  # PINNED

  flutter_secure_storage:      # LATEST
  hive_ce:                     # LATEST
  hive_ce_flutter:             # LATEST — required alongside hive_ce for Flutter platform init
  google_fonts:                # LATEST
  cached_network_image:        # LATEST
  blurhash_dart:               # LATEST — required companion for blurhash placeholders
  video_player:                # LATEST
  just_audio:                  # LATEST

  socket_io_client: ^3.1.4     # PINNED — protocol v4 lock (backend: socket.io@^4)
  pusher_channels_flutter:     # LATEST

  firebase_core: ^4.3.0        # PINNED — FlutterFire BoM 2026 (paired with messaging)
  firebase_messaging: ^15.0.0  # PINNED — FCM token ONLY, no Firestore/Auth
  flutter_local_notifications: # LATEST

  image_picker:                # LATEST
  file_picker:                 # LATEST
  flutter_animate:             # LATEST
  sentry_flutter:              # LATEST
  posthog_flutter:             # LATEST
  connectivity_plus:           # LATEST

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^3.3.1   # PINNED — must match flutter_riverpod major
  build_runner:                # LATEST
  flutter_lints:               # LATEST
  # riverpod_annotation → dependencies (runtime shipped in app)
  # riverpod_generator  → dev_dependencies (code-gen only, not shipped)
```

```bash
flutter pub get
```

## Step 0.2b — Secrets & Environment Rules

> ⚠️ READ THIS BEFORE WRITING A SINGLE LINE OF CODE THAT TOUCHES KEYS OR TOKENS.
> There are exactly two places secrets live in this project. Everything else is wrong.

### The Two-Tier Rule

| What | Where | How to access |
|---|---|---|
| API URL, Pusher key, Sentry DSN, PostHog key | `--dart-define` at build time | `String.fromEnvironment('KEY')` |
| JWT access + refresh tokens (user's session) | `flutter_secure_storage` at runtime | `SecureStorage.read()` |
| JWT signing secrets, DB URI, Cloudinary secret | Backend `.env` only — **never in Flutter** | `process.env.X` on server |

### Rule 1 — No hardcoded keys. Ever.

```dart
// ❌ WRONG — never do this
const apiUrl = 'https://api.verso.app';
const pusherKey = 'abc123xyz';

// ✅ CORRECT — always dart-define
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.verso.app');
const pusherKey = String.fromEnvironment('PUSHER_KEY');
```

### Rule 2 — No `.env` files in the Flutter project

`flutter_dotenv` reads a file bundled inside the APK. Anyone can unzip the APK and read it.
`--dart-define` values are compiled in — much harder to extract.

```
# .gitignore — must include these
.env
.env.local
*.env
```

**Running locally:**
```bash
flutter run \
  --dart-define=API_URL=http://10.0.2.2:3000 \
  --dart-define=PUSHER_KEY=your_key \
  --dart-define=PUSHER_CLUSTER=ap2 \
  --dart-define=SENTRY_DSN=your_dsn \
  --dart-define=POSTHOG_KEY=your_key
```

> Tip: Put this in a `run.sh` script and add `run.sh` to `.gitignore`.

### Rule 3 — User tokens go in flutter_secure_storage, never anywhere else

```dart
// ❌ WRONG — SharedPreferences is not encrypted
final prefs = await SharedPreferences.getInstance();
prefs.setString('token', accessToken);

// ✅ CORRECT — encrypted by OS Keychain (iOS) / EncryptedSharedPreferences (Android)
await SecureStorage.saveTokens(accessToken: token, refreshToken: refresh);
```

### Rule 4 — Backend secrets never touch Flutter

These keys **only** exist in your server's `.env` or Render environment variables.
If you find yourself typing any of these into Flutter code, stop immediately:
- `JWT_ACCESS_SECRET` / `JWT_REFRESH_SECRET`
- `MONGODB_URI`
- `CLOUDINARY_API_SECRET`
- `PUSHER_SECRET`
- `BREVO_API_KEY`

The Flutter app only ever holds the **user's JWT token** (not the signing secret).
It's the same as React — your React app never knows the `JWT_SECRET`, only the token.

### Rule 5 — CI/CD injects secrets, not you

```yaml
# GitHub Actions — secrets come from repo Settings → Secrets
flutter build appbundle --release \
  --dart-define=API_URL=${{ secrets.API_URL }} \
  --dart-define=PUSHER_KEY=${{ secrets.PUSHER_KEY }} \
  --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }} \
  --dart-define=POSTHOG_KEY=${{ secrets.POSTHOG_KEY }}
```

Never commit a build script with real values. Use `${{ secrets.X }}` always.

---

## Step 0.3 — Backend Init

```bash
mkdir verso-api && cd verso-api && npm init -y
npm install express mongoose cors helmet dotenv morgan compression
npm install jsonwebtoken bcryptjs
npm install socket.io@4 pusher   # socket.io MUST be v4.x — socket_io_client ^2.0.3+1 uses protocol v4
npm install @upstash/redis @upstash/ratelimit
npm install zod sanitize-html
npm install @getbrevo/brevo
npm install google-auth-library       # FCM HTTP v1 API
npm install axios                     # HTTP client used by fcmPush.service.ts
npm install posthog-node node-cron @sentry/node
npm install --save-dev typescript ts-node nodemon
npm install --save-dev @types/express @types/node @types/cors @types/morgan
npm install --save-dev @types/node-cron @types/jsonwebtoken @types/bcryptjs
npm install --save-dev @types/sanitize-html  # TypeScript types for sanitize-html
npm install --save-dev @types/compression    # TypeScript types for compression (required — compression does not ship its own types)
```

## Step 0.4 — JWT Utilities (backend — unchanged)

```typescript
// src/utils/jwt.ts
import jwt from "jsonwebtoken";
import crypto from "crypto";

export interface JwtPayload { sub: string; email: string; }

export const signAccessToken  = (p: JwtPayload) =>
  jwt.sign(p, process.env.JWT_ACCESS_SECRET!,  { expiresIn: "15m" });
export const signRefreshToken = (p: JwtPayload) =>
  jwt.sign(p, process.env.JWT_REFRESH_SECRET!, { expiresIn: "30d" });
export const verifyAccessToken  = (t: string) =>
  jwt.verify(t, process.env.JWT_ACCESS_SECRET!)  as JwtPayload;
export const verifyRefreshToken = (t: string) =>
  jwt.verify(t, process.env.JWT_REFRESH_SECRET!) as JwtPayload;
export const hashToken = (raw: string) =>
  crypto.createHash("sha256").update(raw).digest("hex");
export const generateOtp = () =>
  String(Math.floor(100000 + Math.random() * 900000));
export const refreshTokenExpiresAt = () => {
  const d = new Date(); d.setDate(d.getDate() + 30); return d;
};
```

## Step 0.5 — Auth Controller Logic Patterns (backend — unchanged)

**register endpoint:**
```
1. Validate: email required, password min 8 chars
2. If verified user exists → 409
3. Hash password (bcrypt 12 rounds)
4. Generate 6-digit OTP, hash it (bcrypt 10 rounds), set expiry (now + 10 min)
5. If unverified user exists: update their record. Else: create new user.
6. Send OTP email via Brevo (styled HTML with sage colours)
7. Return 200 { message: "Verification code sent to your email." }
```

**verifyOtp endpoint:**
```
1. Find user by email
2. If otpAttempts >= 5 → 429
3. If no OTP or past expiry → 400
4. bcrypt.compare(otp, user.otpCode) → if no match: increment attempts, save, 400
5. Set emailVerified=true, clear otpCode/otpExpiry/otpAttempts
6. Sign access token (15m) + refresh token (30d)
7. Push { tokenHash: hashToken(refreshToken), expiresAt, deviceInfo } to user.refreshTokens
8. Prune refreshTokens to max 5 (keep latest)
9. Save user
10. If first verification: fire sendWelcomeEmail (async, don't await)
11. Return 200 { accessToken, refreshToken, user: { _id, email, username, displayName, hasCompletedOnboarding } }
```

**login endpoint:**
```
1. Find user by email
2. If not found → 401 (same message as wrong password — prevent enumeration)
3. If !emailVerified: regenerate OTP, resend email, return 403 { code: "EMAIL_NOT_VERIFIED" }
4. comparePassword(password) → if no match → 401
5. Sign tokens, push tokenHash, prune, update lastActiveAt, save
6. Return 200 with tokens + user object
```

**refreshTokens endpoint:**
```
1. Verify refresh token signature → 401 if invalid
2. Find user by payload.sub
3. Find tokenRecord where tokenHash === hashToken(refreshToken) AND expiresAt > now → 401 if not found
4. Remove old tokenRecord from refreshTokens array
5. Sign new access + refresh tokens
6. Push new tokenHash to refreshTokens, save
7. Return 200 { accessToken, refreshToken }
```

**logout endpoint:**
```
1. Verify refresh token → get userId
2. Find user, filter out tokenHash, save
3. Return 204 (always, even if token was invalid)
```

**forgotPassword endpoint:**
```
1. Find user by email
2. ALWAYS return 200 (prevents email enumeration)
3. If user exists and is verified: generate OTP, hash, save, sendPasswordResetOtp via Brevo
```

**resetPassword endpoint:**
```
1. Validate newPassword min 8 chars
2. Find user, check OTP valid and not expired, check attempts < 5
3. Compare OTP → increment attempts on fail
4. On success: hash new password, clear OTP fields, clear ALL refreshTokens (revoke all sessions)
5. Return 200
```

## Step 0.6 — Auth Middleware (backend)

```typescript
// src/middleware/auth.middleware.ts
export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.status(401).json({ message: "Authentication required." });
  try {
    const payload = verifyAccessToken(token);
    req.user = { _id: payload.sub, email: payload.email };
    next();
  } catch {
    return res.status(401).json({ message: "Token expired or invalid. Please log in again." });
  }
}

export async function optionalAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.split(" ")[1];
  if (token) { try { const p = verifyAccessToken(token); req.user = { _id: p.sub, email: p.email }; } catch {} }
  next();
}
// Extend Express: declare global { namespace Express { interface Request { user?: { _id: string; email: string } } } }
```

## Step 0.7 — Email Service (backend — unchanged)

```typescript
// src/services/email.service.ts
// All emails: sender = { email: "hello@verso.app", name: "Verso" }
// sendOtpEmail(to, otp) — subject: "Your Verso verification code"
// sendPasswordResetOtp(to, otp) — subject: "Reset your Verso password"
// sendWelcomeEmail(to, displayName) — subject: "Your first page is blank."
// sendWeeklyDigest(to, poems[], prompt?) — subject: "This week's poems are waiting for you."
// Log all sends to emailLogs collection (brevoMessageId, status, type: "otp|welcome|digest|duel_result|password_reset")
```

## Step 0.8 — FCM Push Service (backend — replaces Expo Push)

```typescript
// src/services/fcmPush.service.ts
import { GoogleAuth } from "google-auth-library";
import axios from "axios";

const PROJECT_ID   = process.env.FIREBASE_PROJECT_ID!;
const FCM_ENDPOINT = `https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`;

async function getAccessToken(): Promise<string> {
  const auth = new GoogleAuth({
    keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_KEY_PATH,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });
  const client = await auth.getClient();
  const res = await client.getAccessToken();
  return res.token!;
}

export async function sendFCMPush(
  fcmToken: string,
  msg: { title: string; body: string; data?: Record<string, string> }
): Promise<void> {
  try {
    const token = await getAccessToken();
    await axios.post(
      FCM_ENDPOINT,
      {
        message: {
          token: fcmToken,
          notification: { title: msg.title, body: msg.body },
          data: msg.data ?? {},
          android: { priority: "high", notification: { sound: "default" } },
        },
      },
      { headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" } }
    );
  } catch { /* non-critical — silently fail */ }
}
```

**Backend endpoint to save FCM token:**
```typescript
// PUT /api/users/me/fcm-token   requireAuth
// Body: { fcmToken: string }
// User.updateOne({ _id: req.user._id }, { fcmToken: req.body.fcmToken })
// Return 204
```

## Step 0.9 — Flutter: Secure Storage Helpers

```dart
// lib/core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static Future<String?> getAccess()  async => _s.read(key: 'auth_access');
  static Future<String?> getRefresh() async => _s.read(key: 'auth_refresh');
  static Future<void> setTokens(String a, String r) async {
    await _s.write(key: 'auth_access', value: a);
    await _s.write(key: 'auth_refresh', value: r);
  }
  static Future<void> clear() async {
    await _s.delete(key: 'auth_access');
    await _s.delete(key: 'auth_refresh');
  }
}
```

## Step 0.10 — Flutter: Dio Client with QueuedInterceptor Auto-Refresh

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class DioClient {
  static final instance = _build();

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'https://api.verso.app'),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, h) async {
        final t = await SecureStorage.getAccess();
        if (t != null) opts.headers['Authorization'] = 'Bearer $t';
        h.next(opts);
      },
    ));
    dio.interceptors.add(_AutoRefreshInterceptor(dio));
    return dio;
  }
}

class _AutoRefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;
  _AutoRefreshInterceptor(this._dio);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler h) async {
    if (err.response?.statusCode != 401) return h.next(err);
    final refresh = await SecureStorage.getRefresh();
    if (refresh == null) { await SecureStorage.clear(); return h.next(err); }
    try {
      final res = await Dio().post(
        '${err.requestOptions.baseUrl}/api/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final newAccess  = res.data['accessToken']  as String;
      final newRefresh = res.data['refreshToken'] as String;
      await SecureStorage.setTokens(newAccess, newRefresh);
      final opts = err.requestOptions..headers['Authorization'] = 'Bearer $newAccess';
      h.resolve(await _dio.fetch(opts));
    } catch (_) {
      await SecureStorage.clear();
      h.next(err);
    }
  }
}
```

## Step 0.11 — Flutter: Auth Screen Design Specs

**Welcome (`/auth/welcome`):**
```
Scaffold backgroundColor: AppColors.background
Body: Column centered [
  Container 80×80 (quill-pen SVG — AppColors.primary)
  Text "Verso" — displayLarge Playfair
  Text "Where words find their world." — bodyLarge italic onSurfaceVariant
  SizedBox height: 48
  FilledButton full-width "Begin your story" → /auth/sign-up
  TextButton "Already a poet? Sign in" → /auth/sign-in
]
```

**Sign Up (`/auth/sign-up`):**
```
Card(elevation: 3, margin: 24dp, padding: 24dp, borderRadius: 16):
  TextField: email (keyboardType: email, textInputAction: next)
  TextField: password (obscureText, show/hide toggle)
  FilledButton full-width "Begin your story"
  TextButton "Already a poet? Sign in"
```

**Verify OTP (`/auth/verify-otp`):**
```
Text "Check your email" — headlineSmall Playfair
Text "We sent a 6-digit code to {email}" — bodyMedium
OtpInput widget (6 boxes, auto-submit on complete)
TextButton "Didn't get it? Resend code" — 60s countdown
TextButton "Change email" → back
```

**Sign In (`/auth/sign-in`):**
```
Text "Welcome back." — headlineSmall Playfair
Text "Your words have been waiting." — bodyMedium italic
TextField: email
TextField: password
TextButton "Forgot password?" right-aligned
FilledButton "Return to your page"
If 403 EMAIL_NOT_VERIFIED → snackbar + context.push('/auth/verify-otp', extra: email)
```

**Onboarding Username (`/auth/onboarding/username`):**
```
Text "Choose your pen name" — headlineSmall Playfair
TextField: username (lowercase, 3–20 chars)
  Suffix: real-time availability indicator (debounce 400ms)
  GET /api/users/check-username?u=
  Available: ✓ green | Taken: ✗ error | Checking: CircularProgressIndicator 16dp
FilledButton "This is my name"
```

**Onboarding Moods (`/auth/onboarding/moods`):**
```
Text "What moves you?" — headlineSmall Playfair
GridView 2×4 mood cards (156×80dp each):
  Container mood accent gradient bg
  Text mood name white Title Medium
  Emoji 28dp
  Max 3 selected — tapping 4th deselects first
FilledButton "These are my moods"
TextButton "I'll decide later"
```

**Onboarding Language (`/auth/onboarding/language`):**
```
Text "What language do you write in?" — headlineSmall Playfair
Column of 3 RadioListTiles (56dp, 12dp corner):
  "English" | "বাংলা" | "Both"
  Selected: primaryContainer bg + primary border 2dp
FilledButton "Take me to my feed"
```

## Step 0.12 — Flutter: FCM Token Registration

```dart
// Call after successful login/verifyOtp
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> registerFCMToken() async {
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  final token = await messaging.getToken();
  if (token != null) {
    await DioClient.instance.put('/api/users/me/fcm-token', data: {'fcmToken': token});
  }
  messaging.onTokenRefresh.listen((t) =>
    DioClient.instance.put('/api/users/me/fcm-token', data: {'fcmToken': t}),
  );
}
```

## Step 0.13 — Phase 0 Checklist

- [ ] `flutter run` boots on Android emulator
- [ ] Sage & Vellum colors correct throughout
- [ ] Playfair Display + DM Sans load on start
- [ ] Bengali text uses system font — no Playfair/DM Sans applied
- [ ] Backend starts, `GET /health` returns 200
- [ ] MongoDB Atlas connected, all indexes created
- [ ] Atlas Search indexes created
- [ ] `POST /api/auth/register` → OTP email arrives via Brevo
- [ ] `POST /api/auth/verify-otp` → returns JWT access + refresh tokens
- [ ] `POST /api/auth/login` → tokens for verified user
- [ ] `POST /api/auth/refresh` → rotates token pair
- [ ] `POST /api/auth/logout` → token revoked from MongoDB
- [ ] Forgot password → OTP → reset password works end-to-end
- [ ] Dio auto-refreshes on 401 (user never sees expiry)
- [ ] Tokens survive app restart (flutter_secure_storage)
- [ ] go_router redirects unauthenticated users correctly
- [ ] Register → OTP → Username → Moods → Language → Feed flow works
- [ ] OTP: 5-attempt lockout (429) enforced
- [ ] OTP: 10-minute expiry enforced
- [ ] Password reset: ALL sessions revoked
- [ ] All auth screens match Sage & Vellum spec
- [ ] FCM token saved to MongoDB after login
- [ ] No Clerk / No Firebase Auth / No Firebase Firestore anywhere

---

# PHASE 1 — Poems, Feed, Discover, Profile (MVP)

**Done when:** Users can write + publish poems, browse filtered feed, discover trending, view profile.

---

## Step 1.1 — Poem Model Pre-save Hook (backend — unchanged)

```typescript
// src/models/Poem.model.ts — pre("save") hook
PoemSchema.pre("save", function(next) {
  if (this.isNew || this.isModified("title")) {
    const base = this.title.toLowerCase()
      .replace(/[^a-z0-9\s-]/g, "").replace(/\s+/g, "-");
    this.slug = `${base}-${this._id.toString().slice(-6)}`;
  }
  this.updatedAt = new Date();
  if (this.status === "published" && !this.publishedAt) this.publishedAt = new Date();
  this.lineCount = this.content.split("\n").filter(l => l.trim()).length;
  this.wordCount  = this.content.split(/\s+/).filter(w => w).length;
  next();
});
```

## Step 1.2 — Feed Endpoint Logic (backend — unchanged)

```
GET /api/feed  Auth: requireAuth | optionalAuth
Query: ?cursor&limit=20&mood&language&type
For authenticated: 70% following + 30% trending, merged + deduplicated
For unauthenticated: pure trending
Cursor pagination on publishedAt
Populate author: { displayName, username, avatarUrl, isVerifiedPoet }
Response: { items: FeedItem[], nextCursor: string | null, hasMore: boolean }
```

## Step 1.3 — Trending Score Cron (backend — unchanged)

```typescript
// cron.schedule("0 * * * *", async () => {
//   score = (likes×3 + comments×2 + reads×0.5 + saves×4) × Math.pow(0.95, ageHours/24)
// });
```

## Step 1.4 — Keep-Alive Cron (backend — unchanged)

```typescript
// cron.schedule("*/14 * * * *", () => fetch(`${process.env.API_URL}/health`).catch(()=>{}));
```

## Step 1.5 — PoemCard Flutter Widget

```dart
// lib/shared/widgets/poem_card.dart
class PoemCard extends StatelessWidget {
  final PoemModel poem;
  const PoemCard({required this.poem, super.key});

  @override
  Widget build(BuildContext context) {
    final moodColor = AppColors.mood(poem.mood.firstOrNull ?? '');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: moodColor.withValues(alpha: 0.8), width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              UserAvatar(url: poem.author.avatarUrl, size: 40),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(poem.author.displayName, style: Theme.of(context).textTheme.titleSmall),
                Text('@${poem.author.username}', style: Theme.of(context).textTheme.bodySmall),
              ])),
              Text(_formatTimestamp(poem.publishedAt), style: Theme.of(context).textTheme.labelSmall),
              PopupMenuButton(itemBuilder: (_) => []),
            ]),
            const SizedBox(height: 8),
            // Chips
            Row(children: [
              MoodChip(mood: poem.mood.firstOrNull ?? '', color: moodColor),
              const SizedBox(width: 6),
              _LanguageChip(language: poem.language),
            ]),
            const SizedBox(height: 8),
            // Title
            Text(
              poem.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: poem.language == 'en'
                ? Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: GoogleFonts.playfairDisplay().fontFamily)
                : Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            // Preview
            Text(
              poem.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: poem.language == 'en'
                ? AppTypography.englishPoem.copyWith(fontSize: 14)
                : AppTypography.banglaPoem.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            // Action row
            const Divider(height: 1, color: AppColors.outlineVariant),
            const SizedBox(height: 8),
            Row(children: [
              _ActionButton(icon: Icons.favorite_border, count: poem.likesCount),
              const SizedBox(width: 16),
              _ActionButton(icon: Icons.chat_bubble_outline, count: poem.commentsCount),
              const SizedBox(width: 16),
              _ActionButton(icon: Icons.visibility_outlined, count: poem.readsCount),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, size: 20)),
            ]),
          ],
        ),
      ),
    );
  }
}
```

## Step 1.6 — Poem Editor Flutter Widget

```dart
// lib/features/poem/screens/poem_editor_screen.dart
// Key Flutter patterns:

// 1. Cursor pulse animation
late final AnimationController _cursorController;

@override
void initState() {
  super.initState();
  _cursorController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
    ..repeat(reverse: true);
}

// 2. Poem TextField
TextField(
  controller: _poemController,
  maxLines: null,
  expands: true,
  style: _isEnglish ? AppTypography.englishPoem : AppTypography.banglaPoem,
  cursorColor: AppColors.primary,
  cursorWidth: 2,
  decoration: InputDecoration(
    hintText: 'Begin here…',
    hintStyle: GoogleFonts.playfairDisplay(
      fontStyle: FontStyle.italic,
      color: AppColors.onSurfaceVariant,
    ),
    border: InputBorder.none,
  ),
)

// 3. Auto-save debounce
Timer? _saveTimer;
void _onContentChanged(String _) {
  _saveTimer?.cancel();
  _saveTimer = Timer(const Duration(seconds: 3), _saveDraft);
}

Future<void> _saveDraft() async {
  await ref.read(poemRepositoryProvider).saveDraft(draftId, title, content, language);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved'), duration: Duration(seconds: 2)),
    );
  }
}

// 4. EN/BN toggle
SegmentedButton<String>(
  segments: const [
    ButtonSegment(value: 'en', label: Text('EN')),
    ButtonSegment(value: 'bn', label: Text('BN')),
  ],
  selected: {_language},
  onSelectionChanged: (s) => setState(() => _language = s.first),
)
```

## Step 1.7 — Poem Reader Flutter Widget

```dart
// lib/features/poem/screens/poem_reader_screen.dart
// Key patterns:

// Read tracking: Timer fires after 5 seconds on screen
@override
void initState() {
  super.initState();
  _readTimer = Timer(const Duration(seconds: 5), _trackRead);
}

// Transparent AppBar with extended body
Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: AppColors.onSurface),
    actions: [IconButton(icon: const Icon(Icons.share_outlined), onPressed: _share)],
  ),
  body: Stack(children: [
    SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 88, 24, 80),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(poem.title, style: Theme.of(context).textTheme.headlineLarge),
        // Author row, chips, poem body...
        Text(
          poem.content,
          style: poem.language == 'en' ? AppTypography.englishPoem : AppTypography.banglaPoem,
        ),
      ]),
    ),
    // Sticky reaction bar
    Positioned(
      bottom: 0, left: 0, right: 0,
      child: _ReactionBar(poem: poem),
    ),
  ]),
)
```

## Step 1.8 — Discover + Profile Screens

**Discover:**
```dart
// CustomScrollView with:
// SliverAppBar(expandedHeight: 120, floating: true, flexibleSpace: search bar)
// SliverToBoxAdapter for each section:
//   "Trending Poems" → horizontal ListView.builder
//   "New Stories" → GridView(crossAxisCount: 2)
//   "Video Recitations" → banner GestureDetector → context.push('/video-feed')
//   "Mood Collections" → Wrap(spacing: 8) of FilterChip
//   "Writers to Follow" → horizontal ListView.builder
```

**Profile:**
```dart
// DefaultTabController(length: 4, child:
//   NestedScrollView(
//     headerSliverBuilder: (_, __) => [
//       SliverAppBar(expandedHeight: 200, flexibleSpace: cover image),
//       SliverToBoxAdapter(child: _ProfileInfo()),
//       SliverPersistentHeader(delegate: _TabBarDelegate(), pinned: true),
//     ],
//     body: TabBarView(children: [poemsTab, storiesTab, thoughtsTab, likedTab]),
//   )
// )
```

## Step 1.9 — Phase 1 Checklist

- [ ] `POST /api/poems` creates poem (draft and published)
- [ ] `GET /api/feed` returns paginated feed with mood + language filters
- [ ] Feed works for unauthenticated (trending) and authenticated (weighted)
- [ ] Poem editor sage cursor pulse (800ms AnimationController)
- [ ] Auto-save draft every 3s of inactivity, "Saved" snackbar
- [ ] EN/BN SegmentedButton sets language correctly
- [ ] Publish disabled until title + 1 line
- [ ] "Your words are now part of the world." snackbar on publish
- [ ] PoemCard: mood left border, EN Playfair, BN system font, skeleton shimmer
- [ ] Poem reader: EN Playfair 18sp/32sp, BN system 18sp/38sp
- [ ] Read count increments after 5s dwell
- [ ] Atlas Search: English queries work
- [ ] Atlas Search: Bengali queries work (lucene.standard)
- [ ] Profile: cover, avatar, stats, tabs render correctly
- [ ] All touch targets minimum 48×48dp (use SizedBox constraints)
- [ ] Bengali text NEVER has Playfair or DM Sans fontFamily applied

---

# PHASE 2 — Social Layer: Follows, Likes, Comments, Stories, Thoughts, Notifications

---

## Step 2.1 — isMutual Follow Logic (backend — unchanged)

```typescript
// POST /api/users/:id/follow
// 1. Follow.create({ followerId, followingId, isMutual: false })
// 2. Check reverse → if exists: set isMutual: true on both
// 3. Increment counts atomically
// DELETE /api/users/:id/follow
// 1. Delete document, set isMutual: false on reverse, decrement counts
```

## Step 2.2 — Optimistic Like Pattern (Flutter)

```dart
// lib/features/poem/providers/like_notifier.dart
// Riverpod 3.x — @riverpod Notifier for like state per poem
part 'like_notifier.g.dart';

@riverpod
class LikeNotifier extends _$LikeNotifier {
  @override
  ({bool isLiked, int count}) build(String poemId, bool initialLiked, int initialCount) {
    return (isLiked: initialLiked, count: initialCount);
  }

  Future<void> toggle(String poemId) async {
    final prev = state;
    // Optimistic update — NO setState, update via Riverpod state
    state = (isLiked: !state.isLiked, count: state.count + (state.isLiked ? -1 : 1));

    try {
      if (state.isLiked) {
        await ref.read(likeRepositoryProvider).like(poemId, 'poem');
      } else {
        await ref.read(likeRepositoryProvider).unlike(poemId, 'poem');
      }
    } catch (_) {
      state = prev; // rollback on failure
    }
  }
}

// In PoemCard / PoemReader — consume with ref.watch, never setState:
// final likeState = ref.watch(likeNotifierProvider(poem.id, poem.isLiked, poem.likesCount));
// ...
// GestureDetector(
//   onTap: () => ref.read(likeNotifierProvider(poem.id, ...).notifier).toggle(poem.id),
// )
```

```dart
// Heart animation with flutter_animate (fires via AnimationController in widget):
Icon(Icons.favorite, color: AppColors.primary)
  .animate(controller: _heartController)
  .scale(begin: const Offset(1, 1), end: const Offset(1.4, 1.4), duration: 150.ms)
  .then()
  .scale(begin: const Offset(1.4, 1.4), end: const Offset(1, 1), duration: 150.ms)
```

## Step 2.3 — Thought Visibility Enforcement (backend — unchanged)

```typescript
// private → author only
// mutual → isMutual follows only
// public → everyone
// NEVER return private thoughts to non-authors
```

## Step 2.4 — Story Part Publish Chain (backend — unchanged)

```typescript
// After publish: increment partsCount, update lastPartAt
// Notify all storyFollows: type "new_story_part"
// Send FCM push via sendFCMPush() (NOT Expo push)
// Create feed item contentType: "story_update"
```

## Step 2.5 — Notification Service (backend — updated for FCM)

```typescript
// src/services/notification.service.ts
import { sendFCMPush } from "./fcmPush.service";  // NOT expoPush

export async function createNotification({ recipientId, type, actorId, entityId, entityType }) {
  const poeticMessage = poeticMessages[type] ?? "";
  await Notification.create({ recipientId, type, actorId, entityId, entityType, poeticMessage, isRead: false });
  const recipient = await User.findById(recipientId).select("fcmToken");  // fcmToken not pushToken
  if (recipient?.fcmToken) {
    await sendFCMPush(recipient.fcmToken, {
      title: "Verso",
      body: poeticMessage,
      data: { type, entityId, entityType },
    });
  }
}
```

## Step 2.6 — Flutter: BottomSheet Pattern

```dart
// For CommentSheet, ThoughtComposerSheet, ContentTypePicker:
showModalBottomSheet(
  context: context,
  isScrollControlled: true,  // full height
  backgroundColor: AppColors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.5,
    maxChildSize: 0.95,
    minChildSize: 0.3,
    expand: false,
    builder: (_, controller) => ListView(
      controller: controller,
      children: [ /* sheet content */ ],
    ),
  ),
);
```

## Step 2.7 — Phase 2 Checklist

- [ ] Follow/Unfollow: isMutual maintained bidirectionally
- [ ] followersCount / followingCount atomic
- [ ] Like: polymorphic for poem, storyPart, thought
- [ ] Optimistic like update; heart animation immediate
- [ ] Comments: add + list work; CommentSheet slides up correctly
- [ ] Thought visibility enforced on ALL backend queries
- [ ] Private thoughts return 0 results to non-author
- [ ] Mutual thoughts only visible to mutual follows
- [ ] Story create + cover upload to Cloudinary works
- [ ] Story parts: partsCount + lastPartAt updated on publish
- [ ] Story followers notified via FCM push on new part
- [ ] ContentTypePicker shows "Add Story Part" only if user has active stories
- [ ] ThoughtComposer: visibility picker + char counter + post
- [ ] Notifications screen: all types with poetic messages
- [ ] FCM push notification received on physical Android device
- [ ] Notification tap → navigates to correct screen via go_router deep link
- [ ] Notifications badge on bottom nav

---

# PHASE 3 — Collab Poems, Duels, Audio/Video, Video Feed

---

## Step 3.1 — Pusher Collab Real-time (Flutter)

```dart
// lib/core/network/pusher_client.dart
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherClient {
  static final _pusher = PusherChannelsFlutter.getInstance();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await _pusher.init(
      apiKey: const String.fromEnvironment('PUSHER_KEY'),
      cluster: const String.fromEnvironment('PUSHER_CLUSTER', defaultValue: 'ap2'),
    );
    await _pusher.connect();
    _initialized = true;
  }

  static Future<void> subscribeCollab(String collabId, void Function(dynamic) onStanza) async {
    await init();
    await _pusher.subscribe(
      channelName: 'collab-$collabId',
      onEvent: (event) {
        if (event.eventName == 'stanza_added') onStanza(event.data);
      },
    );
  }

  static Future<void> unsubscribe(String collabId) async {
    await _pusher.unsubscribe(channelName: 'collab-$collabId');
  }
}
```

## Step 3.2 — Duel Lifecycle (backend — unchanged)

```
POST /api/duels             → pending, notify challengee
POST /api/duels/:id/accept  → active, endsAt = now+48h
POST /api/duels/:id/vote    → once per user
Hourly cron                 → resolve winner, notify both via FCM
```

## Step 3.3 — Video Feed Flutter Implementation

```dart
// lib/features/video/screens/video_feed_screen.dart
class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});
  @override State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _controllers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
          _preload(i);
        },
        itemBuilder: (_, i) => VideoFeedItem(
          poem: _poems[i],
          isActive: i == _currentIndex,
          controller: _getController(i),
        ),
      ),
    );
  }

  void _preload(int current) {
    // Preload next 2
    for (final i in [current + 1, current + 2]) {
      if (i < _poems.length) _getController(i);
    }
  }

  VideoPlayerController _getController(int index) {
    if (!_controllers.containsKey(index)) {
      final c = VideoPlayerController.networkUrl(Uri.parse(_poems[index].videoUrl!))
        ..initialize();
      _controllers[index] = c;
    }
    return _controllers[index]!;
  }
}

class VideoFeedItem extends StatelessWidget {
  final PoemModel poem;
  final bool isActive;
  final VideoPlayerController controller;

  const VideoFeedItem({
    required this.poem,
    required this.isActive,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // ⚠️ Side-effect (play/pause) must NOT be called directly in build().
    // Instead call controller.play() in the parent's onPageChanged callback
    // and controller.pause() when index changes away. This avoids repeated
    // play() calls on every rebuild.
    return Stack(fit: StackFit.expand, children: [
      VideoPlayer(controller),
      // Top gradient
      Positioned(top: 0, left: 0, right: 0, height: 120,
        child: Container(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent])))),
      // Bottom gradient
      Positioned(bottom: 0, left: 0, right: 0, height: 220,
        child: Container(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent])))),
      // Top bar
      SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
          const Spacer(),
          _ForYouToggle(),
        ]),
      )),
      // Right actions
      Positioned(right: 16, bottom: 120, child: _RightActions(poem: poem)),
      // Bottom info
      Positioned(left: 16, right: 80, bottom: 88, child: _BottomInfo(poem: poem)),
      // Tap to play/pause
      GestureDetector(onTap: () => controller.value.isPlaying ? controller.pause() : controller.play()),
    ]);
  }
}
```

## Step 3.4 — Audio Player Flutter Widget

```dart
// lib/shared/widgets/audio_player_card.dart
// Uses just_audio AudioPlayer()
// Surface Variant card, 12dp corner
// Row: [PlayPauseButton] [Expanded Slider (position/duration)] [time Text]

class AudioPlayerCard extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerCard({required this.audioUrl, super.key});
}

// AudioPlayer().setUrl(audioUrl) in initState
// StreamBuilder on player.positionStream + player.durationStream for slider
// play() / pause() on button tap
```

## Step 3.5 — Phase 3 Checklist

- [ ] Collab create, stanza add, approval flow work
- [ ] Pusher real-time stanza updates on physical device
- [ ] "Live" indicator shows when Pusher channel has active clients
- [ ] Duel challenge FCM notification sent to challengee
- [ ] Vote once-per-user enforced; progress bars animate
- [ ] Duel result cron resolves winner; both poets get FCM push
- [ ] Audio upload to Cloudinary; AudioPlayerCard renders in poem reader
- [ ] Video upload to Cloudinary; VideoFeedItem renders
- [ ] Video Feed: PageView vertical snap, tap pause/play
- [ ] Video Feed: preloads next 2 items
- [ ] All right actions work (like, comment, save, follow)

---

# PHASE 4 — Direct Messaging (Socket.io)

---

## Step 4.1 — Socket Client (Flutter)

```dart
// lib/core/network/socket_client.dart
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../storage/secure_storage.dart';

class SocketClient {
  static io.Socket? _socket;

  static Future<io.Socket> connect() async {
    final token = await SecureStorage.getAccess();
    _socket = io.io(
      const String.fromEnvironment('API_URL'),
      io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .build(),
    );
    _socket!.connect();
    return _socket!;
  }

  static void disconnect() => _socket?.disconnect();
  static io.Socket? get instance => _socket;
}
```

## Step 4.2 — Message Thread Pattern (Flutter)

```dart
// lib/features/messages/providers/messages_provider.dart
// Riverpod 3.x — family @riverpod Notifier keyed by conversationId
part 'messages_provider.g.dart';

@riverpod
class Messages extends _$Messages {
  @override
  List<MessageModel> build(String conversationId) => [];

  void addMessage(dynamic data) {
    state = [MessageModel.fromJson(data as Map<String, dynamic>), ...state];
  }

  void prependHistory(List<MessageModel> older) {
    state = [...state, ...older];   // state is reversed (newest first)
  }
}
// Usage: ref.read(messagesProvider(conversationId).notifier).addMessage(data)
```

```dart
// In MessageThreadScreen initState:
final socket = await SocketClient.connect();
socket.emit('join_conversation', conversationId);
socket.on('new_message', (data) {
  ref.read(messagesProvider(conversationId).notifier).addMessage(data);
});
socket.on('user_typing', (_) {
  setState(() => _isTyping = true);
  _typingTimer?.cancel();
  _typingTimer = Timer(const Duration(seconds: 3), () => setState(() => _isTyping = false));
});

// On send:
void _sendMessage() {
  final content = _controller.text.trim();
  if (content.isEmpty) return;
  socket.emit('send_message', {'conversationId': conversationId, 'content': content, 'type': 'text'});
  _controller.clear();
}

// On dispose:
socket.emit('mark_read', conversationId);
socket.off('new_message');
socket.off('user_typing');
```

## Step 4.3 — Message Bubble Styles (Flutter)

```dart
// Own message
Container(
  margin: const EdgeInsets.only(left: 48, right: 16, bottom: 4),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16), topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4),
    ),
  ),
  child: Text(message.content, style: const TextStyle(color: AppColors.onPrimary)),
)

// Other message
Container(
  margin: const EdgeInsets.only(left: 16, right: 48, bottom: 4),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(4), topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16),
    ),
  ),
  child: Text(message.content, style: const TextStyle(color: AppColors.onSurface)),
)
```

## Step 4.4 — Phase 4 Checklist

- [ ] Conversations list sorted by lastMessageAt
- [ ] First message creates conversation (finds-or-creates)
- [ ] Messages real-time via Socket.io (sent + received)
- [ ] Typing indicator appears within 1 second
- [ ] Unread count badge on conversation list items
- [ ] Marking conversation read clears unread count
- [ ] Message history paginates (scroll up loads older)
- [ ] Socket reconnects automatically on network resume
- [ ] Poem share cards render and navigate correctly

---

# PHASE 5 — Rate Limiting, Security & Performance

---

## Step 5.1 — Rate Limit Middleware (backend)

```typescript
// src/middleware/rateLimit.middleware.ts
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

const redis = new Redis({ url: process.env.UPSTASH_REDIS_REST_URL!, token: process.env.UPSTASH_REDIS_REST_TOKEN! });

const limiters = {
  auth:       new Ratelimit({ redis, limiter: Ratelimit.slidingWindow(10,  "15 m") }),
  poems:      new Ratelimit({ redis, limiter: Ratelimit.slidingWindow(10,  "24 h") }),
  thoughts:   new Ratelimit({ redis, limiter: Ratelimit.slidingWindow(20,  "24 h") }),
  storyParts: new Ratelimit({ redis, limiter: Ratelimit.slidingWindow(5,   "24 h") }),
  comments:   new Ratelimit({ redis, limiter: Ratelimit.slidingWindow(50,  "1 h") }),
  general:    new Ratelimit({ redis, limiter: Ratelimit.slidingWindow(200, "1 m") }),
};

const messages = {
  auth:       "Too many attempts. Rest for a moment.",
  poems:      "The words are coming too fast. Rest for a moment, then try again.",
  thoughts:   "Your thoughts need space between them. Try again soon.",
  storyParts: "A story unfolds slowly. Rest before the next chapter.",
  comments:   "Your voice needs a breath. Try again soon.",
  general:    "Easy. Even poems need space between lines.",
};

export function rateLimit(type: keyof typeof limiters) {
  return async (req, res, next) => {
    const key = req.user?._id ?? req.ip ?? "anon";  // _id from auth middleware (set from payload.sub)
    const { success, remaining } = await limiters[type].limit(key);
    if (!success) return res.status(429).json({ message: messages[type] });
    res.setHeader("X-RateLimit-Remaining", remaining);
    next();
  };
}
```

## Step 5.2 — Input Sanitization (backend — unchanged)

```typescript
import sanitizeHtml from "sanitize-html";
export const sanitize = (text: string) =>
  sanitizeHtml(text, { allowedTags: [], allowedAttributes: {} });
// Apply to: poem.content, storyPart.content, thought.content, comment.content, user.bio
```

## Step 5.3 — Security Setup (backend — unchanged)

```typescript
import compression from "compression"; // Use ES import — never require() in TypeScript files
// Trust proxy MUST be set before rate limiting for correct IP detection behind Cloudflare
app.set("trust proxy", 1);
app.use(compression());
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({
  origin: ["https://verso.app"],
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"], // Required — without this CORS preflight blocks all JWT-protected routes
}));
```

## Step 5.4 — Flutter Performance Rules

```
ListView.builder: ALWAYS for long lists — never Column + .map() for dynamic content
cached_network_image: ALWAYS for remote images — never Image.network()
  CachedNetworkImage(imageUrl: url, placeholder: (_, __) => BlurHashWidget(hash: blurhash))
const constructors: on ALL stateless widgets that don't depend on runtime data
RepaintBoundary: wrap VideoFeedItem and animated PoemCard like buttons
Riverpod scoped providers: avoid rebuilding entire tree on state change
  Use select() to only rebuild when specific field changes:
  ref.watch(poemProvider(id).select((p) => p.likesCount))
```

## Step 5.5 — Phase 5 Checklist

- [ ] Auth: 10 attempts / 15min / IP enforced
- [ ] Poems: 10/day/user; 11th returns poetic 429
- [ ] Thoughts: 20/day/user
- [ ] Story parts: 5/day/user
- [ ] All 429 responses use poetic messages
- [ ] All user text sanitized before MongoDB save
- [ ] Security headers set
- [ ] CORS locked to production domain
- [ ] Feed < 2s on simulated 4G throttle
- [ ] No layout shift (blurhash on all images)
- [ ] Cloudflare caching confirmed on feed routes
- [ ] ListView.builder used on all long lists (no Column + .map())
- [ ] const constructors used throughout

---

# PHASE 6 — Audio/Video Polish & Dedicated Video Feed

**V2.0 tier · Do not start until V1.0 (Phases 4–5) is live with real users.**

---

## Step 6.1 — Audio Upload & Inline Player (backend + Flutter)

```typescript
// Backend: POST /api/poems/:id/audio   requireAuth
// 1. Receive multipart/form-data — audio file (MP3/AAC, max 50MB)
// 2. Upload to Cloudinary:  folder: "recitations/", resource_type: "video"
//    (Cloudinary uses resource_type "video" for audio too)
// 3. Update poem.audioUrl
// 4. Return { audioUrl }
```

```dart
// Flutter: AudioPlayerCard embedded in PoemReaderScreen
// Appears below poem body when poem.audioUrl != null
// just_audio AudioPlayer — setUrl(audioUrl) in initState
// UI: SurfaceVariant card 12dp radius, Row: [PlayPauseButton] [Slider] [timeText]
// StreamBuilder on player.positionStream + player.durationStream
```

## Step 6.2 — Video Upload & Video Feed Polishing

```typescript
// Backend: POST /api/poems/:id/video   requireAuth
// 1. Receive multipart/form-data — video file (MP4, max 200MB)
// 2. Upload to Cloudinary: folder: "videos/", resource_type: "video"
//    eager: [{ format: "mp4", quality: "auto" }]   (Cloudinary auto-optimise)
// 3. Update poem.videoUrl
// 4. Return { videoUrl }
```

```dart
// Flutter: VideoFeedScreen (already scaffolded in Phase 3)
// Polishing checklist:
// - Add "For You" / "Following" toggle with separate feed providers
// - RepaintBoundary wrapping each VideoFeedItem
// - Pause all controllers when app goes to background (AppLifecycleListener)
// - Dispose controllers not within ±2 of current index to save memory
// - CachedNetworkImage for video thumbnail shown while VideoPlayer initialises
```

## Step 6.3 — Phase 6 Checklist

- [ ] Audio upload (MP3/AAC) to Cloudinary works end-to-end
- [ ] AudioPlayerCard plays, pauses, scrubs correctly in poem reader
- [ ] Audio player does not crash on fast screen transitions (dispose guard)
- [ ] Video upload (MP4) to Cloudinary works; Cloudinary auto-optimises
- [ ] Video Feed "For You" tab shows trending video poems
- [ ] Video Feed "Following" tab shows video poems from followed poets
- [ ] Video player memory: controllers ±2 of current page retained, rest disposed
- [ ] Video pauses when app goes to background
- [ ] RepaintBoundary on VideoFeedItem — no jank during PageView scroll
- [ ] Right-column actions (like, save, follow) work inside video feed

---

# PHASE 7 — Push Notifications & Weekly Digest

**V2.0 tier · Build after Phase 6.**

---

## Step 7.1 — Notification Centre (Flutter)

```dart
// lib/features/notifications/screens/notifications_screen.dart
// Already receives FCM pushes since Phase 2, but this phase adds:
// - Pull-to-refresh on NotificationsScreen
// - Mark all read: PUT /api/notifications/read-all → zero badge
// - Tap routing: switch(notification.entityType) → context.go('/poem/:id') etc.
// - Group unread notifications visually (dot indicator on each unread item)
// - flutter_local_notifications: show heads-up banner when app is foreground
//   FirebaseMessaging.onMessage.listen → FlutterLocalNotificationsPlugin.show()
```

```dart
// lib/core/notifications/fcm_handler.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

// Global navigator key — pass this to GoRouter(navigatorKey:) and MaterialApp.router
// This lets FCMHandler navigate without needing a BuildContext or Ref
final navigatorKey = GlobalKey<NavigatorState>();

// Background handler — must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI — just log or update badge count via Hive local storage
}

class FCMHandler {
  static final _localNotif = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // flutter_local_notifications v18: must call initialize() before show()
    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (details) {
        // Tap on local notification while app is open
        final ctx = navigatorKey.currentState?.context;
        if (ctx != null) _navigateFromPayload(ctx);
      },
    );

    // Create notification channel (Android 8+)
    const channel = AndroidNotificationChannel(
      'verso_default',
      'Verso',
      importance: Importance.high,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground banner
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n == null) return;
      _localNotif.show(
        n.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id, channel.name,
            importance: channel.importance,
            priority: Priority.high,
          ),
        ),
        payload: msg.data['entityId'],
      );
    });

    // Tap on notification when app is terminated or in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }

  static void _handleTap(RemoteMessage msg) {
    final entityId   = msg.data['entityId'] as String?;
    final entityType = msg.data['entityType'] as String?;
    if (entityId == null) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    switch (entityType) {
      case 'poem':    ctx.go('/poem/$entityId');
      case 'story':   ctx.go('/story/$entityId');
      case 'duel':    ctx.go('/duel/$entityId');
      case 'collab':  ctx.go('/collab/$entityId');
      default:        ctx.go('/notifications');
    }
  }

  static void _navigateFromPayload(BuildContext ctx) {
    // Called when user taps a local notification while app is open
    ctx.go('/notifications');
  }
}

// In app_router.dart — pass navigatorKey to GoRouter:
// @Riverpod(keepAlive: true)
// GoRouter router(Ref ref) => GoRouter(
//   navigatorKey: navigatorKey,   ← add this line
//   ...
// );
```

## Step 7.2 — Email Digest & Prompt Rotation (backend)

```typescript
// cron.schedule("0 9 * * 1", async () => {  // Monday 9AM UTC
//   Batch 100 users at a time (Brevo 300/day free limit)
//   For each user: find top 5 trending poems from their following (last 7 days)
//   sendWeeklyDigest(user.email, poems, activePrompt)

// cron.schedule("0 8 * * 0", async () => {  // Sunday 8AM UTC
//   Deactivate current prompt, activate next in sequence
//   Send FCM push to users where emailPreferences.promptAlerts === true
//   via sendFCMPush(user.fcmToken, { title: "New prompt", body: prompt.title })
```

## Step 7.3 — Phase 7 Checklist

- [ ] FCM foreground banner shows via flutter_local_notifications
- [ ] Tap on notification (background/terminated) deep-links to correct screen
- [ ] Notification badge count resets to zero on read-all
- [ ] Pull-to-refresh on notifications screen works
- [ ] Weekly digest cron runs Monday 9AM UTC
- [ ] Digest email renders correctly in Gmail on Android
- [ ] Prompt rotation activates new prompt each Sunday
- [ ] Prompt FCM push delivered to Android device
- [ ] Brevo sender domain SPF + DKIM verified
- [ ] Email logs stored in emailLogs collection (all types)

---

# PHASE 8 — Direct Messaging — Production Polish

**V2.0 tier · Build after Phase 7.**

> Phase 4 scaffolded the Socket.io DM screens. This phase completes them for production:
> reconnection on network loss, message pagination, and read-receipt reliability.

---

## Step 8.1 — Socket Reconnect on Network Resume

```dart
// In SocketClient — handle network interruptions
import 'package:connectivity_plus/connectivity_plus.dart';

// connectivity_plus is already in pubspec.yaml (Step 0.2) — no need to add it again
// Listen to connectivity changes and reconnect socket
Connectivity().onConnectivityChanged.listen((results) {
  if (results.any((r) => r != ConnectivityResult.none)) {
    SocketClient.connect();   // idempotent — checks if already connected
  }
});
```

## Step 8.2 — Message Pagination (Flutter)

```dart
// MessageThreadScreen — load older messages on scroll to top
NotificationListener<ScrollNotification>(
  onNotification: (n) {
    if (n is ScrollStartNotification &&
        n.metrics.pixels <= 100 &&
        !_loadingMore) {
      _loadMore();
    }
    return false;
  },
  child: ListView.builder(
    reverse: true,       // newest at bottom
    controller: _scroll,
    itemCount: messages.length,
    itemBuilder: (_, i) => MessageBubble(message: messages[i]),
  ),
)
```

## Step 8.3 — Phase 8 Checklist

- [ ] Conversations list sorted by lastMessageAt (newest first)
- [ ] First message between two users creates conversation (find-or-create)
- [ ] Messages appear in real time via Socket.io on both devices
- [ ] Typing indicator appears and auto-dismisses after 3 s
- [ ] Unread count badge shown on conversation list items
- [ ] Marking conversation read clears badge (socket + REST)
- [ ] Message history paginates on scroll to top (older messages load)
- [ ] Socket auto-reconnects after network interruption
- [ ] Poem share cards in DMs navigate to /poem/:id on tap
- [ ] Socket disconnects when app goes to background, reconnects on resume

---

# PHASE 9 — QA, Performance & Pre-Launch Hardening

**V3.0 tier · Run after all V2.0 features are stable.**

---

## Step 9.1 — Performance Targets

```
Feed cold start:       < 2 s on simulated 4G throttle (Chrome DevTools equivalent)
Feed scroll:           ≥ 60 fps — ListView.builder + RepaintBoundary on PoemCard
Image load:            blurhash placeholder shown < 100ms; full image < 1.5 s
Video feed page turn:  < 300 ms to first frame (preload ±2 pages)
API p95 latency:       < 400 ms on /api/feed and /api/poems
No layout shift:       blurhash on EVERY remote image — zero CLS
```

## Step 9.2 — Security Audit

**Flutter / Client secrets:**
```
- [ ] Zero hardcoded API URLs, keys, or DSNs in Dart source — grep confirms
- [ ] All build-time config uses String.fromEnvironment() — never flutter_dotenv or hardcoded strings
- [ ] No .env file present in Flutter project root (flutter_dotenv not used)
- [ ] run.sh (local dart-define script) is in .gitignore — confirmed via git log
- [ ] JWT tokens stored only in flutter_secure_storage — no SharedPreferences, no Hive
- [ ] flutter_secure_storage AndroidOptions(encryptedSharedPreferences: true) set
- [ ] SecureStorage.deleteAll() called on logout — confirmed
- [ ] No backend secrets (JWT_SECRET, DB URI, Cloudinary secret) appear anywhere in Flutter code
```

**Backend secrets:**
```
- [ ] All JWT secrets are 64-byte hex strings (not "secret" or "changeme")
- [ ] No .env files committed to Git — confirmed via git log
- [ ] All backend env vars set in Render production environment (not .env in repo)
- [ ] CORS locked to https://verso.app only
- [ ] All user text sanitized via sanitize-html before MongoDB save
- [ ] No raw refresh tokens in database — SHA-256 hash only
- [ ] No passwordHash / otpCode / refreshTokens fields in any API response
- [ ] Rate limits tested: auth, poems, thoughts, storyParts all enforce correctly
- [ ] OTP lockout after 5 failed attempts enforced
- [ ] Password reset revokes ALL active sessions
- [ ] Sentry error alerts configured and receiving test events
```

## Step 9.3 — Accessibility & Internationalisation QA

```
- [ ] All touch targets ≥ 48×48 dp (SizedBox constraints everywhere)
- [ ] Every interactive element has Semantics(label: ...) wrapper
- [ ] Bengali text renders correctly on physical Android device (system font)
- [ ] Bengali text has ZERO Playfair/DM Sans fontFamily applied — grep confirms
- [ ] Poem body line-height correct: EN 32sp, BN 38sp
- [ ] Large text scale (2×) does not break layouts
- [ ] Reduced motion: MediaQuery.of(context).disableAnimations respected
```

## Step 9.4 — Phase 9 Checklist

- [ ] All performance targets met on mid-range Android (e.g. Pixel 4a)
- [ ] Memory: no leak after 30 minutes of scrolling video feed
- [ ] All security items above green
- [ ] All accessibility items above green
- [ ] Sentry receiving events from production backend and Flutter app
- [ ] PostHog recording events correctly
- [ ] Full regression: Register → OTP → Onboarding → Poem → Feed → Like → Comment → Follow → DM
- [ ] Full regression: Story create → Story Part → Notifications → Video Feed
- [ ] Zero console errors on Flutter release build
- [ ] `flutter analyze` returns zero issues

---

# PHASE 10 — Play Store Launch

---

## Step 10.1 — GitHub Actions Release Build

```yaml
# .github/workflows/build-android.yml
name: Build Android Release

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v3
        with:
          channel: 'stable'   # Do not pin flutter-version — always builds on latest stable.
          cache: true         # Cache Flutter SDK between runs for faster CI.
      - run: flutter pub get
      - run: |
          flutter build appbundle --release \
            --dart-define=API_URL=${{ secrets.API_URL }} \
            --dart-define=PUSHER_KEY=${{ secrets.PUSHER_KEY }} \
            --dart-define=PUSHER_CLUSTER=ap2 \
            --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }} \
            --dart-define=POSTHOG_KEY=${{ secrets.POSTHOG_KEY }}
      - uses: actions/upload-artifact@v4
        with:
          name: release-aab
          path: build/app/outputs/bundle/release/app-release.aab
```

> Use `appbundle` (AAB) for Play Store submission. Use `apk` only for side-loading test builds.

## Step 10.2 — Play Store Submission Checklist

- [ ] All backend `.env` vars set in Render production environment
- [ ] JWT secrets are 64-byte hex (not placeholders)
- [ ] MongoDB Atlas indexes all verified active
- [ ] Atlas Search indexes verified with Bengali + English test queries
- [ ] Cloudinary folders active: poems/, recitations/, videos/, stories/
- [ ] Upstash Redis production instance active
- [ ] Brevo: sender domain SPF + DKIM verified
- [ ] Cloudflare proxy active with caching rules on /api/feed
- [ ] Keep-alive cron confirmed (no Render cold sleep)
- [ ] Sentry + PostHog connected and receiving production events
- [ ] App icon (512×512 PNG) and feature graphic (1024×500 PNG) ready
- [ ] Splash screen (SplashScreen API, no flutter_native_splash flicker)
- [ ] App signing keystore stored securely (NOT in Git)
- [ ] Deep links verified: /poem/:id, /story/:id, /user/:username
- [ ] FCM push notifications on physical Android device (production FCM)
- [ ] Bengali text renders on physical Android device (non-Google ROM)
- [ ] OTP email tested end-to-end with Gmail on Android
- [ ] Full user flow: Register → OTP → Onboarding → Publish poem → Feed
- [ ] Rate limit smoke test: 11th poem publish → poetic 429 response
- [ ] GitHub Actions AAB build passes on main push
- [ ] AAB uploaded to Play Console internal test track and tested
- [ ] ZERO Firebase Auth / Firestore / Realtime Database references in codebase
- [ ] ZERO Supabase / Clerk references in codebase
- [ ] firebase_messaging used ONLY for FCM token — confirmed via grep
- [ ] All crons running: trending (hourly), digest (Monday 9AM), prompt (Sunday 8AM), keep-alive (every 14 min)
- [ ] `GET /health` returns 200 from production URL
- [ ] Socket.io DMs tested on two physical Android devices simultaneously
- [ ] Privacy policy URL added to Play Console listing
- [ ] Content rating questionnaire completed in Play Console

---

# PHASE 11 — AI Writing Assistant (Future — Post-V1.0)

**Do not build until V1.0 ships and users request writing help.**

```
Backend:
1. npm install @anthropic-ai/sdk
2. Create src/services/aiWriting.service.ts
3. POST /api/ai/suggest-line       — last 2 lines → Claude → next line suggestion
4. POST /api/ai/suggest-title      — poem content → 3 title options
5. POST /api/ai/suggest-direction  — story so far → next chapter direction
6. Rate limit: 5 AI calls per poem/day/user via Upstash
7. PostHog feature flag: "ai-writing-assist" — roll out gradually

Flutter UI additions:
1. IconButton "✦" in poem editor toolbar (hidden behind PostHog feature flag)
2. On tap: call /api/ai/suggest-line with last 2 lines of poem
3. Show suggestion as greyed italic Text below cursor
4. Tap suggestion → insert into TextEditingController at cursor position
5. Swipe suggestion left → dismiss, request another
```

Features in rollout order:
1. Suggest next line (last 2 lines → Claude → ghost text in editor)
2. Mood check (analyse poem → suggest mood tags)
3. Title suggestion (3 options from poem content)
4. Style coach (compare to sonnet/haiku form requirements)
5. EN↔BN translation assistance
6. Story continuation suggestion
7. Thought → full poem expansion
