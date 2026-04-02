# Verso — Gemini CLI Project Instructions (Flutter Edition)
> Read this file at the start of every session. This is your operating manual for Verso.

---

## Who You Are Working With

You are the sole AI coding assistant for **Verso** — a solo-developer project.
Every decision must favour: managed services, minimal ops burden, zero new accounts,
and tight scope. Never suggest adding a new service when an existing one can do the job.

---

## What Verso Is

A **mobile-first social literary platform** — think Letterboxd for poetry and stories,
with the social depth of Goodreads and the emotional intelligence of a mood-based discovery engine.

- Writers compose poems, publish serialized stories, share thoughts
- Readers discover content by mood, language, and community signal
- A dedicated video feed for recorded poem recitations (TikTok-style, full-screen)
- Every UI string speaks in **poetic language** — never generic, never transactional

**Content types:** Poems · Stories (serialized, multi-part) · Thoughts (280 char) ·
Video Recitations · Audio Recitations · Collaborative Poems · Duels

**Languages:** UI is English only. Poem/story content supports **English and Bangla (Bengali script)**.
Every poem and story part stores `language: "en" | "bn"`.

**Platform:** Android only. iOS is a post-launch consideration.

---

## Tech Stack — Absolute Constraints (2026 Stable Versions)

> **Flutter SDK: 3.32.x stable channel**
>
> **PINNED** = exact version — do not change without compat check.
> **LATEST** = always install latest stable.

| Layer | Technology | Version | NEVER replace with |
|---|---|---|---|
| Mobile | **Flutter + Dart** | 3.32.x stable | React Native, Kotlin/Java native |
| Routing | **go_router** | LATEST | Navigator.push, GetX routing, auto_route |
| State | **flutter_riverpod** | **^3.3.1 PINNED** | GetX, Provider, Redux, BLoC |
| State codegen | **riverpod_annotation / riverpod_generator** | **^3.3.1 PINNED** | — |
| HTTP | **Dio + QueuedInterceptor** | **^5.9.2 PINNED** | http package, chopper |
| Token storage | **flutter_secure_storage** | LATEST | SharedPreferences, hive for tokens |
| Local cache | **hive_ce + hive_ce_flutter** | LATEST | SQLite, ObjectBox |
| Fonts | **google_fonts** | LATEST | Custom font file loading |
| Images | **cached_network_image + blurhash_dart** | LATEST | Image.network() |
| Video | **video_player** | LATEST | — |
| Audio | **just_audio** | LATEST | — |
| Real-time DMs | **socket_io_client** | **^3.1.4 PINNED** | Firestore, Pusher for DMs |
| Real-time Collab | **pusher_channels_flutter** | LATEST | socket.io for collab |
| Push tokens | **firebase_core + firebase_messaging** | **^4.3.0 / ^15.0.0 PINNED PAIR** | Expo push, OneSignal |
| Animations | **flutter_animate** | LATEST | Rive, Lottie |
| CI/CD | **GitHub Actions (ubuntu-latest)** | — | Codemagic, Bitrise |
| Auth | **Custom JWT + bcrypt** | — | Clerk, Auth0, Firebase Auth, Supabase Auth |
| OTP/Email | **Brevo** | — | SendGrid, Mailgun, Resend |
| Database | **MongoDB Atlas M0** | — | Supabase, PlanetScale, Firestore |
| Real-time DMs backend | **socket.io on Render** | **@^4 PINNED** | Firestore, Ably |
| Media | **Cloudinary** | — | S3, Firebase Storage |
| Backend | **Render (Node.js + Express)** | — | Vercel, Railway, Fly.io |
| Rate limiting | **Upstash Redis** | — | In-memory, Redis elsewhere |
| Push delivery | **FCM HTTP v1 API** (google-auth-library) | — | expo-server-sdk, OneSignal |

> ⚠️ **CRITICAL COMPATIBILITY PAIRS — never upgrade independently:**
>
> **socket.io pair:** `socket_io_client ^3.1.4` ↔ `socket.io@^4` on backend
> Protocol v4 lock — client silently fails to connect if mismatched. Pin: `npm install socket.io@^4`.
>
> **Firebase BoM pair:** `firebase_core ^4.3.0` ↔ `firebase_messaging ^15.0.0`
> Different major versions by design — do NOT try to match them.
> Verify at: pub.dev/packages/firebase_messaging → FlutterFire compatibility matrix.
>
> **Riverpod 3.x:** `StateNotifierProvider` and `StateNotifier` are removed.
> Use `@riverpod class MyNotifier extends _$MyNotifier` pattern only.

**Total monthly cost at launch: $0.00 — no credit card required anywhere.**

---

## Auth System — How It Works

Custom JWT + MongoDB + bcrypt. No Firebase Auth. No Clerk.

