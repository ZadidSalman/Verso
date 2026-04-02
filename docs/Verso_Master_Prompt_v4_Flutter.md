# Verso — Master Development Prompt v4
### Flutter · Android-Only · Custom JWT Auth · MongoDB-Only · No Clerk · No Firebase Auth · No Supabase

> **How to use this document:** This is the single source of truth for building Verso from scratch.
> Feed it phase by phase to your AI coding assistant. Every phase integrates both backend steps AND
> UI/UX implementation specs so you never need to cross-reference two documents.
> Features marked `[POST-MVP]` must not be started until MVP (Phases 0–3) is live with real users.

---

## Platform Identity

**Verso** is a mobile-first social literary platform — think Letterboxd for poetry and stories,
with the social depth of Goodreads and the emotional intelligence of a mood-based discovery engine.
Writers compose poems, publish serialized stories, and share thoughts; readers discover all content
types by mood, language, and community signal. A dedicated video feed lets poets share recorded
recitations in a full-screen vertical scroll experience. Every UI string, empty state, and notification
speaks in poetic language — never generic, never transactional.

**Content types:**
- **Poems** — the core. Composed in the editor, published individually.
- **Stories** — serialized multi-part narratives with optional collaboration.
- **Thoughts** — short public/private/mutual one-liners (max 280 chars).
- **Video Recitations** — poems with an attached video. Full-screen TikTok-style feed.
- **Audio Recitations** — poems with attached audio. Playable inline.
- **Collaborative Poems** — multi-author stanza chains (linear or branching).
- **Duels** — head-to-head challenge poems voted on by the community.

**Languages:** App UI is English only. Poem and story content supports both English and Bangla.
Every poem and story part stores a `language: "en" | "bn"` field.

**Platform:** Android only. iOS is post-launch.

**Solo developer project.** Every decision prioritizes managed services, minimal ops burden, and
tight MVP scope. Ship in tiers. Each tier is a complete usable product before the next begins.

---

## Release Tier Map

```
MVP     → Phases 0–1   Auth · Write poems · Combined feed with filters · Discover · Profile
V1.0    → Phases 2–5   Social · Stories · Collab · Duels · DMs · Rate Limits · Security
V2.0    → Phases 6–8   Audio/Video Polish · Dedicated Video Feed · Push Notifications & Digest · DM Production Polish
V3.0    → Phases 9–10  QA & Hardening · Play Store Launch
Future  → Phase 11     AI Writing Assistant
```

**Rule:** Do not start Phase 2 until Phases 0–1 are deployed and tested by real users.

---

## Final Tech Stack (Flutter · Android · MongoDB-Only · Custom JWT Auth)

| Layer | Technology | Version | Purpose | Free |
|---|---|---|---|---|
| **Mobile** | **Flutter + Dart** | **3.32.x stable** | **Android app** | **Open Source** |
| Routing | go_router | latest stable | Declarative routing, deep links, bottom tabs | Open Source |
| State | flutter_riverpod + riverpod_generator | **^3.3.1** ⚠️ PINNED | Global + server state, caching | Open Source |
| HTTP | Dio + QueuedInterceptor | **^5.9.2** ⚠️ PINNED | API calls, JWT auto-refresh | Open Source |
| Token Storage | flutter_secure_storage | latest stable | Encrypted JWT token storage | Open Source |
| Local Cache | hive_ce + hive_ce_flutter | latest stable | Feed filters, onboarding state, drafts cache | Open Source |
| Fonts | google_fonts | latest stable | Playfair Display + DM Sans | Open Source |
| Images | cached_network_image + blurhash_dart | latest stable | Remote images with placeholder | Open Source |
| Video | video_player | latest stable | Full-screen video feed | Open Source |
| Audio | just_audio | latest stable | Inline audio player | Open Source |
| Real-time DMs | socket_io_client | **^3.1.4** ⚠️ PINNED | Direct messages — protocol v4 lock | Open Source |
| Real-time Collab | pusher_channels_flutter | latest stable | Stanza live updates, duels | Open Source |
| Push tokens | firebase_core + firebase_messaging | **^4.3.0 / ^15.0.0** ⚠️ PINNED PAIR | FCM token only — no Firestore/Auth | Free |
| Local notifications | flutter_local_notifications | latest stable | Display push notifications | Open Source |
| Image picker | image_picker | latest stable | Profile photos, cover images | Open Source |
| File picker | file_picker | latest stable | Audio/video upload selection | Open Source |
| Animations | flutter_animate | latest stable | Micro-animations, transitions | Open Source |
| Error monitoring | sentry_flutter | latest stable | Crash reports (Flutter) | 5k errors/mo free |
| Analytics (Flutter) | posthog_flutter | latest stable | Events + feature flags (client) | Open Source |
| Network | connectivity_plus | latest stable | Socket auto-reconnect on network resume | Open Source |
| Poetry editor | Custom TextField + AnimationController | built-in | Sage cursor pulse, toolbar | Built-in |
| **Auth** | **Custom JWT + bcrypt** | — | **Sign-up, sign-in, token refresh** | **Free** |
| **OTP** | **Brevo Transactional Email** | — | **Email verification, password reset** | **300/day free** |
| Database | MongoDB Atlas M0 | — | All app data incl. auth | 512MB–5GB free |
| Search | Atlas Search (lucene.standard) | — | Full-text EN + Bangla | Included |
| Real-time Messaging | Socket.io on Render | **socket.io@^4** ⚠️ PINNED | DMs — must match socket_io_client protocol | Free |
| Push Delivery | FCM HTTP v1 API (via google-auth-library) | — | Push notification delivery | Free |
| Media | Cloudinary | — | Photos, audio, video | 25GB free |
| Backend | Render (Node.js + Express) | — | API server | Free |
| Email | Brevo | — | Transactional email + weekly digest | 300/day free |
| Rate Limiting | Upstash Redis | — | Persistent rate limits | 500k cmds/mo free |
| Analytics (Backend) | PostHog | — | Server-side events + feature flags | 1M events/mo free |
| Error monitoring (Backend) | Sentry | — | Server crash reports | 5k errors/mo free |
| CDN | Cloudflare | — | CDN + DDoS + caching | Free |
| CI/CD | GitHub Actions (Linux runner) | — | Android APK/AAB builds | 2000 min/mo free |

> ⚠️ **PINNED version rules (2026):**
> - `flutter_riverpod ^3.3.1` — Riverpod 3.x removes `StateNotifierProvider`. Use `@riverpod` annotations only.
> - `dio ^5.9.2` — latest stable; actively maintained.
> - `socket_io_client ^3.1.4` ↔ `socket.io@^4` on backend — protocol v4 pair. Never upgrade one without the other.
> - `firebase_core ^4.3.0` ↔ `firebase_messaging ^15.0.0` — FlutterFire BoM pair. Verify at pub.dev/packages/firebase_messaging before any upgrade.

**Total monthly cost at launch: $0.00 — no credit card required anywhere.**

**Flutter rationale (replacing React Native + Expo):**
- Flutter gives full control over rendering — no NativeWind, no bridge overhead.
- Dart is strongly typed natively — no TypeScript config needed.
- Riverpod replaces Zustand + TanStack Query in one package.
- flutter_secure_storage replaces MMKV for token storage (encrypted by default).
- hive_ce replaces AsyncStorage for fast local key-value cache.
- Pusher and Socket.io have official Flutter/Dart SDKs — zero logic change.
- firebase_messaging used ONLY for FCM token — no Firebase database, auth, or hosting.
- GitHub Actions on Linux handles Android builds entirely free.

**Auth rationale (unchanged from v3):**
- Custom JWT auth removes the 50,000 MAU ceiling and any external auth dependency.
- All user data, tokens, and OTP codes live in MongoDB — same database, same connection.
- Brevo already exists in the stack for emails; OTP is just one more transactional template.
- bcrypt for password hashing. JWT access tokens (15 min) + refresh tokens (30 days) in MongoDB.

---

## Design System — "Sage & Vellum"

> This section is the canonical design reference. Every phase implementation must follow these specs.
> In Flutter: colours in `lib/core/theme/app_colors.dart`, text styles in `lib/core/theme/app_typography.dart`, ThemeData builder in `lib/core/theme/app_theme.dart`. Never hardcode hex in widgets.

### Colour Palette

```
Primary            #1F6B5A   Deep sage-teal — primary actions, active states, links
Primary Container  #A8DACC   Soft mint — chips, selected state backgrounds
On Primary         #FFFFFF
On Primary Cont.   #00201A

Secondary          #4A7C59   Forest sage — secondary actions, highlights
Secondary Container#C1E8C8   Pale sage green — tag backgrounds, highlight chips
On Secondary       #FFFFFF
On Secondary Cont. #0B2112

Tertiary           #6B7B6E   Muted sage-grey — timestamps, metadata
Tertiary Container #DDE8DE   Very pale sage — subtle dividers, disabled
On Tertiary        #FFFFFF
On Tertiary Cont.  #1A2B1D

Surface            #F6FAF8   Vellum white — cards, sheets, nav bar
Surface Variant    #EDF4F0   Soft sage white — secondary cards
On Surface         #1A1C1A   Primary text
On Surface Variant #404944   Secondary text, captions

Background         #F6FAF8
Outline            #8FA89A   Borders, inactive nav icons
Outline Variant    #D8E5DC   Skeleton loaders, subtle separators

Error              #B3261E
Error Container    #F9DEDC
Inverse Surface    #2A312D   Toast background
Inverse On Surface #EDF4F0   Toast text
```

### Mood Accent Palette

Each mood maps to a card left-border accent (3dp, 80% opacity) and chip text. Never as fill.

```
Melancholic  #6366F1   Romantic    #EC4899   Joyful      #F59E0B
Angry        #EF4444   Peaceful    #1F6B5A   Nostalgic   #8B5CF6
Mysterious   #1F2937   Spiritual   #D97706
```

### Typography

