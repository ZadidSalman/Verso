# Verso — Knowledge Base (Flutter Edition)
> Static reference facts: schemas, indexes, API routes, business rules, Flutter patterns, poetic copy.
> This file changes infrequently — only when a schema is added or a decision is revised.

---

## Flutter Tech Stack Reference — 2026 Stable Versions

> **Flutter SDK: 3.32.x** — always use stable channel (`flutter channel stable`)
>
> Legend: **PINNED** = exact version required. **LATEST** = always install latest stable.

| Layer | Package | Version | Pin? | Notes |
|---|---|---|---|---|
| Routing | go_router | latest stable | LATEST | Always pass IDs in path params — never in `extra` for deep links |
| State | flutter_riverpod | **^3.3.1** | **PINNED** | Riverpod 3.x — `StateNotifierProvider` removed, use `@riverpod` annotations |
| State codegen | riverpod_annotation | **^3.3.1** | **PINNED** | Runtime — must match flutter_riverpod major |
| State codegen (dev) | riverpod_generator | **^3.3.1** | **PINNED** | Dev only — must match flutter_riverpod major |
| HTTP | dio | **^5.9.2** | **PINNED** | QueuedInterceptor for JWT refresh |
| Token storage | flutter_secure_storage | latest stable | LATEST | `encryptedSharedPreferences: true` on Android |
| Local cache | hive_ce | latest stable | LATEST | Feed filters, onboarding state, drafts cache |
| Local cache (Flutter) | hive_ce_flutter | latest stable | LATEST | Required alongside hive_ce for Flutter platform init |
| Fonts | google_fonts | latest stable | LATEST | Playfair Display + DM Sans |
| Images | cached_network_image | latest stable | LATEST | Always use with blurhash_dart placeholder |
| Blurhash | blurhash_dart | latest stable | LATEST | Image placeholder — used with cached_network_image |
| Video | video_player | latest stable | LATEST | Full-screen feed |
| Audio | just_audio | latest stable | LATEST | Inline poem player |
| Real-time DMs | socket_io_client | **^3.1.4** | **PINNED** | Protocol v4 lock — backend MUST use socket.io@^4 |
| Real-time Collab | pusher_channels_flutter | latest stable | LATEST | Subscribe per collab/duel channel |
| Push (core) | firebase_core | **^4.3.0** | **PINNED** | FlutterFire BoM 2026 — paired with messaging |
| Push (token) | firebase_messaging | **^15.0.0** | **PINNED** | FCM token ONLY — no Firestore, no Auth |
| Local notifications | flutter_local_notifications | latest stable | LATEST | Display incoming FCM messages |
| Image picker | image_picker | latest stable | LATEST | Profile photos, cover images |
| File picker | file_picker | latest stable | LATEST | Audio/video upload |
| Animations | flutter_animate | latest stable | LATEST | Like heart, shimmer, transitions |
| Error monitoring | sentry_flutter | latest stable | LATEST | |
| Analytics | posthog_flutter | latest stable | LATEST | Feature flags for AI writing assist |
| Network | connectivity_plus | latest stable | LATEST | Socket auto-reconnect on network resume |
| Build/CI | GitHub Actions ubuntu-latest | — | — | `subosito/flutter-action@v3`, `channel: stable` |

> **⚠️ CRITICAL COMPATIBILITY PAIRS — never upgrade one side without the other:**
>
> **Firebase BoM pair:** `firebase_core ^4.3.0` ↔ `firebase_messaging ^15.0.0`
> These are on different major versions by design — do NOT try to "match" them.
> Always verify at: pub.dev/packages/firebase_messaging → FlutterFire compatibility matrix.
>
> **Socket.io pair:** `socket_io_client ^3.1.4` ↔ `npm socket.io@^4` on backend
> Protocol v4 — upgrading to socket_io_client 4.x+ requires migrating backend to socket.io v5+.
> Mismatch causes silent connection failure with no error thrown.
>
> **Riverpod 3.x migration note:**
> `StateNotifierProvider` removed → use `@riverpod class MyNotifier extends _$MyNotifier`
> `StateNotifier` class gone → use `Notifier` / `AsyncNotifier`
> `ChangeNotifierProvider` removed → use `@riverpod` with `Notifier`
> Run `dart pub global activate riverpod_cli && riverpod migrate` to automate migration.