**Flow:**
1. `POST /api/auth/register` → bcrypt hash password → generate 6-digit OTP → store hashed OTP in MongoDB → send via Brevo
2. `POST /api/auth/verify-otp` → validate OTP → issue JWT access token (15 min) + refresh token (30 days) → store refresh token hash in MongoDB
3. `POST /api/auth/login` → compare password → issue tokens
4. `POST /api/auth/refresh` → verify refresh token → rotate pair (old deleted, new issued)
5. `POST /api/auth/logout` → delete refresh token from MongoDB
6. Forgot/reset password → same OTP flow via Brevo

**Rules:**
- Access token: 15 minutes, `JWT_ACCESS_SECRET`
- Refresh token: 30 days, `JWT_REFRESH_SECRET` (different secret)
- Refresh tokens stored as **SHA-256 hash** in `user.refreshTokens[]` array
- Max 5 refresh tokens per user (oldest pruned on overflow)
- OTP: 6 digits, bcrypt-hashed in DB, expires in 10 min, max 5 attempts before lockout
- On password reset: **revoke all refresh tokens** (invalidate all sessions)
- Flutter: access token stored in `flutter_secure_storage` (encrypted), `QueuedInterceptor` on Dio handles 401s silently
- **Never store raw tokens in the database** — always hash first

---

## Push Notifications — How They Work

**Flutter client:** `firebase_messaging` package gets the FCM device token.
`FirebaseMessaging.instance.getToken()` → send token to `PUT /api/users/me/fcm-token` → stored in `user.fcmToken` in MongoDB.

**Backend:** When a notification is triggered (like, follow, comment, etc.), the backend calls
`sendFCMPush(user.fcmToken, { title, body, data })` which uses `google-auth-library` to get an
OAuth2 token and calls the FCM HTTP v1 API directly.

**What firebase_messaging is NOT used for:**
- ❌ Firebase Auth
- ❌ Firestore
- ❌ Firebase Realtime Database
- ❌ Firebase Analytics
- ❌ Any other Firebase service

Only `firebase_core` and `firebase_messaging` are in the Flutter `pubspec.yaml`. That's it.

---

## Release Tiers — Respect the Scope

```
MVP     → Phases 0–1   Auth · Poems · Feed · Discover · Profile
V1.0    → Phases 2–5   Social · Stories · Collab · Duels · DMs · Rate Limits · Security
V2.0    → Phases 6–8   Audio/Video Polish · Dedicated Video Feed · Push Notifications · Digest · DM Production Polish
V3.0    → Phases 9–10  QA & Hardening · Play Store Launch
Future  → Phase 11     AI Writing Assistant (Anthropic Claude API)
```

**Hard rule: Do not implement V1.0 features until MVP (Phases 0–1) is live with real users.**
If asked to jump ahead, remind the developer of this rule.

---

## Design System — "Sage & Vellum"

Every screen, every widget must use these tokens. No hardcoded hex values outside `app_colors.dart`.

### Colours (Light Theme Only — Dark Mode is Post-MVP)

All defined in `lib/core/theme/app_colors.dart` as `static const Color` values.

```
Primary            #1F6B5A   Deep sage-teal
Primary Container  #A8DACC   Soft mint
On Primary         #FFFFFF
Secondary          #4A7C59   Forest sage
Secondary Container#C1E8C8   Pale sage green
Tertiary           #6B7B6E   Muted sage-grey
Tertiary Container #DDE8DE   Very pale sage
Surface            #F6FAF8   Vellum white (the page)
Surface Variant    #EDF4F0   Slightly deeper vellum
On Surface         #1A1C1A   Ink black (primary text)
On Surface Variant #404944   Faded ink (secondary text)
Background         #F6FAF8
Outline            #8FA89A   Sage outline
Outline Variant    #D8E5DC   Pale separator
Error              #B3261E
Error Container    #F9DEDC
Inverse Surface    #2A312D   Snackbar bg
Inverse On Surface #EDF4F0   Snackbar text
```

### Mood Accents (card left-border + chip text ONLY — never as fill)

```
Melancholic #6366F1  Romantic  #EC4899  Joyful    #F59E0B
Angry       #EF4444  Peaceful  #1F6B5A  Nostalgic #8B5CF6
Mysterious  #1F2937  Spiritual #D97706
```

All in `AppColors.mood(String mood)` helper.

### Typography Rules

- **Playfair Display** for: poem titles, story titles, display headlines, poem body (EN only)
  → `GoogleFonts.playfairDisplay()`
- **DM Sans** for: all UI chrome, buttons, labels, captions, metadata
  → `GoogleFonts.dmSans()`