```
Display/Poem titles:  Playfair Display 400/700   → GoogleFonts.playfairDisplay()
UI chrome:            DM Sans 300/400/500         → GoogleFonts.dmSans()

English Poem Body:    Playfair Display 400 · 18sp · 32sp line-height · +0.3 tracking
Bangla Poem Body:     SYSTEM DEFAULT (Noto Serif Bengali) · 18sp · 38sp line-height
                      ⚠️ NEVER set fontFamily on Bengali text — system handles it

Type Scale (Flutter TextStyle equivalents):
  Display Large   Playfair 700 · 57sp · 64sp lh  → displayLarge
  Headline Large  Playfair 600 · 32sp · 40sp lh  → headlineLarge
  Headline Medium Playfair 600 · 28sp · 36sp lh  → headlineMedium
  Headline Small  Playfair 600 · 24sp · 32sp lh  → headlineSmall
  Title Large     DM Sans 500 · 22sp · 28sp lh   → titleLarge
  Title Medium    DM Sans 500 · 16sp · 24sp lh   → titleMedium
  Title Small     DM Sans 500 · 14sp · 20sp lh   → titleSmall  ← author name on PoemCard
  Body Large      DM Sans 400 · 16sp · 24sp lh   → bodyLarge
  Body Medium     DM Sans 400 · 14sp · 20sp lh   → bodyMedium
  Body Small      DM Sans 300 · 12sp · 16sp lh   → bodySmall
  Label Large     DM Sans 500 · 14sp · 20sp lh   → labelLarge
  Label Medium    DM Sans 400 · 12sp · 16sp lh   → labelMedium
  Label Small     DM Sans 400 · 11sp · 16sp lh   → labelSmall
```

### Shape / Corner Radius

```
Extra Small  4dp   Chips, tags, snackbars       → RoundedRectangleBorder(radius: 4)
Small        8dp   Inputs, text fields           → RoundedRectangleBorder(radius: 8)
Medium       12dp  Cards, list items             → RoundedRectangleBorder(radius: 12)
Large        16dp  Bottom sheets, modals         → RoundedRectangleBorder(radius: 16)
Extra Large  28dp  FAB                           → RoundedRectangleBorder(radius: 28)
Full         50%   Avatars, circular buttons     → CircleBorder()
```

### Spacing Base Unit: 4dp

```
8dp=compact  12dp=card-internal  16dp=standard  24dp=section  32dp=large  48dp=screen-safe
```

### Component Specs (Apply to Every Screen)