---

## MongoDB Collections — Full Schemas

### `users`
Fields NEVER returned in API responses: `passwordHash`, `otpCode`, `otpExpiry`, `otpAttempts`, `refreshTokens`

```json
{
  "_id": "ObjectId",
  "email": "string (unique, lowercase, indexed)",
  "passwordHash": "string (bcrypt 12 rounds)",
  "emailVerified": "boolean (default: false)",
  "otpCode": "string | null (bcrypt hash of 6-digit code)",
  "otpExpiry": "Date | null (10 minutes from issue)",
  "otpAttempts": "number (max 5 before lockout)",
  "refreshTokens": [{ "tokenHash": "string (SHA-256)", "expiresAt": "Date", "deviceInfo": "string", "createdAt": "Date" }],
  "username": "string (unique, lowercase)",
  "displayName": "string",
  "bio": "string",
  "avatarUrl": "string (Cloudinary)",
  "coverPhotoUrl": "string (Cloudinary)",
  "followersCount": "number", "followingCount": "number",
  "poemsCount": "number", "storiesCount": "number", "thoughtsCount": "number",
  "totalReads": "number", "totalLikes": "number",
  "isVerifiedPoet": "boolean",
  "preferredMoods": ["string"],
  "preferredLanguage": "en | bn | both",
  "hasCompletedOnboarding": "boolean",
  "fcmToken": "string (Firebase Cloud Messaging device token — from firebase_messaging Flutter package)",
  "emailPreferences": { "weeklyDigest": "boolean", "newFollower": "boolean", "duelResults": "boolean", "promptAlerts": "boolean" },
  "posthogDistinctId": "string",
  "joinedAt": "Date", "lastActiveAt": "Date"
}
```

> **`fcmToken` note:** Previously called `pushToken` (Expo). Now stores the FCM registration token
> obtained by `FirebaseMessaging.instance.getToken()` on the Flutter client. Backend sends pushes
> via FCM HTTP v1 API using `google-auth-library` for OAuth2. No Firebase Admin SDK required.

### `poems`
```json
{
  "_id": "ObjectId", "authorId": "ObjectId (ref: users)",
  "title": "string", "content": "string (raw text, line breaks preserved — plain text NOT rich JSON)",
  "slug": "string (unique, auto-generated: lowercase-title-last6ofId)",
  "language": "en | bn", "mood": ["string"], "tags": ["string"],
  "category": "string", "genre": "string",
  "isAnonymous": "boolean", "isUnsent": "boolean", "unsentTo": "string",
  "promptId": "ObjectId | null",
  "status": "draft | published | archived",
  "audioUrl": "string (Cloudinary)", "videoUrl": "string (Cloudinary)", "coverImageUrl": "string (Cloudinary)",
  "likesCount": "number", "commentsCount": "number", "savesCount": "number", "readsCount": "number",
  "trendingScore": "number",
  "wordCount": "number (auto-computed)", "lineCount": "number (auto-computed)",
  "publishedAt": "Date (set when status first becomes published)",
  "createdAt": "Date", "updatedAt": "Date"
}
```

### `drafts`
```json
{ "_id": "ObjectId", "authorId": "ObjectId", "title": "string", "content": "string", "language": "en | bn", "mood": ["string"], "tags": ["string"], "updatedAt": "Date" }
```

> Real-time: Pusher event `stanza_added` on channel `collab-{id}` when stanza submitted.