- **System font (Noto Serif Bengali)** for: ANY Bengali script — NEVER set fontFamily
- English poem body: Playfair Display 400, 18sp, 32sp line-height, letterSpacing: 0.3
- Bengali poem body: no fontFamily, 18sp, 38sp line-height
- ⚠️ **Never set fontFamily on Bengali text. Ever. Not even to "system".**

All defined in `lib/core/theme/app_typography.dart` as `AppTypography.englishPoem` and `AppTypography.banglaPoem`.

### Type Scale

```
displayLarge:   Playfair 700 · 57sp · 64sp lh
headlineLarge:  Playfair 600 · 32sp · 40sp lh
headlineMedium: Playfair 600 · 28sp · 36sp lh
headlineSmall:  Playfair 600 · 24sp · 32sp lh
titleLarge:     DM Sans 500 · 22sp · 28sp lh
titleMedium:    DM Sans 500 · 16sp · 24sp lh
titleSmall:     DM Sans 500 · 14sp · 20sp lh   ← author name on PoemCard
bodyLarge:      DM Sans 400 · 16sp · 24sp lh
bodyMedium:     DM Sans 400 · 14sp · 20sp lh
bodySmall:      DM Sans 300 · 12sp · 16sp lh
labelLarge:     DM Sans 500 · 14sp · 20sp lh
labelMedium:    DM Sans 400 · 12sp · 16sp lh
labelSmall:     DM Sans 400 · 11sp · 16sp lh
```

### Shape Scale

```
4dp  = chips, tags, snackbars          BorderRadius.circular(4)
8dp  = inputs, text fields             BorderRadius.circular(8)
12dp = cards, list items               BorderRadius.circular(12)
16dp = bottom sheets, modals           BorderRadius.circular(16)
28dp = FAB (Write button)              BorderRadius.circular(28)
50%  = avatars, circular icon buttons  CircleBorder()
```

### Spacing Base Unit: 4dp

```
8=compact  12=card-internal  16=standard  24=section  32=large  48=screen-safe
```

### Motion Rules

- Sheet open: 350ms `Curves.easeInOutCubicEmphasized` or `Cubic(0.05, 0.7, 0.1, 1.0)`
- Sheet close: 250ms `Cubic(0.3, 0, 0.8, 0.15)`
- Like heart: `flutter_animate` `.scale()` 1.0→1.4→1.0, 300ms total
- Poem editor cursor: `AnimationController` opacity 1.0→0.3→1.0, 800ms, `repeat(reverse: true)`
- **Reduced motion:** check `MediaQuery.of(context).disableAnimations` — if true, use opacity 0→1 150ms only

### Key Widget Rules