**Bottom Navigation Bar (80dp):**
- Tabs: Feed · Discover · Write★ · Notifications · Profile
- Write tab = 56dp circular FAB, Primary (#1F6B5A) bg, quill-pen icon 28dp On-Primary
- In Flutter: use `BottomNavigationBar` or `NavigationBar` with a custom FAB widget in centre slot
- Active tab: pill indicator 64×32dp Primary Container. Label: Label Medium Primary.
- Inactive: Label Medium Outline (#8FA89A)

**PoemCard:**
- Width: screen − 32dp. Padding 16dp. Corner 12dp. Elevation Level 1.
- Left mood border: 3dp, mood accent colour 80%. Use `Container` with left `Border` decoration.
- Header: [Avatar 40dp] [displayName Title Small] [username Body Small] [timestamp Label Small] [⋮]
- Mood + Language chips (28dp height, 4dp corner) below header.
- Poem title: Title Large, On Surface, max 2 lines.
- Preview: Body Large, Playfair if EN, system if BN, max 3 lines.
- Action row: [🤍 N] [💬 N] [👁 N] [↗] — Icon 20dp, Label Medium On-Surface-Variant.

**Empty State Anatomy (use everywhere):**
```
Padding: 48dp top, 24dp horizontal, centred
[120×120dp illustration / icon in Outline Variant tint]
[Headline Small · On Surface · Playfair Display]
[Body Medium · On Surface Variant · max 280dp wide]
[Filled Primary CTA — optional]
```

**Toast/Snackbar:**
- Height 52dp, corner 4dp. Background: Inverse Surface (#2A312D).
- Text: Inverse On Surface (#EDF4F0), Body Medium, 16dp left-pad. Duration: 3000ms.
- In Flutter: use `ScaffoldMessenger.of(context).showSnackBar()` with custom `SnackBar` widget.

**Poetic UI Voice — Zero Generic Copy:**
- Empty feed           → "The feed is quiet. Perhaps it's time to write."
- No search results    → "No poems found. The silence holds its own poetry."
- No notifications     → "The night is quiet. No one has knocked yet."
- Empty DMs            → "No conversations yet. Send your first word."
- Poem published       → "Your words are now part of the world."
- Rate limit hit       → "The words are coming too fast. Rest for a moment, then try again."
- Draft saved          → "Saved" ← keep this one simple/functional
- 429 error            → "Easy. Even poems need space between lines."

**Skeleton Loaders (all async content):**
- Colour: Outline Variant (#D8E5DC). Shimmer: gradient left→right, 1500ms, infinite.
- In Flutter: use `flutter_animate` shimmer extension or a custom `AnimatedContainer`.
- PoemCard skeleton: circle 40dp + rect 120×14 + rect 200×20 + 3 full-width lines + action row.

**Motion:**
- Sheet open: 350ms Emphasized Decelerate — `Curves.easeInOutCubicEmphasized`
- Sheet close: 250ms Emphasized Accelerate — custom `Cubic(0.3, 0, 0.8, 0.15)`
- Like heart: scale 1.0→1.4→1.0, fill Primary, spring 300ms — `flutter_animate` `.scale()`
- Sage cursor pulse: opacity 1.0→0.3→1.0, 800ms ease-in-out, infinite — `AnimationController`
- Reduced motion: replace all with opacity 0→1, 150ms, no translate/scale

**Accessibility:**
- All interactive elements: minimum 48×48dp touch target — use `SizedBox` constraint or `InkWell`
- Text scale aware: use `MediaQuery.textScalerOf(context)` — `textScaleFactor` is deprecated since Flutter 3.12, never use it
- Every interactive element has `Semantics(label: ...)` wrapper
- Bengali script: never set `fontFamily` — system handles Noto Serif Bengali automatically

---

## Data Architecture — All MongoDB Collections

### `users` (Auth fields replace Clerk)

```json
{
  "_id": "ObjectId",
  "email": "string (unique, lowercase, indexed)",
  "passwordHash": "string (bcrypt, 12 rounds)",
  "emailVerified": "boolean (default: false)",
  "otpCode": "string | null (hashed bcrypt — 6-digit code)",
  "otpExpiry": "Date | null (10 minutes from issue)",
  "otpAttempts": "number (max 5 before lockout)",
  "refreshTokens": [
    {
      "tokenHash": "string (SHA-256 of the raw token)",
      "expiresAt": "Date",
      "deviceInfo": "string (optional)",
      "createdAt": "Date"
    }
  ],
  "username": "string (unique, lowercase, indexed)",
  "displayName": "string",
  "bio": "string",
  "avatarUrl": "string (Cloudinary URL)",
  "coverPhotoUrl": "string (Cloudinary URL)",
  "followersCount": "number",
  "followingCount": "number",
  "poemsCount": "number",
  "storiesCount": "number",
  "thoughtsCount": "number",
  "totalReads": "number",
  "totalLikes": "number",
  "isVerifiedPoet": "boolean",
  "preferredMoods": ["string"],
  "preferredLanguage": "en | bn | both",
  "hasCompletedOnboarding": "boolean",
  "fcmToken": "string (FCM device token — replaces Expo push token)",
  "emailPreferences": {
    "weeklyDigest": "boolean",
    "newFollower": "boolean",
    "duelResults": "boolean",
    "promptAlerts": "boolean"
  },
  "posthogDistinctId": "string",
  "joinedAt": "Date",
  "lastActiveAt": "Date"
}
```

> Note: `pushToken` field is renamed to `fcmToken` — stores the FCM registration token
> obtained by `firebase_messaging` on the Flutter client. Backend uses this to send
> push notifications via FCM HTTP v1 API directly (no Firebase Admin SDK required for basic sends).

### `poems`

```json
{
  "_id": "ObjectId",
  "authorId": "ObjectId (ref: users, indexed)",
  "title": "string",
  "content": "string (raw text with line breaks — plain text, not rich JSON)",
  "slug": "string (unique, URL-safe, indexed)",
  "language": "en | bn (indexed)",
  "mood": ["string (indexed)"],
  "tags": ["string (indexed)"],
  "category": "string (indexed)",
  "genre": "string (indexed)",
  "isAnonymous": "boolean",
  "isUnsent": "boolean",
  "unsentTo": "string (optional)",
  "promptId": "ObjectId (ref: prompts, optional)",
  "status": "draft | published | archived",
  "audioUrl": "string (Cloudinary)",
  "videoUrl": "string (Cloudinary)",
  "coverImageUrl": "string (Cloudinary)",
  "likesCount": "number",
  "commentsCount": "number",
  "savesCount": "number",
  "readsCount": "number",
  "trendingScore": "number (indexed)",
  "wordCount": "number",
  "lineCount": "number",
  "publishedAt": "Date (indexed)",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### `drafts`

```json
{
  "_id": "ObjectId",
  "authorId": "ObjectId (indexed)",
  "title": "string",
  "content": "string",
  "language": "en | bn",
  "mood": ["string"],
  "tags": ["string"],
  "updatedAt": "Date"
}
```

### `stories`

```json
{
  "_id": "ObjectId",
  "authorId": "ObjectId (ref: users, indexed)",
  "title": "string",
  "description": "string (max 500 chars)",
  "coverImageUrl": "string (Cloudinary)",
  "language": "en | bn (indexed)",
  "mood": ["string (indexed)"],
  "tags": ["string (indexed)"],
  "genre": "string (indexed)",
  "isCollab": "boolean",
  "collabMode": "invite-only | open",
  "storyMode": "linear | branching",
  "collabContributorIds": ["ObjectId"],
  "status": "ongoing | completed | abandoned",
  "partsCount": "number",
  "followersCount": "number",
  "totalReads": "number",
  "trendingScore": "number (indexed)",
  "publishedAt": "Date (indexed)",
  "lastPartAt": "Date (indexed)",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```
> `storyMode: "linear"` → sequential chapters. `storyMode: "branching"` → chapters can fork into multiple child paths.
> `collabMode` controls **who can contribute** (independent of storyMode).

### `storyParts`

```json
{
  "_id": "ObjectId",
  "storyId": "ObjectId (ref: stories, indexed)",
  "authorId": "ObjectId",
  "partNumber": "number (1-based)",
  "title": "string",
  "content": "string (raw text)",
  "coverImageUrl": "string (optional)",
  "language": "en | bn",
  "parentPartId": "ObjectId | null (null for root/linear; set for branching child parts)",
  "branchLabel": "string (optional — displayed in branch navigator, e.g. 'The dark path')",
  "status": "draft | published",
  "isCollabContribution": "boolean",
  "likesCount": "number",
  "commentsCount": "number",
  "readsCount": "number",
  "publishedAt": "Date",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```
> For linear stories `parentPartId` is always null. For branching stories, child parts set `parentPartId` to their parent part's `_id`.

### `thoughts`

```json
{
  "_id": "ObjectId",
  "authorId": "ObjectId (indexed)",
  "content": "string (max 280 chars)",
  "visibility": "public | private | mutual",
  "mood": "string (optional)",
  "reactionsCount": "number",
  "createdAt": "Date (indexed)"
}
```

**Visibility rules:** `private` → author only. `mutual` → users with isMutual follow. `public` → everyone.

### `follows`

```json
{
  "_id": "ObjectId",
  "followerId": "ObjectId (indexed)",
  "followingId": "ObjectId (indexed)",
  "isMutual": "boolean (indexed)",
  "createdAt": "Date"
}
```

Compound unique index: `{ followerId, followingId }`.

### `likes`

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId",
  "targetId": "ObjectId",
  "targetType": "poem | storyPart | thought",
  "createdAt": "Date"
}
```

Compound unique index: `{ userId, targetId, targetType }`.

### `comments`

```json
{
  "_id": "ObjectId",
  "targetId": "ObjectId",
  "targetType": "poem | storyPart | thought",
  "authorId": "ObjectId",
  "parentCommentId": "ObjectId | null",
  "content": "string",
  "likesCount": "number",
  "createdAt": "Date"
}
```

### `saves` / `collections`

```json
// collections
{
  "_id": "ObjectId",
  "ownerId": "ObjectId (indexed)",
  "title": "string",
  "poemIds": ["ObjectId"],
  "isPublic": "boolean",
  "createdAt": "Date"
}
// saves
{
  "_id": "ObjectId",
  "userId": "ObjectId (indexed)",
  "poemId": "ObjectId (indexed)",
  "collectionId": "ObjectId",
  "createdAt": "Date"
}
```

### `collaborativePoems`

```json
{
  "_id": "ObjectId",
  "title": "string",
  "language": "en | bn",
  "originatorId": "ObjectId",
  "collabType": "open | invite-only",
  "status": "open | closed",
  "stanzas": [
    {
      "stanzaId": "ObjectId",
      "authorId": "ObjectId",
      "content": "string",
      "order": "number",
      "isApproved": "boolean",
      "createdAt": "Date"
    }
  ],
  "contributorsCount": "number",
  "mood": ["string"],
  "createdAt": "Date"
}
```
> ⚠️ Collaborative poems are **always linear** — stanzas chain sequentially. There is no branching for poems.
> `collabType: "open"` = any user can submit a stanza. `collabType: "invite-only"` = originator sends invites.

### `duels`

```json
{
  "_id": "ObjectId",
  "theme": "string",
  "challengerId": "ObjectId",
  "challengeeId": "ObjectId",
  "challengerPoemId": "ObjectId",
  "challengeePoemId": "ObjectId | null",
  "status": "pending | active | completed | declined",
  "votesForChallenger": "number",
  "votesForChallengee": "number",
  "voterIds": ["ObjectId"],
  "winnerId": "ObjectId | null",
  "endsAt": "Date",
  "createdAt": "Date"
}
```

### `notifications`

```json
{
  "_id": "ObjectId",
  "recipientId": "ObjectId (indexed)",
  "type": "new_follower | poem_liked | storyPart_liked | thought_reacted | comment | duel_invite | duel_result | stanza_added | new_story_part | story_collab_invite",
  "actorId": "ObjectId",
  "entityId": "ObjectId",
  "entityType": "poem | storyPart | story | duel | comment | thought | collab",
  "poeticMessage": "string",
  "isRead": "boolean",
  "createdAt": "Date (indexed)"
}
```

### `conversations` + `messages`

```json
// conversations
{
  "_id": "ObjectId",
  "participantIds": ["ObjectId"],
  "conversationKey": "string (sorted userId1_userId2 — unique index)",
  "lastMessage": "string",
  "lastMessageAt": "Date",
  "unreadCounts": { "userId1": 0, "userId2": 3 },
  "createdAt": "Date"
}
// messages
{
  "_id": "ObjectId",
  "conversationId": "ObjectId (indexed)",
  "senderId": "ObjectId",
  "content": "string",
  "type": "text | poemShare | storyShare",
  "readBy": ["ObjectId"],
  "sentAt": "Date (indexed)"
}
```

### `storyFollows` / `prompts` / `emailLogs`

```json
// storyFollows — compound unique { userId, storyId }
{ "_id": "ObjectId", "userId": "ObjectId", "storyId": "ObjectId", "createdAt": "Date" }

// prompts
{ "_id": "ObjectId", "title": "string", "description": "string", "language": "en | bn | both",
  "startsAt": "Date", "endsAt": "Date", "isActive": "boolean" }

// emailLogs
{ "_id": "ObjectId", "userId": "ObjectId", "type": "otp | welcome | digest | duel_result | password_reset",
  "brevoMessageId": "string", "status": "sent | delivered | failed", "sentAt": "Date" }
```

---

## MongoDB Indexes

```javascript
// AUTH — critical for login speed
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ username: 1 }, { unique: true, sparse: true }); // sparse: username set during onboarding, not registration

// poems
db.poems.createIndex({ trendingScore: -1 });
db.poems.createIndex({ publishedAt: -1 });
db.poems.createIndex({ authorId: 1, publishedAt: -1 });
db.poems.createIndex({ mood: 1, trendingScore: -1 });
db.poems.createIndex({ language: 1, trendingScore: -1 });
db.poems.createIndex({ status: 1, publishedAt: -1 });
db.poems.createIndex({ videoUrl: 1, trendingScore: -1 }); // video feed

// stories
db.stories.createIndex({ trendingScore: -1 });
db.stories.createIndex({ authorId: 1, lastPartAt: -1 });
db.stories.createIndex({ lastPartAt: -1 });
db.stories.createIndex({ mood: 1, trendingScore: -1 });
db.storyParts.createIndex({ storyId: 1, partNumber: 1 });
db.storyParts.createIndex({ storyId: 1, publishedAt: -1 });

// thoughts
db.thoughts.createIndex({ authorId: 1, visibility: 1, createdAt: -1 });

// social
db.follows.createIndex({ followerId: 1, followingId: 1 }, { unique: true });
db.follows.createIndex({ followingId: 1 });
db.follows.createIndex({ followerId: 1, isMutual: 1 });

// engagement
db.likes.createIndex({ userId: 1, targetId: 1, targetType: 1 }, { unique: true });
db.comments.createIndex({ targetId: 1, targetType: 1, createdAt: -1 });
db.saves.createIndex({ userId: 1, poemId: 1 });
db.storyFollows.createIndex({ userId: 1, storyId: 1 }, { unique: true });

// messaging
db.conversations.createIndex({ conversationKey: 1 }, { unique: true });
db.conversations.createIndex({ participantIds: 1 });
db.messages.createIndex({ conversationId: 1, sentAt: -1 });

// notifications
db.notifications.createIndex({ recipientId: 1, createdAt: -1 });
db.notifications.createIndex({ recipientId: 1, isRead: 1 });

// drafts
db.drafts.createIndex({ authorId: 1, updatedAt: -1 });
```

---

## Atlas Search Index Configuration

> **Critical:** Use `lucene.standard` — NOT `lucene.english`.
> The English analyzer strips Bengali tokens and permanently breaks Bangla search.

Create this index on both `poems` (name: `poems_search`) and `stories` (name: `stories_search`):

```json
{
  "mappings": {
    "dynamic": false,
    "fields": {
      "title":    { "type": "string", "analyzer": "lucene.standard" },
      "content":  { "type": "string", "analyzer": "lucene.standard" },
      "tags":     { "type": "string", "analyzer": "lucene.standard" },
      "mood":     { "type": "string" },
      "genre":    { "type": "string" },
      "language": { "type": "string" },
      "status":   { "type": "string" }
    }
  }
}
```

---

# PHASE 0 — Project Setup, Auth Foundation & Design System Wiring

**MVP Tier ✅ · Build this first, before any feature code.**

**Goal:** Fully wired Flutter project with zero features — every tool connected, every folder created,
every environment variable set, every index created, custom JWT auth implemented end-to-end,
Brevo OTP working, and design tokens loaded. When Phase 0 is done:
- `GET /health` returns 200
- Flutter app boots on Android emulator with correct fonts and colours
- Register → OTP email → Verify → JWT → Onboarding flow works completely

---

## Step 0.1 — Initialize the Flutter Project

```bash
flutter create verso --org app.verso --platforms android
cd verso
# Verify blank project runs on emulator BEFORE adding any dependencies
flutter run
```

---

## Step 0.2 — Install All Flutter Dependencies

> Run `flutter pub add <package_name>` for each package below — this fetches the latest stable version automatically.
> ⚠️ `firebase_core` + `firebase_messaging` must be version-compatible — check the FlutterFire compatibility matrix at pub.dev/packages/firebase_messaging before adding or upgrading either.
> ⚠️ `socket_io_client` — use latest stable that supports Socket.IO **protocol v4**. Verify changelog before any major version upgrade.

Add to `pubspec.yaml`:

```yaml
# ═══════════════════════════════════════════════════════════════════
# Verso — pubspec.yaml dependencies (2026 stable versions)
# Flutter SDK: 3.32.x stable channel
#
# VERSION RULES:
#   PINNED  = exact version required — breaking changes or BoM coupling
#   LATEST  = always install latest stable — no strict version coupling
#
# ⚠️  CRITICAL COMPATIBILITY PAIRS — never upgrade independently:
#   firebase_core ^4.3.0  ←→  firebase_messaging ^15.0.0   (FlutterFire BoM)
#   socket_io_client ^3.1.4  ←→  backend socket.io@^4      (protocol v4)
# ═══════════════════════════════════════════════════════════════════

dependencies:
  flutter:
    sdk: flutter

  # Routing (LATEST)
  go_router:

  # State management — Riverpod 3.x (PINNED)
  # ⚠️ 3.x removes StateNotifierProvider, StateNotifier, ChangeNotifierProvider
  # ✓ Use @riverpod annotations with Notifier / AsyncNotifier only
  # ✓ Run: dart pub global activate riverpod_cli && riverpod migrate
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^3.3.1

  # HTTP (PINNED)
  dio: ^5.9.2

  # Token storage (LATEST)
  flutter_secure_storage:

  # Local cache (LATEST)
  hive_ce:
  hive_ce_flutter:       # ⚠️ Required alongside hive_ce — both must be in pubspec.yaml

  # Fonts (LATEST)
  google_fonts:

  # Images (LATEST)
  cached_network_image:
  blurhash_dart:         # Required companion for blurhash placeholders

  # Video & Audio (LATEST)
  video_player:
  just_audio:

  # Real-time — PINNED + protocol lock
  # ⚠️ socket_io_client 3.x uses Socket.IO protocol v4
  # ⚠️ Backend MUST use socket.io@^4 — v5+ breaks connection silently
  # ⚠️ Do NOT upgrade either side without migrating both simultaneously
  socket_io_client: ^3.1.4
  pusher_channels_flutter:

  # Push notifications — Firebase BoM 2026 (PINNED PAIR)
  # ⚠️ firebase_core 4.x + firebase_messaging 15.x are BoM-paired
  # ⚠️ Upgrading one without the other WILL break the app
  # ⚠️ Always check: pub.dev/packages/firebase_messaging → FlutterFire matrix
  firebase_core: ^4.3.0
  firebase_messaging: ^15.0.0   # FCM token retrieval ONLY — no Firestore, no Auth
  flutter_local_notifications:

  # Media picker (LATEST)
  image_picker:
  file_picker:

  # Animations (LATEST)
  flutter_animate:

  # Monitoring (LATEST)
  sentry_flutter:
  posthog_flutter:

  # Network (LATEST)
  connectivity_plus:

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^3.3.1   # PINNED — must match flutter_riverpod major version
  build_runner:
  flutter_lints:
  # riverpod_annotation → dependencies (runtime)
  # riverpod_generator  → dev_dependencies (code-gen only, not shipped)
```

```bash
flutter pub get
```

---

## Step 0.3 — Initialize the Backend (unchanged from v3)

```bash
mkdir verso-api && cd verso-api
npm init -y

# Core
npm install express mongoose cors helmet dotenv morgan compression

# Auth — custom JWT (no Clerk, no Firebase Auth)
npm install jsonwebtoken bcryptjs

# Real-time
npm install socket.io@^4 pusher   # ⚠️ socket.io MUST stay on major version 4 — socket_io_client Flutter package uses protocol v4; v5+ breaks the connection silently. Do NOT upgrade to v5+ without updating socket_io_client.

# Rate limiting
npm install @upstash/redis @upstash/ratelimit

# Validation
npm install zod sanitize-html

# Email (OTP + transactional + digest)
npm install @getbrevo/brevo

# Push notifications — FCM HTTP v1 API
npm install google-auth-library   # for FCM v1 OAuth2 token
npm install axios                 # HTTP client used by fcmPush.service.ts

# Analytics
npm install posthog-node

# Cron
npm install node-cron

# Monitoring
npm install @sentry/node

# Dev
npm install --save-dev typescript ts-node nodemon @types/express @types/node
npm install --save-dev @types/cors @types/morgan @types/node-cron
npm install --save-dev @types/jsonwebtoken @types/bcryptjs @types/sanitize-html
npm install --save-dev @types/compression    # TypeScript types for compression (compression does not ship its own types)
```

> **Push notifications change from v3:** Instead of `expo-server-sdk`, the backend now uses
> the FCM HTTP v1 API directly with `google-auth-library` for OAuth2 token generation.
> See Step 0.7g for the updated push service.

---

## Step 0.4 — Flutter Folder Structure

```
/verso
├── lib/
│   ├── main.dart
│   ├── app.dart                          ← MaterialApp + go_router setup
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart           ← Sage & Vellum colour tokens
│   │   │   ├── app_typography.dart       ← TextTheme + poem body styles (AppTypography.englishPoem / banglaPoem)
│   │   │   ├── app_theme.dart            ← ThemeData builder
│   │   │   └── app_shapes.dart           ← AppShapes corner radius constants
│   │   ├── router/
│   │   │   └── app_router.dart           ← go_router config
│   │   ├── di/
│   │   │   └── providers.dart            ← Riverpod providers
│   │   ├── network/
│   │   │   ├── dio_client.dart           ← Dio + QueuedInterceptor
│   │   │   └── api_endpoints.dart
│   │   ├── storage/
│   │   │   ├── secure_storage.dart       ← flutter_secure_storage helpers
│   │   │   └── hive_storage.dart         ← hive_ce helpers
│   │   └── constants/
│   │       ├── moods.dart
│   │       └── copy.dart                 ← all poetic UI strings
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── auth_models.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart    ← Riverpod auth state
│   │   │   └── screens/
│   │   │       ├── welcome_screen.dart
│   │   │       ├── sign_up_screen.dart
│   │   │       ├── sign_in_screen.dart
│   │   │       ├── verify_otp_screen.dart
│   │   │       ├── forgot_password_screen.dart
│   │   │       └── onboarding/
│   │   │           ├── username_screen.dart
│   │   │           ├── moods_screen.dart
│   │   │           └── language_screen.dart
│   │   ├── feed/
│   │   │   ├── data/
│   │   │   │   └── feed_repository.dart
│   │   │   ├── providers/
│   │   │   │   └── feed_provider.dart
│   │   │   └── screens/
│   │   │       └── feed_screen.dart
│   │   ├── poem/
│   │   │   ├── data/
│   │   │   │   └── poem_repository.dart
│   │   │   ├── providers/
│   │   │   │   └── poem_provider.dart
│   │   │   └── screens/
│   │   │       ├── poem_reader_screen.dart
│   │   │       └── poem_editor_screen.dart
│   │   ├── discover/
│   │   │   └── screens/
│   │   │       ├── discover_screen.dart
│   │   │       └── search_screen.dart
│   │   ├── profile/
│   │   │   └── screens/
│   │   │       ├── own_profile_screen.dart
│   │   │       └── user_profile_screen.dart
│   │   ├── story/
│   │   │   └── screens/
│   │   │       ├── story_reader_screen.dart
│   │   │       ├── story_part_screen.dart
│   │   │       └── story_editor_screen.dart
│   │   ├── thought/
│   │   │   └── widgets/
│   │   │       └── thought_composer_sheet.dart
│   │   ├── video/
│   │   │   └── screens/
│   │   │       └── video_feed_screen.dart
│   │   ├── messages/
│   │   │   └── screens/
│   │   │       ├── conversations_screen.dart
│   │   │       └── message_thread_screen.dart
│   │   ├── notifications/
│   │   │   └── screens/
│   │   │       └── notifications_screen.dart
│   │   ├── collab/
│   │   │   └── screens/
│   │   │       └── collab_screen.dart
│   │   └── duel/
│   │       └── screens/
│   │           └── duel_screen.dart
│   └── shared/
│       ├── widgets/
│       │   ├── poem_card.dart
│       │   ├── thought_card.dart
│       │   ├── story_update_card.dart
│       │   ├── duel_feed_card.dart
│       │   ├── collab_feed_card.dart
│       │   ├── user_avatar.dart
│       │   ├── follow_button.dart
│       │   ├── mood_chip.dart
│       │   ├── otp_input.dart            ← 6-box OTP input widget
│       │   ├── empty_state.dart
│       │   ├── skeleton_loader.dart
│       │   ├── bottom_sheet_base.dart
│       │   └── comment_sheet.dart
│       └── models/
│           ├── user_model.dart
│           ├── poem_model.dart
│           ├── story_model.dart
│           └── feed_item_model.dart
└── android/
    └── app/
        └── google-services.json          ← Firebase config (FCM token only)
```

---

## Step 0.5 — Backend Folder Structure (unchanged from v3)

```
/verso-api
└── src/
    ├── server.ts
    ├── socket.ts
    ├── routes/         (auth, poems, stories, storyParts, thoughts, users,
    │                    feed, comments, collections, duels, collab,
    │                    notifications, conversations)
    ├── controllers/
    │   └── auth.controller.ts
    ├── models/         (User, Poem, Draft, Story, StoryPart, StoryFollow,
    │                    Thought, Follow, Like, Comment, Collection, Save,
    │                    CollabPoem, Duel, Notification, Conversation,
    │                    Message, EmailLog)
    ├── middleware/
    │   ├── auth.middleware.ts
    │   ├── rateLimit.middleware.ts
    │   ├── validate.middleware.ts
    │   └── error.middleware.ts
    ├── services/
    │   ├── email.service.ts
    │   ├── trending.service.ts
    │   ├── notification.service.ts
    │   ├── cloudinary.service.ts
    │   ├── pusher.service.ts
    │   └── fcmPush.service.ts            ← replaces expoPush.service.ts
    ├── jobs/
    │   ├── trendingScore.job.ts
    │   ├── weeklyDigest.job.ts
    │   └── promptRotation.job.ts
    └── utils/
        ├── slug.ts
        ├── sanitize.ts
        ├── pagination.ts
        └── jwt.ts
```

---

## Step 0.6 — Flutter Theme: Sage & Vellum Design Tokens

```dart
// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary            = Color(0xFF1F6B5A);
  static const primaryContainer    = Color(0xFFA8DACC);
  static const onPrimary           = Color(0xFFFFFFFF);
  static const onPrimaryContainer  = Color(0xFF00201A);
  static const secondary           = Color(0xFF4A7C59);
  static const secondaryContainer  = Color(0xFFC1E8C8);
  static const onSecondary         = Color(0xFFFFFFFF);
  static const onSecondaryContainer= Color(0xFF0B2112);
  static const tertiary            = Color(0xFF6B7B6E);
  static const tertiaryContainer   = Color(0xFFDDE8DE);
  static const onTertiary          = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFF1A2B1D);
  static const surface             = Color(0xFFF6FAF8);
  // surfaceVariant kept as a project token name — used directly in widgets, not as a ColorScheme param
  static const surfaceVariant      = Color(0xFFEDF4F0);
  static const onSurface           = Color(0xFF1A1C1A);
  static const onSurfaceVariant    = Color(0xFF404944);
  static const background          = Color(0xFFF6FAF8); // same as surface — kept for backward compat
  static const outline             = Color(0xFF8FA89A);
  static const outlineVariant      = Color(0xFFD8E5DC);
  static const error               = Color(0xFFB3261E);
  static const errorContainer      = Color(0xFFF9DEDC);
  static const inverseSurface      = Color(0xFF2A312D);
  static const inverseOnSurface    = Color(0xFFEDF4F0);
  static const success             = Color(0xFF16A34A);

  // Mood accents
  static const moodMelancholic = Color(0xFF6366F1);
  static const moodRomantic    = Color(0xFFEC4899);
  static const moodJoyful      = Color(0xFFF59E0B);
  static const moodAngry       = Color(0xFFEF4444);
  static const moodPeaceful    = Color(0xFF1F6B5A);
  static const moodNostalgic   = Color(0xFF8B5CF6);
  static const moodMysterious  = Color(0xFF1F2937);
  static const moodSpiritual   = Color(0xFFD97706);

  static Color moodColor(String mood) {
    const map = {
      'melancholic': moodMelancholic, 'romantic': moodRomantic,
      'joyful': moodJoyful,           'angry': moodAngry,
      'peaceful': moodPeaceful,       'nostalgic': moodNostalgic,
      'mysterious': moodMysterious,   'spiritual': moodSpiritual,
    };
    return map[mood] ?? primary;
  }
}
```

```dart
// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get textTheme => TextTheme(
    displayLarge:  GoogleFonts.playfairDisplay(fontSize: 57, fontWeight: FontWeight.w700, height: 64/57, color: AppColors.onSurface),
    headlineLarge: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w600, height: 40/32, color: AppColors.onSurface),
    headlineMedium:GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, height: 36/28, color: AppColors.onSurface),
    headlineSmall: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600, height: 32/24, color: AppColors.onSurface),
    titleLarge:    GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500, height: 28/22, color: AppColors.onSurface),
    titleMedium:   GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, height: 24/16, color: AppColors.onSurface),
    bodyLarge:     GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w400, height: 24/16, color: AppColors.onSurface),
    bodyMedium:    GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, height: 20/14, color: AppColors.onSurface),
    bodySmall:     GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w300, height: 16/12, color: AppColors.onSurfaceVariant),
    labelLarge:    GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, height: 20/14, color: AppColors.onSurface),
    labelMedium:   GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400, height: 16/12, color: AppColors.onSurface),
    labelSmall:    GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w400, height: 16/11, color: AppColors.onSurfaceVariant),
  );

  // Use this for Bengali text — no fontFamily set, system Noto Serif Bengali takes over
  static TextStyle banglaPoem = const TextStyle(fontSize: 18, height: 38/18, color: AppColors.onSurface);
  // Use this for English poem body
  static TextStyle englishPoem = GoogleFonts.playfairDisplay(fontSize: 18, height: 32/18, letterSpacing: 0.3, color: AppColors.onSurface);
}
```

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary:               AppColors.primary,
      primaryContainer:      AppColors.primaryContainer,
      onPrimary:             AppColors.onPrimary,
      onPrimaryContainer:    AppColors.onPrimaryContainer,
      secondary:             AppColors.secondary,
      secondaryContainer:    AppColors.secondaryContainer,
      onSecondary:           AppColors.onSecondary,
      onSecondaryContainer:  AppColors.onSecondaryContainer,
      tertiary:              AppColors.tertiary,
      tertiaryContainer:     AppColors.tertiaryContainer,
      onTertiary:            AppColors.onTertiary,
      onTertiaryContainer:   AppColors.onTertiaryContainer,
      surface:               AppColors.surface,
      // surfaceVariant → deprecated in Flutter 3.18; map to surfaceContainerHighest
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurface:             AppColors.onSurface,
      onSurfaceVariant:      AppColors.onSurfaceVariant,
      error:                 AppColors.error,
      errorContainer:        AppColors.errorContainer,
      outline:               AppColors.outline,
      outlineVariant:        AppColors.outlineVariant,
      inverseSurface:        AppColors.inverseSurface,
      onInverseSurface:      AppColors.inverseOnSurface,
      // background & onBackground removed — deprecated since Flutter 3.18; surface is used instead
    ),
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.inverseSurface,
      contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.inverseOnSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
```

---

## Step 0.7 — Custom JWT Auth — Backend Implementation

All backend auth logic is identical to v3. The only change is the push service (Step 0.7g).

### Step 0.7a–f — User Model, JWT Utilities, Auth Controller, Middleware, Routes
*(Identical to v3 — copy from previous version. No changes needed.)*

### Step 0.7g — FCM Push Service (replaces Expo Push Service)

```typescript
// src/services/fcmPush.service.ts
import { GoogleAuth } from "google-auth-library";
import axios from "axios";

const FCM_ENDPOINT = "https://fcm.googleapis.com/v1/projects/{YOUR_PROJECT_ID}/messages:send";

async function getFCMAccessToken(): Promise<string> {
  const auth = new GoogleAuth({
    keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_KEY_PATH,  // path to service account JSON
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });
  const client = await auth.getClient();
  const tokenResponse = await client.getAccessToken();
  return tokenResponse.token!;
}

export async function sendFCMPush(
  fcmToken: string,
  message: { title: string; body: string; data?: Record<string, string> }
): Promise<void> {
  try {
    const accessToken = await getFCMAccessToken();
    await axios.post(
      FCM_ENDPOINT,
      {
        message: {
          token: fcmToken,
          notification: { title: message.title, body: message.body },
          data: message.data ?? {},
          android: {
            priority: "high",
            notification: { sound: "default", click_action: "FLUTTER_NOTIFICATION_CLICK" },
          },
        },
      },
      { headers: { Authorization: `Bearer ${accessToken}`, "Content-Type": "application/json" } }
    );
  } catch (err) {
    // Silently fail — push is non-critical
  }
}
```

> **Environment variables needed:**
> - `GOOGLE_SERVICE_ACCOUNT_KEY_PATH` — path to your Firebase service account JSON (download from Firebase Console → Project Settings → Service Accounts)
> - `FIREBASE_PROJECT_ID` — your Firebase project ID

---

## Step 0.8 — Backend Server (unchanged from v3)

Identical `server.ts` with Socket.io. No changes. Copy from v3.

---

## Step 0.9 — Environment Variables & Secrets Rules

> ⚠️ Two-tier secrets model. Read before writing any code that touches keys or tokens.

### Tier 1 — Build-time config (Flutter client)

Use `--dart-define` only. **Never use `flutter_dotenv`** — dotenv files are bundled inside the APK and readable by anyone who unzips it. `--dart-define` values are compiled in.

```dart
// Access in code
const apiUrl     = String.fromEnvironment('API_URL', defaultValue: 'https://api.verso.app');
const pusherKey  = String.fromEnvironment('PUSHER_KEY');
const pusherCluster = String.fromEnvironment('PUSHER_CLUSTER', defaultValue: 'ap2');
const sentryDsn  = String.fromEnvironment('SENTRY_DSN');
const posthogKey = String.fromEnvironment('POSTHOG_KEY');
```

**Local development — `run.sh` (add to .gitignore):**
```bash
flutter run \
  --dart-define=API_URL=http://10.0.2.2:3000 \
  --dart-define=PUSHER_KEY=your_key \
  --dart-define=PUSHER_CLUSTER=ap2 \
  --dart-define=SENTRY_DSN=your_dsn \
  --dart-define=POSTHOG_KEY=your_key
```

**CI/CD — GitHub Actions secrets (never commit real values):**
```
API_URL, PUSHER_KEY, SENTRY_DSN, POSTHOG_KEY
```

### Tier 2 — Runtime user tokens (flutter_secure_storage)

```dart
// ✅ Always — OS-encrypted storage
await SecureStorage.saveTokens(accessToken: token, refreshToken: refresh);

// ❌ Never — unencrypted
SharedPreferences.getInstance().then((p) => p.setString('token', token));
```

### What lives where

| Secret | Location | Access |
|---|---|---|
| API_URL, PUSHER_KEY, SENTRY_DSN, POSTHOG_KEY | `--dart-define` | `String.fromEnvironment()` |
| JWT access + refresh tokens | `flutter_secure_storage` | `SecureStorage.read()` |
| JWT_ACCESS_SECRET, JWT_REFRESH_SECRET | Backend `.env` only | `process.env.X` |
| MONGODB_URI, CLOUDINARY_API_SECRET | Backend `.env` only | `process.env.X` |
| PUSHER_SECRET, BREVO_API_KEY | Backend `.env` only | `process.env.X` |

> Backend secrets never appear in Flutter code. Flutter only holds the user's JWT token — not the signing key. Same model as React: your React app never sees `JWT_SECRET`.

### .gitignore rules (Flutter project root)
```
.env
.env.local
*.env
run.sh
```

**Flutter build-time values (all via --dart-define):**
```
API_URL=https://api.verso.app
SENTRY_DSN=https://xxx@sentry.io/xxx
POSTHOG_KEY=phc_xxx
PUSHER_KEY=xxx
PUSHER_CLUSTER=ap2
```

**Backend `.env` (server only — never in Flutter):**
```
MONGODB_URI=mongodb+srv://...
JWT_ACCESS_SECRET=<64-byte-hex>
JWT_REFRESH_SECRET=<64-byte-hex-different-from-above>
CLOUDINARY_CLOUD_NAME=xxx
CLOUDINARY_API_KEY=xxx
CLOUDINARY_API_SECRET=xxx
PUSHER_APP_ID=xxx
PUSHER_KEY=xxx
PUSHER_SECRET=xxx
PUSHER_CLUSTER=ap2
UPSTASH_REDIS_REST_URL=https://xxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=xxx
BREVO_API_KEY=xkeysib-xxx
SENTRY_DSN=https://xxx@sentry.io/xxx
POSTHOG_API_KEY=phc_xxx
GOOGLE_SERVICE_ACCOUNT_KEY_PATH=./firebase-service-account.json
FIREBASE_PROJECT_ID=verso-xxxxx
PORT=3000
NODE_ENV=production
API_URL=https://api.verso.app
```

---

## Step 0.10 — Flutter Auth Layer: Token Storage + Dio Interceptor

```dart
// lib/core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _accessKey  = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  static Future<String?> getAccessToken()  async => _storage.read(key: _accessKey);
  static Future<String?> getRefreshToken() async => _storage.read(key: _refreshKey);

  static Future<void> setTokens(String access, String refresh) async {
    await _storage.write(key: _accessKey,  value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
```

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'https://api.verso.app'),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    // Attach access token to every request
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getAccessToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));

    // Auto-refresh interceptor using QueuedInterceptor
    dio.interceptors.add(_RefreshInterceptor(dio));

    return dio;
  }
}

class _RefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;
  _RefreshInterceptor(this._dio);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) {
      await SecureStorage.clearTokens();
      return handler.next(err);
    }

    try {
      final response = await Dio().post(
        '${err.requestOptions.baseUrl}/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final newAccess  = response.data['accessToken']  as String;
      final newRefresh = response.data['refreshToken'] as String;
      await SecureStorage.setTokens(newAccess, newRefresh);

      // Retry original request with new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccess';
      final retried = await _dio.fetch(opts);
      return handler.resolve(retried);
    } catch (_) {
      await SecureStorage.clearTokens();
      return handler.next(err);
    }
  }
}
```

```dart
// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';
import '../data/auth_models.dart';
import '../../core/storage/secure_storage.dart';

part 'auth_provider.g.dart';

// AuthState — plain data class, no changes needed from 2.x
class AuthState {
  final AuthUser? user;
  final bool isLoading;
  const AuthState({this.user, this.isLoading = false});
  bool get isAuthenticated => user != null;
  AuthState copyWith({AuthUser? user, bool? isLoading}) =>
    AuthState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading);
}

// Riverpod 3.x: @riverpod annotation + Notifier replaces StateNotifierProvider
@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    _loadUser();
    return const AuthState();
  }

  Future<void> _loadUser() async {
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      // Decode JWT sub/email from token or fetch /api/users/me
      // state = state.copyWith(user: storedUser);
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true);
    await ref.read(authRepositoryProvider).register(email, password);
    state = state.copyWith(isLoading: false);
  }

  Future<AuthUser> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true);
    final user = await ref.read(authRepositoryProvider).verifyOtp(email, otp);
    state = AuthState(user: user);
    return user;
  }

  Future<AuthUser> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    final user = await ref.read(authRepositoryProvider).login(email, password);
    state = AuthState(user: user);
    return user;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    await SecureStorage.clearTokens();
    state = const AuthState();
  }
}

// Usage in widgets: ref.watch(authProvider) — same call site as Riverpod 2.x
// Generated provider name: authProvider (from class name Auth → authProvider)
```

---

## Step 0.11 — go_router Configuration

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../notifications/fcm_handler.dart'; // for navigatorKey
// import all screen files...

part 'app_router.g.dart';

// Riverpod 3.x: @riverpod replaces Provider<GoRouter>
// keepAlive: true — router must never be disposed during app lifetime
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: navigatorKey,   // global key for FCM tap navigation outside widget tree
    initialLocation: '/auth/welcome',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.fullPath?.startsWith('/auth') ?? false;

      if (!isAuth && !isAuthRoute) return '/auth/welcome';
      if (isAuth && !authState.user!.hasCompletedOnboarding) {
        return '/auth/onboarding/username';
      }
      if (isAuth && isAuthRoute && authState.user!.hasCompletedOnboarding) {
        return '/feed';
      }
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/auth/welcome',               builder: (c, s) => const WelcomeScreen()),
      GoRoute(path: '/auth/sign-up',               builder: (c, s) => const SignUpScreen()),
      GoRoute(path: '/auth/sign-in',               builder: (c, s) => const SignInScreen()),
      GoRoute(path: '/auth/verify-otp',            builder: (c, s) => VerifyOtpScreen(email: s.extra as String)),
      GoRoute(path: '/auth/forgot-password',       builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(path: '/auth/onboarding/username',   builder: (c, s) => const OnboardingUsernameScreen()),
      GoRoute(path: '/auth/onboarding/moods',      builder: (c, s) => const OnboardingMoodsScreen()),
      GoRoute(path: '/auth/onboarding/language',   builder: (c, s) => const OnboardingLanguageScreen()),

      // Main tabs shell
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/feed',          builder: (c, s) => const FeedScreen()),
          GoRoute(path: '/discover',      builder: (c, s) => const DiscoverScreen()),
          GoRoute(path: '/write',         builder: (c, s) => const PoemEditorScreen()),
          GoRoute(path: '/notifications', builder: (c, s) => const NotificationsScreen()),
          GoRoute(path: '/profile',       builder: (c, s) => const OwnProfileScreen()),
        ],
      ),

      // Content routes (push navigation)
      GoRoute(path: '/poem/:id',                    builder: (c, s) => PoemReaderScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/story/:id',                   builder: (c, s) => StoryReaderScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/story/:id/part/:partId',      builder: (c, s) => StoryPartScreen(storyId: s.pathParameters['id']!, partId: s.pathParameters['partId']!)),
      GoRoute(path: '/user/:username',              builder: (c, s) => UserProfileScreen(username: s.pathParameters['username']!)),
      GoRoute(path: '/duel/:id',                    builder: (c, s) => DuelScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/collab/:id',                  builder: (c, s) => CollabScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/video-feed',                  builder: (c, s) => const VideoFeedScreen()),
      GoRoute(path: '/messages',                    builder: (c, s) => const ConversationsScreen()),
      GoRoute(path: '/messages/:conversationId',    builder: (c, s) => MessageThreadScreen(conversationId: s.pathParameters['conversationId']!)),
      GoRoute(path: '/write/story',                 builder: (c, s) => const StoryEditorScreen()),
      GoRoute(path: '/discover/search',             builder: (c, s) => const SearchScreen()),
    ],
  );
}

// Usage in main.dart:
// MaterialApp.router(routerConfig: ref.watch(routerProvider))
```

---

## Step 0.12 — FCM Token Registration (Flutter)

```dart
// In main.dart — called after user logs in
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> registerFCMToken(String userId) async {
  final messaging = FirebaseMessaging.instance;

  // Request permission (Android 13+)
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // Get FCM token
  final token = await messaging.getToken();
  if (token != null) {
    // Send to backend: PUT /api/users/me/fcm-token
    await DioClient.instance.put('/api/users/me/fcm-token', data: {'fcmToken': token});
  }

  // Listen for token refresh
  messaging.onTokenRefresh.listen((newToken) async {
    await DioClient.instance.put('/api/users/me/fcm-token', data: {'fcmToken': newToken});
  });
}
```

> **Important:** `firebase_messaging` is used ONLY to retrieve the FCM device token.
> No Firestore, no Firebase Auth, no Firebase Realtime Database is used anywhere.
> The token is stored in MongoDB (`user.fcmToken`) and used by your Express backend
> to call the FCM HTTP v1 API. This keeps the architecture clean and cost-free.

---

## Step 0.13 — OTP Input Widget

```dart
// lib/shared/widgets/otp_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';

class OtpInput extends StatefulWidget {
  final void Function(String otp) onComplete;
  const OtpInput({required this.onComplete, super.key});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: 52, height: 60,
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outline, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
              _checkComplete();
            },
          ),
        ),
      )),
    );
  }

  void _checkComplete() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) widget.onComplete(otp);
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }
}
```

---

## Step 0.14 — Phase 0 Checklist

- [ ] `flutter run` boots on Android emulator with correct fonts and Sage & Vellum colours
- [ ] Playfair Display + DM Sans load correctly
- [ ] Bengali text renders in system font (no custom font applied)
- [ ] Backend starts, `GET /health` returns 200
- [ ] MongoDB Atlas connected, all indexes created
- [ ] Atlas Search indexes created (`poems_search`, `stories_search`)
- [ ] `POST /api/auth/register` → OTP email arrives via Brevo
- [ ] OTP email styled correctly (sage colours, readable code)
- [ ] `POST /api/auth/verify-otp` → returns JWT access + refresh tokens
- [ ] `POST /api/auth/login` → tokens for verified user
- [ ] `POST /api/auth/refresh` → rotates token pair
- [ ] `POST /api/auth/logout` → token revoked from MongoDB
- [ ] Forgot password → OTP → reset password works end-to-end
- [ ] Dio auto-refreshes on 401 (user never sees token expiry)
- [ ] Tokens persist across app restarts (flutter_secure_storage)
- [ ] go_router redirects unauthenticated users to welcome screen
- [ ] Register → OTP → Username → Moods → Language → Feed flow works
- [ ] OTP: 5-attempt lockout (429) enforced
- [ ] OTP: 10-minute expiry enforced
- [ ] Password reset: ALL sessions revoked after reset
- [ ] All auth screens match Sage & Vellum spec
- [ ] FCM token registered after login and stored in MongoDB
- [ ] No Clerk / No Firebase Auth / No Firebase Firestore anywhere

---

# PHASE 1 — Poems, Feed, Discover, Profile (MVP)

**Done when:** Users can write + publish poems, browse filtered feed, discover trending, view profile.

---

## Step 1.1 — Poem Model + Backend (unchanged from v3)

Poem pre-save hook, API routes, feed endpoint, trending cron — all identical to v3. Copy from previous version.

---

## Step 1.2 — Feed Screen UI

**Route:** `/feed`

```dart
// Flutter layout equivalent of the React Native feed screen
// Scaffold with:
//   appBar: custom 64dp app bar (hide on scroll using SliverAppBar)
//   body: Column [
//     FeedFilterBar (horizontal SingleChildScrollView of FilterChip widgets)
//     Expanded → ListView.builder (replaces FlashList)
//       each item dispatches to correct card widget by contentType
//   ]
//   bottomNavigationBar: MainBottomNav (80dp)
//
// SliverAppBar: pinned: false, floating: true, snap: true
// Filter chips: active = secondaryContainer bg + primary text, 32dp height, 4dp corner
```

**PoemCard widget:**
```dart
// lib/shared/widgets/poem_card.dart
// Container with left border decoration (3dp, mood accent at 80% opacity)
// Card with elevation 1, borderRadius 12
// Header Row: CircleAvatar(40) + displayName (titleSmall) + @username (bodySmall) + timestamp (labelSmall) + PopupMenuButton
// Chip Row: MoodChip + LanguageChip
// Title Text: max 2 lines, titleLarge — use Playfair only if language == 'en'
// Preview Text: max 3 lines, bodyLarge — same font rule
// Action Row: [HeartButton N] [CommentButton N] [EyeIcon N] [ShareButton]
// Like animation: flutter_animate .scale(begin: 1, end: 1.4, duration: 150ms).then().scale(begin: 1.4, end: 1.0)
// Skeleton: use flutter_animate .shimmer() on placeholder Containers
```

---

## Step 1.3 — Poem Editor Screen

**Route:** `/write`

```dart
// Scaffold:
//   resizeToAvoidBottomInset: true
//   appBar: AppBar with back (saves draft), title "New Poem",
//           [EN|BN SegmentedButton], [Publish ElevatedButton disabled until title+1line]
//   body: Column [
//     TextField (title, Playfair 22sp, no border, focus → 2dp primary underline)
//     Expanded → TextField (poem body, multiline, no maxLines)
//       EN: GoogleFonts.playfairDisplay(size:18, height:32/18, letterSpacing:0.3)
//       BN: TextStyle(size:18, height:38/18) — no fontFamily
//       cursorColor: AppColors.primary
//       Cursor pulse: AnimationController opacity 1.0→0.3→1.0, 800ms, repeat
//       placeholder: "Begin here…" in italic On-Surface-Variant
//   ]
//   bottomSheet: ToolbarRow (Bold · Italic · Indent · ——— · 🖼)