### `stories`
```json
{
  "_id": "ObjectId", "authorId": "ObjectId",
  "title": "string", "description": "string (max 500 chars)", "coverImageUrl": "string",
  "language": "en | bn", "mood": ["string"], "tags": ["string"], "genre": "string",
  "isCollab": "boolean",
  "collabMode": "invite-only | open",
  "storyMode": "linear | branching",
  "collabContributorIds": ["ObjectId"],
  "status": "ongoing | completed | abandoned",
  "partsCount": "number", "followersCount": "number", "totalReads": "number", "trendingScore": "number",
  "publishedAt": "Date", "lastPartAt": "Date",
  "createdAt": "Date", "updatedAt": "Date"
}
```
> `storyMode: "linear"` → parts are sequential (Part 1 → Part 2 → Part 3).
> `storyMode: "branching"` → a part can have multiple child parts, creating fork paths through the story.
> `collabMode` controls **who can contribute**: `"open"` = any user; `"invite-only"` = author-invited contributors only.
> Both `storyMode` values work with both `collabMode` values independently.

### `storyParts`
```json
{
  "_id": "ObjectId", "storyId": "ObjectId", "authorId": "ObjectId",
  "partNumber": "number (1-based)", "title": "string", "content": "string (raw text)",
  "coverImageUrl": "string (optional)", "language": "en | bn",
  "parentPartId": "ObjectId | null (null for root part; set for branching child parts)",
  "branchLabel": "string (optional — shown in branch navigator, e.g. 'The dark path')",
  "status": "draft | published", "isCollabContribution": "boolean",
  "likesCount": "number", "commentsCount": "number", "readsCount": "number",
  "publishedAt": "Date", "createdAt": "Date", "updatedAt": "Date"
}
```
> `parentPartId: null` = root/sequential part. `parentPartId: <id>` = branch child — only used when `story.storyMode === "branching"`.
> For linear stories, `parentPartId` is always null.

On storyPart publish: increment story.partsCount, update story.lastPartAt, notify all storyFollows, create feed item contentType:"story_update".

### `thoughts`
```json
{ "_id": "ObjectId", "authorId": "ObjectId", "content": "string (max 280 chars)", "visibility": "public | private | mutual", "mood": "string (optional)", "reactionsCount": "number", "createdAt": "Date" }
```

Visibility enforcement (NEVER bypass):
- `private` → author only, never returned to anyone else
- `mutual` → users where isMutual===true with author
- `public` → everyone

### `follows`
```json
{ "_id": "ObjectId", "followerId": "ObjectId", "followingId": "ObjectId", "isMutual": "boolean", "createdAt": "Date" }
```
Compound unique index: { followerId, followingId }

isMutual logic: A follows B → check if B→A exists → if yes set isMutual:true on both. A unfollows B → delete A→B, set isMutual:false on B→A.

### `likes`
```json
{ "_id": "ObjectId", "userId": "ObjectId", "targetId": "ObjectId", "targetType": "poem | storyPart | thought", "createdAt": "Date" }
```
Compound unique index: { userId, targetId, targetType }

### `comments`
```json
{ "_id": "ObjectId", "targetId": "ObjectId", "targetType": "poem | storyPart | thought", "authorId": "ObjectId", "parentCommentId": "ObjectId | null", "content": "string", "likesCount": "number", "createdAt": "Date" }
```

### `collaborativePoems`
```json
{
  "_id": "ObjectId", "title": "string", "language": "en | bn", "originatorId": "ObjectId",
  "collabType": "open | invite-only",
  "status": "open | closed",
  "stanzas": [{ "stanzaId": "ObjectId", "authorId": "ObjectId", "content": "string", "order": "number", "isApproved": "boolean", "createdAt": "Date" }],
  "contributorsCount": "number", "mood": ["string"], "createdAt": "Date"
}
```
> ⚠️ Collaborative poems are **always linear** — stanzas chain sequentially. There is no branching mode for poems. Branching is a Stories-only feature.
> `collabType: "open"` → any user can submit a stanza. `collabType: "invite-only"` → originator sends invites.

### `duels`
```json
{
  "_id": "ObjectId", "theme": "string",
  "challengerId": "ObjectId", "challengeeId": "ObjectId",
  "challengerPoemId": "ObjectId", "challengeePoemId": "ObjectId | null",
  "status": "pending | active | completed | declined",
  "votesForChallenger": "number", "votesForChallengee": "number", "voterIds": ["ObjectId"],
  "winnerId": "ObjectId | null", "endsAt": "Date (48h after acceptance)", "createdAt": "Date"
}
```