**Bottom Nav (80dp total):**
- 5 tabs: Feed · Discover · Write★ · Notifications · Profile
- Write tab is a **56dp circular FAB** in the centre slot — not a standard NavigationBar item
- Use `Stack` + `NavigationBar` with dummy centre item, overlay FAB
- Active tab: 64×32dp pill indicator, primaryContainer bg, labelMedium primary text
- Inactive: labelMedium outline (#8FA89A)

**PoemCard:**
- `Container` with `BoxDecoration` `border: Border(left: BorderSide(color: moodColor.withValues(alpha: 0.8), width: 3))`
- `elevation: 1`, `borderRadius: 12`
- Header: `CircleAvatar(radius: 20)` + displayName titleSmall + @username bodySmall + timestamp labelSmall + `PopupMenuButton`
- Mood chip (28dp height, 4dp corner): secondaryContainer bg, mood accent text
- Language chip: tertiaryContainer bg, labelMedium
- Title: titleLarge, max 2 lines — Playfair if EN, no fontFamily override if BN
- Preview: bodyLarge, 3 lines — same font rule
- Action row: [HeartButton N] [CommentButton N] [EyeIcon N] [ShareButton] — 48dp touch targets

**Empty States:**
```
padding: EdgeInsets.fromLTRB(24, 48, 24, 0), centered
Icon/illustration: 120×120dp, outlineVariant tint
Text headline: headlineSmall Playfair
Text body: bodyMedium onSurfaceVariant, max width 280dp
FilledButton CTA (optional)
```

**Skeletons:** `flutter_animate .shimmer()` on placeholder `Container` widgets. Color: outlineVariant.

**Snackbars:** `ScaffoldMessenger.showSnackBar()`. inverseSurface bg, inverseOnSurface text, 52dp, borderRadius 4, 3000ms.

**Accessibility:**
- All tappable widgets: minimum `SizedBox(width: 48, height: 48)` or `InkWell` with `splashRadius`
- `Semantics(label: '...')` on every interactive element
- `maxFontSizeMultiplier` / `textScaler` aware poem body — use `MediaQuery.textScalerOf(context)`. **Never** use the deprecated `textScaleFactor` (removed in Flutter 3.12+)
- Bengali text: zero fontFamily — system handles it

---

## Coding Conventions

**Dart/Flutter:**
- Dart everywhere — no dynamic types, define all models with `fromJson`/`toJson`
- `riverpod_generator` for all providers — run `dart run build_runner watch`
- Riverpod for ALL async data — no `FutureBuilder` + `http`, no `setState` for server data
- `go_router` for ALL navigation — no `Navigator.push` calls
- `cached_network_image` for ALL remote images — no `Image.network()`
- `ListView.builder` for ALL dynamic lists — no `Column` + `.map()`
- `flutter_secure_storage` for tokens ONLY — never SharedPreferences for auth
- `hive_ce` for local app cache (filters, onboarding state, feed scroll position)
- `connectivity_plus` for socket reconnect on network resume
- `const` on every stateless widget and unchanging value

**Backend:**
- TypeScript everywhere — no `any` types, define all interfaces
- Zod for all API input validation
- `sanitize-html` on all user-generated text before saving to MongoDB
- `axios` is required as a runtime dep (used by `fcmPush.service.ts`) — add to npm install
- `@types/sanitize-html` required as dev dep for TypeScript to resolve sanitize-html types
- Success response shape: `{ data: ..., message: string }`
- Error response shape: `{ message: string }`
- List response shape: `{ items: [], nextCursor: string | null, hasMore: boolean }`
- Route → Controller → Service → Model. No business logic in route files.
- `requireAuth` on protected routes, `optionalAuth` on public routes
- Rate limit middleware applied at route registration level

**Poetic UI Voice — MANDATORY:**
Zero generic microcopy. All empty states, snackbars, errors, notifications use the strings in `knowledge_flutter.md`.
"Saved" is the one exception — keep that functional.

---

## Hard Rules — Never Break These

**Flutter:**
- ❌ Never use `Image.network()` — always `CachedNetworkImage`
- ❌ Never use `Column + .map()` for dynamic lists — always `ListView.builder`
- ❌ Never use `Navigator.push` — always `context.go()` or `context.push()`
- ❌ Never use GetX for anything — not routing, not state, not DI
- ❌ Never apply fontFamily to Bengali/Bangla text
- ❌ Never hardcode hex values in widgets — use `AppColors.xxx`
- ❌ Never use Firebase Auth, Firestore, or Realtime Database
- ❌ Never use `firebase_messaging` for anything except getting the FCM token
- ❌ Never use SharedPreferences for auth tokens — `flutter_secure_storage` only
- ❌ Never implement V1.0+ features before MVP is live

**Backend:**
- ❌ Never suggest Firebase, Supabase, Clerk, or any auth-as-a-service
- ❌ Never store raw JWT refresh tokens — SHA-256 hash first
- ❌ Never skip input sanitization on user text content
- ❌ Never use `lucene.english` for Atlas Search — always `lucene.standard`
- ❌ Never write generic UI copy ("No results", "Loading...", "Error")

---

## Quick File Reference

```
/verso                   Flutter app (Android)
/verso-api               Backend (Node.js + Express)

Critical Flutter files:
  lib/core/network/dio_client.dart           Dio + QueuedInterceptor + auto-refresh
  lib/core/network/socket_client.dart        Socket.io client (DMs — protocol v4)
  lib/core/network/pusher_client.dart        Pusher channels (collab/duels)
  lib/core/storage/secure_storage.dart       JWT token storage helpers
  lib/core/storage/hive_storage.dart         Local cache helpers
  lib/core/router/app_router.dart            go_router config
  lib/features/auth/providers/auth_provider.dart  Riverpod auth state
  lib/core/theme/app_colors.dart             Sage & Vellum color tokens (static const Color)
  lib/core/theme/app_typography.dart         TextTheme + poem body styles (AppTypography.englishPoem / banglaPoem)
  lib/core/theme/app_theme.dart              ThemeData builder — references app_colors + app_typography
  lib/core/theme/app_shapes.dart             AppShapes corner radius constants
  lib/core/constants/copy.dart               All poetic UI strings

Critical backend files:
  src/utils/jwt.ts                    sign/verify/hash helpers
  src/middleware/auth.middleware.ts    requireAuth / optionalAuth
  src/services/email.service.ts       Brevo OTP + emails
  src/services/fcmPush.service.ts     FCM HTTP v1 push — uses axios + google-auth-library
  src/services/notification.service.ts  createNotification + FCM dispatch
  src/controllers/auth.controller.ts  all auth endpoints
```

→ Full folder trees, all schemas, all routes, all poetic copy: `knowledge_flutter.md`
→ Phase-by-phase build steps with Dart/Flutter code: `skill_flutter.md`
→ Complete production UI/UX specification (colours, typography, animations, every screen): `design.md`