// Auto-save: Timer.periodic(3 seconds) debounce → PUT /api/drafts/:id
// On save success: ScaffoldMessenger snackbar "Saved"
```

---

## Step 1.4 — Poem Reader Screen

**Route:** `/poem/:id`

```dart
// Scaffold with extendBodyBehindAppBar: true
// appBar: AppBar(backgroundColor: Colors.transparent, leading: back, actions: [share])
// body: SingleChildScrollView → Column [
//   88dp top padding
//   Title: headlineLarge Playfair
//   Author row: CircleAvatar(32) + displayName + timestamp
//   Chips: language + mood (horizontal SingleChildScrollView)
//   Poem body: EN → AppTypography.englishPoem | BN → AppTypography.banglaPoem
//   Stanza breaks: em-dash centred
// ]
// bottomNavigationBar: _ReactionBar (64dp): [LikeButton N] [CommentButton N] [SaveButton] [ShareButton]
// Read tracking: Timer(Duration(seconds: 5)) → POST /api/poems/:id/read
```

---

## Step 1.5 — Discover Screen, Profile Screen

Both follow the same layout principles as v3.
- Discover: `CustomScrollView` with `SliverAppBar` (expanded search bar) + horizontal lists using `ListView.builder(scrollDirection: Axis.horizontal)`
- Profile: `NestedScrollView` with `SliverAppBar` (cover photo) + `TabBar` + `TabBarView`
- All fonts follow the EN/BN rule consistently

---

## Step 1.6 — Phase 1 Checklist

- [ ] Feed renders PoemCard, ThoughtCard, StoryUpdateCard correctly
- [ ] Feed filter chips filter by content type
- [ ] Skeleton shimmer on all async content
- [ ] Empty states use poetic copy
- [ ] Poem editor sage cursor pulse (800ms)
- [ ] Auto-save draft every 3s of inactivity, "Saved" snackbar
- [ ] EN/BN toggle sets poem language correctly
- [ ] Publish button disabled until title + 1 line
- [ ] "Your words are now part of the world." snackbar on publish
- [ ] Poem reader EN: Playfair 18sp/32sp, BN: system 18sp/38sp
- [ ] Read count increments after 5s dwell
- [ ] Discover sections populated from API
- [ ] Atlas Search works for English queries
- [ ] Atlas Search works for Bengali queries
- [ ] Profile screen: cover, avatar, stats, tabs render correctly
- [ ] All touch targets minimum 48×48dp
- [ ] Bengali text never uses Playfair or DM Sans

---

# PHASE 2 — Social Layer: Likes, Comments, Follows, Stories & Thoughts

**V1.0 Tier — Do not start until Phase 1 is live with real users.**

All backend logic (Follow, Like, Comment, Stories, Thoughts, Notifications) is identical to v3.

**Flutter-specific UI notes:**

- **Likes (optimistic):** Use Riverpod's `AsyncValue` + local state mutation before API resolves. `flutter_animate` `.scale()` fires immediately.
- **CommentSheet:** `showModalBottomSheet` with `isScrollControlled: true`, `DraggableScrollableSheet` inside.
- **ThoughtComposerSheet:** `showModalBottomSheet` with `TextField` + `SegmentedButton` for visibility.
- **ContentTypePicker:** `showModalBottomSheet` with `ListTile` rows for poem/story/thought/add-part options.
- **Notifications screen:** `ListView.builder` with `Dismissible` for mark-read swipe.

---

# PHASE 3 — Collaborative Poems, Duels, Audio/Video & Video Feed

All backend logic identical to v3. Flutter-specific notes:

**Pusher (collab):**
```dart
// lib/core/network/pusher_client.dart
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