### `notifications`
```json
{
  "_id": "ObjectId", "recipientId": "ObjectId",
  "type": "new_follower | poem_liked | storyPart_liked | thought_reacted | comment | duel_invite | duel_result | stanza_added | new_story_part | story_collab_invite",
  "actorId": "ObjectId", "entityId": "ObjectId",
  "entityType": "poem | storyPart | story | duel | comment | thought | collab",
  "poeticMessage": "string", "isRead": "boolean", "createdAt": "Date"
}
```

### `conversations` + `messages`
```json
{ "_id": "ObjectId", "participantIds": ["ObjectId"], "conversationKey": "string (sorted userId1_userId2)", "lastMessage": "string", "lastMessageAt": "Date", "unreadCounts": { "<userId>": 0 }, "createdAt": "Date" }
{ "_id": "ObjectId", "conversationId": "ObjectId", "senderId": "ObjectId", "content": "string", "type": "text | poemShare | storyShare", "readBy": ["ObjectId"], "sentAt": "Date" }
```

### `storyFollows` / `prompts` / `emailLogs`
```json
{ "_id": "ObjectId", "userId": "ObjectId", "storyId": "ObjectId", "createdAt": "Date" }
{ "_id": "ObjectId", "title": "string", "description": "string", "language": "en | bn | both", "startsAt": "Date", "endsAt": "Date", "isActive": "boolean" }
{ "_id": "ObjectId", "userId": "ObjectId", "type": "otp | welcome | digest | duel_result | password_reset", "brevoMessageId": "string", "status": "sent | delivered | failed", "sentAt": "Date" }
```

---

## MongoDB Indexes (All Must Be Created Before Any Route)

```javascript
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ username: 1 }, { unique: true, sparse: true });
db.poems.createIndex({ trendingScore: -1 });
db.poems.createIndex({ publishedAt: -1 });
db.poems.createIndex({ authorId: 1, publishedAt: -1 });
db.poems.createIndex({ mood: 1, trendingScore: -1 });
db.poems.createIndex({ language: 1, trendingScore: -1 });
db.poems.createIndex({ status: 1, publishedAt: -1 });
db.poems.createIndex({ videoUrl: 1, trendingScore: -1 });
db.stories.createIndex({ trendingScore: -1 });
db.stories.createIndex({ authorId: 1, lastPartAt: -1 });
db.stories.createIndex({ lastPartAt: -1 });
db.stories.createIndex({ mood: 1, trendingScore: -1 });
db.storyParts.createIndex({ storyId: 1, partNumber: 1 });
db.storyParts.createIndex({ storyId: 1, publishedAt: -1 });
db.thoughts.createIndex({ authorId: 1, visibility: 1, createdAt: -1 });
db.follows.createIndex({ followerId: 1, followingId: 1 }, { unique: true });
db.follows.createIndex({ followingId: 1 });
db.follows.createIndex({ followerId: 1, isMutual: 1 });
db.likes.createIndex({ userId: 1, targetId: 1, targetType: 1 }, { unique: true });
db.comments.createIndex({ targetId: 1, targetType: 1, createdAt: -1 });
db.saves.createIndex({ userId: 1, poemId: 1 });
db.storyFollows.createIndex({ userId: 1, storyId: 1 }, { unique: true });
db.storyFollows.createIndex({ storyId: 1 });
db.conversations.createIndex({ conversationKey: 1 }, { unique: true });
db.conversations.createIndex({ participantIds: 1 });
db.messages.createIndex({ conversationId: 1, sentAt: -1 });
db.notifications.createIndex({ recipientId: 1, createdAt: -1 });
db.notifications.createIndex({ recipientId: 1, isRead: 1 });
db.drafts.createIndex({ authorId: 1, updatedAt: -1 });
```

---

## Atlas Search Index

CRITICAL: Use `lucene.standard` — NEVER `lucene.english` (it strips Bengali tokens).

Create on `poems` (name: `poems_search`) AND `stories` (name: `stories_search`):
```json
{ "mappings": { "dynamic": false, "fields": {
  "title":    { "type": "string", "analyzer": "lucene.standard" },
  "content":  { "type": "string", "analyzer": "lucene.standard" },
  "tags":     { "type": "string", "analyzer": "lucene.standard" },
  "mood":     { "type": "string" },
  "genre":    { "type": "string" },
  "language": { "type": "string" },
  "status":   { "type": "string" }
}}}
```

---

## API Routes Reference

### Auth `/api/auth`
| POST /register | POST /verify-otp | POST /login | POST /refresh | POST /logout | POST /forgot-password | POST /reset-password |

### Users `/api/users`
| GET /:username | PUT /me | PUT /me/onboarding | PUT /me/fcm-token | GET /check-username?u= | POST /:id/follow | DELETE /:id/follow | GET /:id/followers | GET /:id/following |

> `PUT /me/fcm-token` is new in Flutter edition — saves FCM token from `firebase_messaging`

### Poems `/api/poems`
| POST / | GET /:id | PUT /:id | DELETE /:id | POST /:id/publish | POST /:id/read | POST /:id/audio | POST /:id/video | GET /by/:username |

### Feed `/api/feed`
| GET / — ?page&limit&mood&language&type=all\|poems\|stories\|thoughts |

### Stories `/api/stories`
| POST / | GET /:id | PUT /:id | POST /:id/parts | GET /:id/parts/:partId | POST /:id/follow | DELETE /:id/follow | GET /trending |

### Thoughts `/api/thoughts`
| POST / | GET /feed | GET /user/:id (visibility filtered) | DELETE /:id |

### Engagement
| POST /api/likes — { targetId, targetType } |
| DELETE /api/likes/:targetId?targetType= |
| POST /api/comments | GET /api/comments/:targetId | DELETE /api/comments/:id |

### Collab + Duels
| POST /api/collab | GET /api/collab/:id | POST /api/collab/:id/stanzas |
| POST /api/duels | GET /api/duels/:id | POST /api/duels/:id/accept | POST /api/duels/:id/vote |

### Messaging `/api/conversations`
| GET / | POST / (find-or-create) | GET /:id/messages | PUT /:id/read |

### Notifications
| GET /api/notifications | PUT /api/notifications/read-all |

---

## Business Rules

**Trending Score Formula:**
```
score = (likesCount×3 + commentsCount×2 + readsCount×0.5 + savesCount×4)
        × Math.pow(0.95, ageInHours / 24)
```
Runs hourly on all published poems AND stories.

**Rate Limits (Upstash sliding window):**
| auth | 10/15min per IP | poems | 10/24h per user | thoughts | 20/24h per user |
| storyParts | 5/24h per user | comments | 50/1h per user | general | 200/1min per user |

**Feed pagination:** cursor-based on `publishedAt`. Returns `{ items, nextCursor, hasMore }`.

**Read count:** increment `readsCount` only after 5 seconds dwell time on poem reader.

**Brevo free tier:** 300 emails/day. Weekly digest must be batched in groups of 100 users.

**FCM Push:** Backend uses FCM HTTP v1 API (`https://fcm.googleapis.com/v1/projects/{id}/messages:send`)
with OAuth2 bearer token from `google-auth-library`. Token is `user.fcmToken` (stored after Flutter client registers).

---

## Flutter-Specific Coding Rules

**NEVER do these in Flutter:**
- ❌ `Column(children: items.map((i) => Widget()).toList())` for long dynamic lists — use `ListView.builder`
- ❌ `Image.network(url)` — always use `CachedNetworkImage`
- ❌ Hardcode hex colors in widgets — always use `AppColors.xxx`
- ❌ Set `fontFamily` on Bengali text — no fontFamily means system Noto Serif Bengali
- ❌ Use Firebase Auth, Firestore, or Realtime Database — `firebase_messaging` for FCM token ONLY
- ❌ Use `setState` for server data — use Riverpod providers
- ❌ Navigate using `Navigator.push` — always use `context.go()` or `context.push()` from go_router