final pusher = PusherChannelsFlutter.getInstance();
await pusher.init(apiKey: const String.fromEnvironment('PUSHER_KEY'), cluster: 'ap2');
await pusher.connect();

// Subscribe to collab channel
final channel = await pusher.subscribe(channelName: 'collab-$collabId');
channel.bind('stanza_added', (event) {
  // Update stanza list via Riverpod state notifier
});
```

**Socket.io (DMs):**
```dart
// lib/core/network/socket_client.dart
import 'package:socket_io_client/socket_io_client.dart' as io;

final socket = io.io(apiUrl, io.OptionBuilder()
  .setTransports(['websocket'])
  .disableAutoConnect()
  .setExtraHeaders({'Authorization': 'Bearer $accessToken'})
  .build());

socket.connect();
socket.on('new_message', (data) { /* update message list via Riverpod */ });
socket.on('user_typing', (data) { /* show typing indicator */ });
```

**Video Feed:**
```dart
// lib/features/video/screens/video_feed_screen.dart
// PageView.builder(scrollDirection: Axis.vertical, controller: PageController())
// Each page: Stack [
//   VideoPlayer (full screen, BoxFit.cover)
//   Gradient overlays (top + bottom)
//   Top bar (back + For You/Following toggle)
//   Right action column (avatar, like, comment, save, share)
//   Bottom poem info
//   GestureDetector (tap centre = toggle play/pause)
// ]
// Preload pages at currentIndex+1 and currentIndex+2
// video_player package: VideoPlayerController.networkUrl()
```

**Audio player:**
```dart
// just_audio package: AudioPlayer()
// Inline card with play/pause IconButton + SliderTheme progress bar
```

---

# PHASE 4 — Direct Messaging (Socket.io)

Backend identical to v3. Flutter implementation:

- `socket_io_client` handles all real-time events
- Riverpod `@riverpod` `AsyncNotifier` for message list — see skill.md Phase 4 for full implementation
- Messages screen: `ListView.builder` reversed (newest at bottom)
- Own messages: right-aligned, Primary bg
- Other messages: left-aligned, Surface bg, 16dp corners

---

# PHASE 5 — Rate Limiting, Security & Performance

Backend identical to v3 (Upstash, helmet, CORS, sanitize-html).

**Flutter performance:**
- Use `ListView.builder` / `SliverList` — never `Column` with `.map()` for long lists
- `cached_network_image` with `BlurHashDecoder` on all remote images
- `const` constructors on all stateless widgets
- Avoid `setState` on large trees — use Riverpod scoped providers
- `RepaintBoundary` around heavy animated widgets (video feed, like button)

---

# PHASE 6 — Audio/Video Polish & Dedicated Video Feed

**V2.0 tier · Build after Phase 5.**

- Audio upload: `POST /api/poems/:id/audio` → Cloudinary `resource_type: "video"` → `poem.audioUrl`
- Video upload: `POST /api/poems/:id/video` → Cloudinary `resource_type: "video"`, eager MP4 auto-quality → `poem.videoUrl`
- Flutter `AudioPlayerCard`: `just_audio` inline in poem reader — SurfaceVariant card, play/pause/scrub
- Video Feed polish: "For You" / "Following" toggle providers; `RepaintBoundary` on each `VideoFeedItem`; `AppLifecycleListener` pauses all controllers when app backgrounds; dispose controllers outside ±2 of current page
- See `skill.md` Phase 6 for complete Dart code

---

# PHASE 7 — Push Notifications & Weekly Digest

**V2.0 tier · Build after Phase 6.**

- `FCMHandler` (see `skill.md` Phase 7): foreground banners via `flutter_local_notifications`, tap routing via `navigatorKey`, `onMessageOpenedApp` and `getInitialMessage` for background/terminated states
- Notification Centre: pull-to-refresh, mark-all-read, unread dot per item, tap → `context.go('/poem/:id')` etc.
- Weekly digest cron: Monday 9AM UTC, batch 100 users, `sendWeeklyDigest` via Brevo
- Prompt rotation cron: Sunday 8AM UTC, deactivate current, activate next, FCM push to opted-in users
- See `skill.md` Phase 7 for complete Dart + TypeScript code

---

# PHASE 8 — Direct Messaging — Production Polish

**V2.0 tier · Build after Phase 7. Phase 4 scaffolded DMs; this phase hardens them.**

- Socket auto-reconnect on network resume via `connectivity_plus`
- Message pagination: scroll-to-top loads older messages via `GET /api/conversations/:id/messages?before=cursor`
- `ListView.builder(reverse: true)` — newest message always at bottom
- Read receipts: `socket.emit('mark_read', conversationId)` on screen dispose
- See `skill.md` Phase 8 for complete Dart code

---

# PHASE 9 — QA, Performance & Pre-Launch Hardening

**V3.0 tier · Run after all V2.0 features are stable.**

**Performance targets:**
- Feed cold start < 2s on 4G throttle; scroll ≥ 60fps; video page-turn < 300ms first frame
- No layout shift — blurhash on every remote image

**Security audit checklist:**

Flutter / client secrets:
- [ ] Zero hardcoded API URLs, keys, or DSNs in Dart source — `grep -r "https://api\|phc_\|sentry.io"` confirms
- [ ] All build-time config uses `String.fromEnvironment()` — no `flutter_dotenv`, no hardcoded strings
- [ ] No `.env` file in Flutter project root — `flutter_dotenv` not used
- [ ] `run.sh` (local dart-define script) in `.gitignore` — confirmed via `git log`
- [ ] JWT tokens stored only in `flutter_secure_storage` — no `SharedPreferences`, no Hive
- [ ] `AndroidOptions(encryptedSharedPreferences: true)` set
- [ ] `SecureStorage.deleteAll()` called on logout — confirmed
- [ ] No backend secrets (`JWT_SECRET`, `MONGODB_URI`, `CLOUDINARY_API_SECRET`) anywhere in Flutter code

Backend secrets:
- [ ] JWT secrets are 64-byte hex (not placeholder strings)
- [ ] CORS locked to `https://verso.app` only
- [ ] All user text sanitized via `sanitize-html` before MongoDB save
- [ ] No raw refresh tokens in DB — SHA-256 hash only
- [ ] No `passwordHash`/`otpCode`/`refreshTokens` fields in any API response
- [ ] Rate limits all enforced; OTP lockout after 5 attempts
- [ ] Password reset revokes all sessions
- [ ] No `.env` committed — confirmed via `git log`