**ALWAYS do these in Flutter:**
- ✅ `const` constructor on every stateless widget possible
- ✅ `RepaintBoundary` around heavy animated widgets
- ✅ `Semantics(label: ...)` on every interactive element
- ✅ Minimum `SizedBox(width: 48, height: 48)` around tap targets
- ✅ Use `MediaQuery.textScalerOf(context)` aware layouts for poem body — `textScaleFactor` is deprecated since Flutter 3.12, never use it
- ✅ `flutter_animate` for like heart, shimmer, and transitions
- ✅ Pass IDs in go_router path params (`/poem/:id`), never in `extra` for deep-linkable routes

---

## Screen Routes

| Screen | Route | Phase |
|---|---|---|
| Welcome | /auth/welcome | 0 |
| Sign Up | /auth/sign-up | 0 |
| Verify OTP | /auth/verify-otp | 0 |
| Sign In | /auth/sign-in | 0 |
| Forgot Password | /auth/forgot-password | 0 |
| Onboarding Username | /auth/onboarding/username | 0 |
| Onboarding Moods | /auth/onboarding/moods | 0 |
| Onboarding Language | /auth/onboarding/language | 0 |
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

## Key Screen Layout Specs

### Feed Screen
```
AppBar: SliverAppBar(floating: true, snap: true, pinned: false)
  Leading: quill-pen icon + "Verso" titleLarge primary
  Actions: [bell IconButton] [search IconButton] — 48dp touch targets

Filter Bar: SingleChildScrollView(scrollDirection: Axis.horizontal)
  FilterChip widgets: height 32, borderRadius 4
  Active: secondaryContainer bg, primary text
  Inactive: surfaceVariant bg, outlineVariant border

Body: ListView.builder (no FlashList — Flutter ListView is already optimized)

Bottom Nav: NavigationBar(height: 80) + FAB in centre slot
```

### Poem Editor
```
AppBar: back(saves draft) | "New Poem" | [SegmentedButton EN|BN] | [FilledButton Publish]
Title: TextField(style: Playfair 22sp, decoration: focusedBorder 2dp primary underline)
Body: Expanded TextField(maxLines: null, style: EN Playfair 18/32 | BN system 18/38)
  cursorColor: AppColors.primary
  cursorWidth: 2
  Cursor pulse: AnimationController 800ms repeat(reverse:true) → opacity
Toolbar: BottomAppBar or Padding above keyboard
  [Bold] [Italic] [Indent] [—] [Image]
```

### Poem Reader
```
extendBodyBehindAppBar: true
AppBar: transparent, back + share
Content: SingleChildScrollView padding: EdgeInsets.fromLTRB(24, 88, 24, 80)
  Title: headlineLarge Playfair
  Author: CircleAvatar(32) + displayName + timestamp
  Chips: horizontal SingleChildScrollView
  Body: EN AppTypography.englishPoem | BN AppTypography.banglaPoem
Sticky bottom: Positioned bottom-0 → _ReactionBar(64dp)
  [LikeButton N] [CommentButton N] [SaveButton] [ShareButton]
```

### Video Feed
```
Scaffold(backgroundColor: Colors.black, extendBodyBehindAppBar: true)
PageView.builder(scrollDirection: Axis.vertical)
Per page: Stack [
  VideoPlayer full screen BoxFit.cover
  Top gradient Container(h: 120) rgba(0,0,0,0.4)
  Bottom gradient Container(h: 220) rgba(0,0,0,0.7)
  SafeArea top bar: back + For You/Following ToggleButtons
  Right column (Positioned right: 16, bottom: 120): avatar + like + comment + save + share
  Bottom info (Positioned left: 16, bottom: 88): name + title + snippet + mood chip
  GestureDetector full screen: tap toggle play/pause
]
Preload index+1 and index+2
```

---

## Notification Poetic Messages