**Accessibility checklist:**
- [ ] All touch targets ≥ 48×48 dp
- [ ] Every interactive element has `Semantics(label: ...)`
- [ ] Bengali text: zero `Playfair`/`DM Sans` `fontFamily` — confirmed via `grep`
- [ ] Large text scale (2×) does not break layouts; `MediaQuery.textScalerOf(context)` used
- [ ] `MediaQuery.of(context).disableAnimations` respected (reduced motion)

**Full regression paths:**
- Register → OTP → Onboarding → Poem → Feed → Like → Comment → Follow → DM
- Story create → Story Part → Notifications → Video Feed → Audio Player
- `flutter analyze` zero issues; zero console errors in release build

---

# PHASE 10 — Play Store Launch

## Step 10.1 — GitHub Actions Build (AAB for Play Store)

`.github/workflows/build-android.yml`:
```yaml
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
      - uses: subosito/flutter-action@v2
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

> Use `appbundle` (AAB) for Play Store. Use `apk` only for direct-install test builds.

## Step 10.2 — Play Store Metadata

```
App name:    Verso
Short desc:  Write. Read. Feel.
Description: Mood-based poetry discovery, bilingual (EN + বাংলা), serialized stories,
             collaborative poems, video recitations, community
Category:    Books & Reference
```

## Step 10.3 — Launch Checklist

- [ ] All backend `.env` variables set in Render production
- [ ] JWT secrets are strong 64-byte hex values (not placeholders)
- [ ] MongoDB Atlas Search indexes verified with EN + Bengali test queries
- [ ] All MongoDB compound indexes active
- [ ] Cloudinary production folder structure active (poems/, recitations/, videos/, stories/)
- [ ] Upstash Redis production instance active
- [ ] Brevo sender domain verified (SPF + DKIM)
- [ ] Cloudflare proxy active with caching rules on `/api/feed`
- [ ] Render keep-alive cron confirmed working
- [ ] Sentry + PostHog connected and receiving production events
- [ ] App icon (512×512 PNG) and feature graphic (1024×500 PNG) ready
- [ ] Splash screen configured (no flicker)
- [ ] App signing keystore stored securely — NOT in Git
- [ ] Deep links tested: `/poem/:id`, `/story/:id`, `/user/:username`
- [ ] FCM push notifications tested on physical Android device (production FCM)
- [ ] Bengali rendering tested on physical Android device (non-Google ROM)
- [ ] OTP email tested on Gmail on Android
- [ ] Full flow: Register → OTP → Onboarding → Publish poem → Feed
- [ ] Rate limit test: publish 11 poems → 11th gets poetic 429
- [ ] GitHub Actions AAB build passes on main push
- [ ] AAB uploaded to Play Console internal test track and tested
- [ ] **No Firebase Auth references anywhere in codebase**
- [ ] **No Firebase Firestore references anywhere in codebase**
- [ ] **No Supabase references anywhere in codebase**
- [ ] **No Clerk references anywhere in codebase**
- [ ] `firebase_messaging` used ONLY for FCM token — confirmed via `grep`
- [ ] All crons running: trending (hourly), digest (Mon 9AM), prompt (Sun 8AM), keep-alive (every 14 min)
- [ ] `GET /health` returns 200 from production URL
- [ ] Socket.io DMs tested on two physical Android devices simultaneously
- [ ] Privacy policy URL added to Play Console listing
- [ ] Content rating questionnaire completed

---

# PHASE 11 — AI Writing Assistant [POST-V1.0 · Future]

**Do not build until V1.0 ships and users actively request writing help.**

Backend: `npm install @anthropic-ai/sdk` → `src/services/aiWriting.service.ts`
- `POST /api/ai/suggest-line` — last 2 lines → Claude → next line suggestion
- `POST /api/ai/suggest-title` — poem content → 3 title options
- `POST /api/ai/suggest-direction` — story so far → next chapter direction
- Rate limit: 5 AI calls per poem/day/user via Upstash
- PostHog feature flag: `"ai-writing-assist"` — roll out gradually

Flutter UI additions:
- `✦` `IconButton` in poem editor toolbar (hidden behind PostHog feature flag)
- Ghost text suggestion displayed below cursor as greyed-out italic overlay
- Tap ghost text → inserts at cursor position in `TextEditingController`
- Swipe suggestion left → dismiss and request another

---

# Poetic Copy Reference

Use this throughout the app for every empty state, snackbar, and notification. Never use generic system language.

| Context | Copy |
|---|---|
| Empty feed (no follows) | *"The feed is quiet. Perhaps it's time to write."* |
| No poems found (search) | *"No poems found. The silence holds its own poetry."* |
| No stories found (search) | *"No stories found. Every great story begins with a single line."* |
| Empty drafts | *"Your drafts are waiting. Pick up where you left off."* |
| No thoughts (profile) | *"Some thoughts are still finding their words."* |
| Poem published | *"Your words are now part of the world."* |
| Story created | *"Your story has a beginning. Now write what comes next."* |
| Story part published | *"Another chapter. The story deepens."* |
| Thought posted (public) | *"Your thought is out in the world."* |
| Thought posted (mutual) | *"Your thought is with your circle."* |
| Thought posted (private) | *"Your thought is safe with you."* |
| Story followed | *"You'll know when the next chapter arrives."* |
| Story unfollowed | *"You've closed this book for now."* |
| New follower notification | *"A new reader has found their way to your words."* |
| Poem liked notification | *"Someone paused on your poem tonight."* |
| Story part liked | *"A reader stopped at your chapter."* |
| Thought reacted | *"Your thought touched someone."* |
| Comment (poem) | *"Someone added a voice to your poem."* |
| Comment (story) | *"A reader left a note in the margins of your chapter."* |
| New story part | *"A new chapter has arrived. The story continues."* |
| Story collab invite | *"You've been invited to write part of a story."* |
| Stanza added | *"Someone left a line for your poem."* |
| Duel invite | *"A poet has challenged you to a duel."* |
| Duel result | *"The readers have spoken. See how your poem fared."* |
| Rate limit (poem) | *"The words are coming too fast. Rest for a moment, then try again."* |
| Rate limit (thought) | *"Your thoughts need space between them. Try again soon."* |
| Rate limit (story part) | *"A story unfolds slowly. Rest before the next chapter."* |
| 429 error (general) | *"Easy. Even poems need space between lines."* |
| Draft saved | *"Saved"* ← keep this simple |
| No notifications | *"The night is quiet. No one has knocked yet."* |
| Empty DMs | *"No conversations yet. Send your first word."* |
| Profile bio empty | *"A poet without a bio is still a poet."* |
| Zero reads on a poem | *"Your words are still finding their way."* |
| Empty video feed | *"No recitations yet. Your voice could be the first."* |
| OTP email subject | *"Your Verso verification code"* |
| Welcome email subject | *"Your first page is blank."* |
| Weekly digest subject | *"This week's poems are waiting for you."* |
| Password reset subject | *"Reset your Verso password"* |
| Sign up CTA | *"Begin your story"* |
| Sign in CTA | *"Return to your page"* |
| OTP screen headline | *"Check your email"* |
| Username onboarding | *"Choose your pen name"* |
| Mood onboarding | *"What moves you?"* |
| Language onboarding | *"What language do you write in?"* |
| Finish onboarding | *"Take me to my feed"* |

---

## Screen Route Reference

| Screen | Route | Phase |
|---|---|---|
| Welcome | /auth/welcome | 0 |
| Sign Up | /auth/sign-up | 0 |
| Verify OTP | /auth/verify-otp | 0 |
| Sign In | /auth/sign-in | 0 |
| Forgot Password | /auth/forgot-password | 0 |
| Onboarding — Username | /auth/onboarding/username | 0 |
| Onboarding — Moods | /auth/onboarding/moods | 0 |
| Onboarding — Language | /auth/onboarding/language | 0 |
| Feed | /feed | 1 |
| Poem Reader | /poem/:id | 1 |
| Poem Editor | /write | 1 |
| Discover | /discover | 1 |
| Search | /discover/search | 1 |
| Own Profile | /profile | 1 |
| Other Profile | /user/:username | 2 |
| Notifications | /notifications | 2 |
| Story Creator | /write/story | 2 |
| Story Reader | /story/:id | 2 |
| Story Part | /story/:id/part/:partId | 2 |
| Duel | /duel/:id | 3 |
| Collab Poem | /collab/:id | 3 |
| Video Feed | /video-feed | 3 |
| Messages List | /messages | 4 |
| Message Thread | /messages/:conversationId | 4 |

---

*Every line of code is a line of verse.*
*Verso — where words find their world.*