```dart
// lib/core/constants/copy.dart
const poeticMessages = {
  'poem_liked':          'Someone paused on your poem tonight.',
  'storyPart_liked':     'A reader stopped at your chapter.',
  'thought_reacted':     'Your thought touched someone.',
  'comment':             'Someone added a voice to your poem.',
  'comment_story':       'A reader left a note in the margins of your chapter.',
  'new_follower':        'A new reader has found their way to your words.',
  'duel_invite':         'A poet has challenged you to a duel.',
  'duel_result':         'The readers have spoken. See how your poem fared.',
  'stanza_added':        'Someone left a line for your poem.',
  'new_story_part':      'A new chapter has arrived. The story continues.',
  'story_collab_invite': 'You\'ve been invited to write part of a story.',
};
```

---

## Poetic Copy — Full Table

| Context | Copy |
|---|---|
| Empty feed | "The feed is quiet. Perhaps it's time to write." |
| No poems found | "No poems found. The silence holds its own poetry." |
| No stories found | "No stories found. Every great story begins with a single line." |
| Empty drafts | "Your drafts are waiting. Pick up where you left off." |
| No thoughts (profile) | "Some thoughts are still finding their words." |
| Profile bio empty | "A poet without a bio is still a poet." |
| Poem published | "Your words are now part of the world." |
| Story created | "Your story has a beginning. Now write what comes next." |
| Story part published | "Another chapter. The story deepens." |
| Thought (public) | "Your thought is out in the world." |
| Thought (mutual) | "Your thought is with your circle." |
| Thought (private) | "Your thought is safe with you." |
| Story followed | "You'll know when the next chapter arrives." |
| Story unfollowed | "You've closed this book for now." |
| Rate limit poems | "The words are coming too fast. Rest for a moment, then try again." |
| Rate limit thoughts | "Your thoughts need space between them. Try again soon." |
| Rate limit story parts | "A story unfolds slowly. Rest before the next chapter." |
| 429 general | "Easy. Even poems need space between lines." |
| Draft saved | "Saved" (keep this one simple) |
| No notifications | "The night is quiet. No one has knocked yet." |
| Empty DMs | "No conversations yet. Send your first word." |
| Zero reads | "Your words are still finding their way." |
| Empty video feed | "No recitations yet. Your voice could be the first." |
| OTP email subject | "Your Verso verification code" |
| Welcome email subject | "Your first page is blank." |
| Digest email subject | "This week's poems are waiting for you." |
| Password reset subject | "Reset your Verso password" |
| Sign up CTA | "Begin your story" |
| Sign in CTA | "Return to your page" |
| OTP headline | "Check your email" |
| Username onboarding | "Choose your pen name" |
| Mood onboarding | "What moves you?" |
| Language onboarding | "What language do you write in?" |
| Finish onboarding | "Take me to my feed" |

## Input Placeholders

```dart
// lib/core/constants/copy.dart
const placeholders = {
  'poemTitle':       'A title for your verse…',
  'poemBody':        'Begin here…',
  'storyTitle':      'Your story\'s first title…',
  'storyPartTitle':  'This chapter is called…',
  'thoughtComposer': 'A thought for the world…',
  'searchBar':       'Search poems, poets, moods…',
  'profileBio':      'Tell the world who you are…',
  'commentInput':    'Leave a word in the margins…',
  'dmInput':         'Say something…',
};
```

---

## Write FAB — ContentType Options

```dart
// showModalBottomSheet ContentTypePicker options:
// 1. ✍️ Write a Poem    → context.push('/write')
// 2. 📖 Start a Story   → context.push('/write/story')
// 3. 💭 Share a Thought → showModalBottomSheet(ThoughtComposerSheet)
// 4. ➕ Add a Story Part → only if user.activeStories.isNotEmpty
```

## Feed ContentType → Widget Map

| contentType | Flutter Widget |
|---|---|
| poem | PoemCard |
| thought | ThoughtCard |
| story_update | StoryUpdateCard |
| collab | CollabFeedCard |
| duel | DuelFeedCard |
