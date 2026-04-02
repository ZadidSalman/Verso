# AGENTS.md — Verso AI Coding Agent Instructions
### GitHub Codespaces · OpenCode · Flutter · Android

> **What this file is:** Your operating manual for every AI coding session.
> OpenCode reads this file automatically at the start of every session in GitHub Codespaces.
> Every rule here is absolute. Every phase must be completed in order.

---

## 🗂️ Project File Structure

Your repository must follow this layout exactly:

```
verso/                                  ← root of the repo
│
├── AGENTS.md                           ← this file — OpenCode reads it automatically
│
├── docs/                               ← ALL reference documents live here
│   ├── design.md                       ← UI/UX design system (Sage & Vellum)
│   ├── Verso_Master_Prompt_v4_Flutter.md  ← phase-by-phase build guide
│   ├── skill_flutter.md                ← step-by-step Dart/Flutter code patterns
│   ├── knowledge_flutter.md            ← schemas, API routes, business rules
│   └── gemini_flutter.md               ← additional AI assistant instructions
│
├── verso/                              ← Flutter app (created by flutter create)
│   ├── lib/
│   ├── android/
│   ├── pubspec.yaml
│   └── ...
│
├── verso-api/                          ← Node.js + Express backend
│   ├── src/
│   ├── package.json
│   └── ...
│
└── .github/
    └── workflows/
        ├── build-android.yml           ← APK/AAB build on push
        └── build-apk-debug.yml         ← debug APK on PR
```

---

## 📋 How to Use docs/ Files in Every Session

At the start of any coding session in OpenCode, feed files in this order:

```
1. AGENTS.md              (this file — already auto-loaded by OpenCode)
2. docs/knowledge_flutter.md    — schemas, routes, business rules
3. docs/design.md               — colours, components, animations
4. docs/skill_flutter.md        — current phase step-by-step code
5. docs/Verso_Master_Prompt_v4_Flutter.md  — current phase spec
```

**Then say:** `"Implement Phase X, Step Y as specified in the docs above."`

Never paste the entire master prompt at once — feed only the phase section you are working on.

---

## ⚙️ GitHub Codespaces Setup

### First-time environment setup

```bash
# 1. Install Flutter (stable)
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$PATH:$HOME/flutter/bin"
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc

# 2. Verify Flutter
flutter doctor

# 3. Install Node.js (for backend)
nvm install --lts
nvm use --lts

# 4. Install Android SDK (if not pre-installed in Codespace)
sudo apt-get install -y android-sdk
export ANDROID_HOME=/usr/lib/android-sdk
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"

# 5. Accept Android licenses
flutter doctor --android-licenses

# 6. Clone and enter repo
git clone https://github.com/YOUR_USERNAME/verso.git
cd verso
```

### Every session startup

```bash
cd verso                # repo root
flutter --version       # confirm stable 3.32.x
node --version          # confirm LTS
```

---

## 🚀 GitHub Actions Workflows

### Workflow 1 — Release AAB (builds on every push to `main`)

Create this file at `.github/workflows/build-android.yml`:

```yaml
name: Build Android Release (AAB)

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Flutter (stable)
        uses: subosito/flutter-action@v3
        with:
          channel: stable      # Always stable — never pin a specific version number
          cache: true

      - name: Get dependencies
        working-directory: verso
        run: flutter pub get

      - name: Run codegen
        working-directory: verso
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Build release AAB
        working-directory: verso
        run: |
          flutter build appbundle --release \
            --dart-define=API_URL=${{ secrets.API_URL }} \
            --dart-define=PUSHER_KEY=${{ secrets.PUSHER_KEY }} \
            --dart-define=PUSHER_CLUSTER=ap2 \
            --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }} \
            --dart-define=POSTHOG_KEY=${{ secrets.POSTHOG_KEY }}

      - name: Upload AAB artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-aab-${{ github.sha }}
          path: verso/build/app/outputs/bundle/release/app-release.aab
          retention-days: 30
```

### Workflow 2 — Debug APK (builds on every pull request)

Create this file at `.github/workflows/build-apk-debug.yml`:

```yaml
name: Build Android Debug (APK)

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  build-debug:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Flutter (stable)
        uses: subosito/flutter-action@v3
        with:
          channel: stable
          cache: true

      - name: Get dependencies
        working-directory: verso
        run: flutter pub get

      - name: Run codegen
        working-directory: verso
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Analyze code
        working-directory: verso
        run: flutter analyze

      - name: Build debug APK
        working-directory: verso
        run: flutter build apk --debug

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: debug-apk-${{ github.sha }}
          path: verso/build/app/outputs/flutter-apk/app-debug.apk
          retention-days: 7
```

### Required GitHub Secrets

Go to: **Repo → Settings → Secrets and variables → Actions → New repository secret**

| Secret name | Value |
|---|---|
| `API_URL` | `https://api.verso.app` (or Render URL during dev) |
| `PUSHER_KEY` | Your Pusher Channels app key |
| `PUSHER_CLUSTER` | `ap2` (or your cluster) |
| `SENTRY_DSN` | Your Sentry DSN URL |
| `POSTHOG_KEY` | Your PostHog project API key |

---

## 🔒 Absolute Rules — Never Violate

These apply in every single session, every single file:

```
COLOURS     → AppColors.xxx only. Never Color(0xFF...) or Colors.green in widgets.
TYPOGRAPHY  → Theme.of(context).textTheme.xxx or AppTypography.xxx only. No inline fontSize.
SPACING     → 4dp multiples only: 4, 8, 12, 16, 24, 32, 48. No arbitrary values.
SHAPES      → AppShapes.xs/sm/md/lg/xl/full/sheet. No inline BorderRadius.circular().
ANIMATIONS  → A01–A30 from design.md only. No unlisted animations. Always reduced-motion fallback.
LISTS       → ListView.builder for > 3 items. Never Column + .map().
IMAGES      → CachedNetworkImage + blurhash_dart. Never Image.network().
NAVIGATION  → context.go() / context.push() from go_router. Never Navigator.push().
STATE       → Riverpod @riverpod providers for server data. setState for local UI only.
FIREBASE    → firebase_messaging for FCM token ONLY. Never Firestore, Auth, or RTDB.
BENGALI     → Never set fontFamily on Bengali text. Omit it entirely.
COPY        → Poetic strings from knowledge_flutter.md. Never "Loading..." or "Error".
```

---

## 📦 Phase Map — Complete Build Order

**Rule: Complete every checkbox in a phase before starting the next phase.**
**Rule: Do not start Phase 2 until Phase 0 + Phase 1 are deployed and tested by real users.**

```
MVP     → Phase 0 + Phase 1
V1.0    → Phase 2 + Phase 3 + Phase 4 + Phase 5
V2.0    → Phase 6 + Phase 7 + Phase 8
V3.0    → Phase 9 + Phase 10
Future  → Phase 11
```

---

## PHASE 0 — Project Setup, Auth & Design Foundation

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Steps 0.1–0.14
> Reference: `docs/skill_flutter.md` → PHASE 0

**Goal:** Flutter project created, Riverpod wired, Dio configured, JWT auth working end-to-end, OTP email flowing, design tokens loaded, go_router set up, FCM token registered.

### Step-by-step:

- [ ] **0.1** — Create Flutter project
  ```bash
  flutter create verso --org app.verso --platforms android
  cd verso
  ```

- [ ] **0.2** — Install all dependencies (see `docs/skill_flutter.md` Step 0.2 for full pubspec.yaml with pinned versions)
  ```bash
  flutter pub get
  ```

- [ ] **0.3** — Initialise backend
  ```bash
  cd ../verso-api
  npm init -y
  npm install express mongoose cors helmet dotenv morgan compression
  npm install jsonwebtoken bcryptjs
  npm install nodemailer @sentry/node posthog-node
  npm install -D typescript ts-node @types/node @types/express nodemon
  ```

- [ ] **0.4** — Create Flutter folder structure (see `docs/Verso_Master_Prompt_v4_Flutter.md` Step 0.4)

- [ ] **0.5** — Create backend folder structure (see `docs/Verso_Master_Prompt_v4_Flutter.md` Step 0.5)

- [ ] **0.6** — Implement `AppColors`, `AppTypography`, `AppShapes`, `AppAnimations`, `AppTheme`
  (copy from `docs/design.md` Part 1 + Part 5)

- [ ] **0.7** — Implement JWT auth backend (register, login, refresh, OTP verify, password reset)

- [ ] **0.8** — Set up Express server with all middleware

- [ ] **0.9** — Configure `.env` for backend and `--dart-define` for Flutter

- [ ] **0.10** — Implement Flutter auth layer: `flutter_secure_storage` + Dio + `QueuedInterceptor` auto-refresh

- [ ] **0.11** — Configure `go_router` with auth guard (redirect unauthenticated → `/auth/welcome`)

- [ ] **0.12** — Register FCM token with backend on login

- [ ] **0.13** — Build OTP input widget (6-box, auto-advance, shake on error — animation A17)

- [ ] **0.14** — Phase 0 checklist: all items green before moving to Phase 1

---

## PHASE 1 — Poems, Feed, Discover, Profile (MVP)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Steps 1.1–1.6
> Reference: `docs/skill_flutter.md` → PHASE 1

**Goal:** Users can write, publish, and read poems. Feed with mood filters. Discover screen. Profile screen.

### Step-by-step:

- [ ] **1.1** — Poem model + backend CRUD (`POST /api/poems`, `GET /api/poems/:id`, `GET /api/feed`)

- [ ] **1.2** — Feed screen UI
  - PoemCard Variant A (with mood left border)
  - Mood filter chips (horizontal scroll)
  - Staggered list entrance (animation A19)
  - Pull-to-refresh quill animation (A07)
  - Skeleton loading (A03)

- [ ] **1.3** — Poem editor screen
  - Sage cursor pulse (A01)
  - Editor toolbar (bold, italic, indent, stanza break)
  - Mood picker bottom sheet
  - Language toggle (EN / BN)
  - Auto-save to Hive every 30s

- [ ] **1.4** — Poem reader screen
  - Poem body with correct font (Playfair EN / system BN)
  - Reaction bar (like with A02 heart burst)
  - Save/bookmark toggle (A29)

- [ ] **1.5** — Discover screen + Profile screen (own + other user)

- [ ] **1.6** — Phase 1 checklist: all items green → **deploy and get real user feedback before Phase 2**

---

## PHASE 2 — Social Layer (V1.0)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Phase 2
> Reference: `docs/skill_flutter.md` → PHASE 2

**⚠️ Do not start until Phase 0 + 1 are live with real users.**

**Goal:** Follows, likes, comments, notifications, stories, thoughts.

### Step-by-step:

- [ ] **2.1** — Follow / unfollow system (backend + Follow button morph animation A26)
- [ ] **2.2** — Likes + comments backend + UI
- [ ] **2.3** — Stories: create, add parts, reader (A21 prev/next navigation)
- [ ] **2.4** — Thoughts composer (A22 visibility picker: public / mutual / private)
- [ ] **2.5** — Notifications screen (A13 bell bounce)
- [ ] **2.6** — Notification list with staggered entrance (A19)
- [ ] **2.7** — Phase 2 checklist green

---

## PHASE 3 — Collab Poems, Duels, Audio, Video (V1.0)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Phase 3
> Reference: `docs/skill_flutter.md` → PHASE 3

**Goal:** Collaborative poems, duel voting, audio player, video feed scaffold.

### Step-by-step:

- [ ] **3.1** — Collaborative poem stanza chain (Pusher for live updates, A23 branch fork animation)
- [ ] **3.2** — Duels (challenge, submit, vote — A11 vote ripple, A12 live poll fill)
- [ ] **3.3** — Audio upload to Cloudinary + inline audio player (A28 waveform animation)
- [ ] **3.4** — Video upload to Cloudinary + full-screen video feed scaffold (A09 snap scroll)
- [ ] **3.5** — Phase 3 checklist green

---

## PHASE 4 — Direct Messaging (V1.0)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Phase 4
> Reference: `docs/skill_flutter.md` → PHASE 4

**Goal:** Real-time DMs via Socket.io. Conversation list. Message thread.

### Step-by-step:

- [ ] **4.1** — Socket.io server on Render (`socket.io@^4` — must match `socket_io_client ^3.1.4`)
- [ ] **4.2** — Messages List screen (Screen 23 in design.md)
- [ ] **4.3** — Message Thread screen (Screen 24) with bubbles, typing indicator, A24 send animation
- [ ] **4.4** — Poem share card in DMs
- [ ] **4.5** — Phase 4 checklist green

---

## PHASE 5 — Rate Limiting, Security & Performance (V1.0)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Phase 5

**Goal:** Upstash Redis rate limits, input sanitisation, MongoDB indexes, Cloudflare caching.

### Step-by-step:

- [ ] **5.1** — Upstash Redis rate limits on all publish endpoints (poetic 429 messages)
- [ ] **5.2** — Input sanitisation middleware on all POST/PUT routes
- [ ] **5.3** — MongoDB compound indexes verified and active
- [ ] **5.4** — Cloudflare caching rules on `/api/feed` and static assets
- [ ] **5.5** — Phase 5 checklist green → **V1.0 complete**

---

## PHASE 6 — Audio/Video Polish & Dedicated Video Feed (V2.0)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Phase 6
> Reference: `docs/skill_flutter.md` → PHASE 6

**Goal:** Full-screen video feed (TikTok-style). Audio waveform polish. BG-04 black background.

### Step-by-step:

- [ ] **6.1** — Full-screen video feed with vertical snap scroll (A09)
- [ ] **6.2** — Video overlay gradients (BG-04 from design.md Section 1.7)
- [ ] **6.3** — Audio waveform player polish (A28)
- [ ] **6.4** — Phase 6 checklist green

---

## PHASE 7 — Push Notifications & Weekly Digest (V2.0)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Phase 7
> Reference: `docs/skill_flutter.md` → PHASE 7

**Goal:** FCM push delivery via FCM HTTP v1. Local notifications. Weekly digest email via Brevo.

### Step-by-step:

- [ ] **7.1** — FCM HTTP v1 push delivery on backend (via `google-auth-library`, no Firebase Admin SDK)
- [ ] **7.2** — `FCMHandler` Flutter class (foreground banners, tap routing, background/terminated states)
- [ ] **7.3** — Weekly digest cron job via Brevo (Monday 9AM)
- [ ] **7.4** — Phase 7 checklist green

---

## PHASE 8 — Direct Messaging Production Polish (V2.0)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Phase 8
> Reference: `docs/skill_flutter.md` → PHASE 8

**Goal:** Socket auto-reconnect on network resume. Read receipts. Message pagination.

### Step-by-step:

- [ ] **8.1** — `connectivity_plus` auto-reconnect on network resume
- [ ] **8.2** — Read receipts (delivered / read ticks)
- [ ] **8.3** — Message list pagination (cursor-based)
- [ ] **8.4** — Phase 8 checklist green → **V2.0 complete**

---

## PHASE 9 — QA, Performance & Pre-Launch Hardening (V3.0)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Phase 9

**Goal:** Bengali rendering verified on physical device. Frame rate profiling. Sentry + PostHog confirmed.

### Step-by-step:

- [ ] **9.1** — Test Bengali rendering on physical Android device (non-Google ROM if possible)
- [ ] **9.2** — Flutter DevTools frame profiling — all screens ≥ 60fps
- [ ] **9.3** — Sentry receiving production crash events
- [ ] **9.4** — PostHog receiving production analytics events
- [ ] **9.5** — Full user flow test on physical device: Register → OTP → Onboard → Publish → Feed
- [ ] **9.6** — Rate limit test: publish 11 poems → 11th gets poetic 429 response
- [ ] **9.7** — DM test: two physical Android devices simultaneously
- [ ] **9.8** — Deep link test: `/poem/:id`, `/story/:id`, `/user/:username`
- [ ] **9.9** — Run anti-Firebase grep audit (see below)
- [ ] **9.10** — Phase 9 checklist green

---

## PHASE 10 — Play Store Launch (V3.0)

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Steps 10.1–10.3

**Goal:** AAB uploaded to Play Console. Internal test track. Public launch.

### Step-by-step:

- [ ] **10.1** — GitHub Actions AAB build passes on `main` push (workflow above)
- [ ] **10.2** — App signing keystore generated and stored securely (NOT in Git)
- [ ] **10.3** — Play Store listing: name, description, screenshots, icon, feature graphic
- [ ] **10.4** — Content rating questionnaire completed
- [ ] **10.5** — Privacy policy URL added to Play Console
- [ ] **10.6** — AAB uploaded to internal test track and tested
- [ ] **10.7** — All launch checklist items green (see `docs/Verso_Master_Prompt_v4_Flutter.md` Step 10.3)
- [ ] **10.8** — Submit for review → **V3.0 / Public Launch**

---

## PHASE 11 — AI Writing Assistant [POST-V1.0 · Future]

> Reference: `docs/Verso_Master_Prompt_v4_Flutter.md` → Phase 11

**⚠️ Do not build until V1.0 ships and users actively request writing help.**

- Backend: `npm install @anthropic-ai/sdk` → `POST /api/ai/suggest-line`, `suggest-title`, `suggest-direction`
- Rate limit: 5 AI calls per poem per day per user via Upstash
- Flutter: `✦` icon button in poem editor toolbar (hidden behind PostHog feature flag `"ai-writing-assist"`)
- Ghost text suggestion as greyed italic overlay below cursor
- Tap to insert, swipe left to dismiss and request another

---

## 🔍 Anti-Pattern Audit Commands

Run these before every commit. Zero results expected on all of them.

```bash
cd verso

# No hardcoded colours in widget files
grep -r "Color(0xFF" lib/
grep -r "Colors\." lib/ | grep -v "Colors.transparent\|Colors.black\|Colors.white"

# No inline font sizes
grep -r "fontSize:" lib/

# No Navigator.push
grep -r "Navigator.push" lib/

# No Image.network
grep -r "Image.network" lib/

# No setState for async data
grep -rn "setState.*await\|await.*setState" lib/

# No Firebase Auth/Firestore (firebase_messaging only)
grep -r "firebase_auth\|FirebaseAuth\|FirebaseFirestore\|FirebaseDatabase" lib/

# No Bengali fontFamily
grep -r "fontFamily.*Noto\|fontFamily.*system" lib/

# No Column + map for dynamic lists
grep -r "\.map(" lib/ | grep "Column\|children"
```

---

## 🗃️ Session Workflow — What to Say to OpenCode

### Starting a new phase

```
Read docs/knowledge_flutter.md, docs/design.md, and docs/skill_flutter.md.
Then implement Phase X, Step Y exactly as specified.
Follow all rules in AGENTS.md.
```

### Continuing a session

```
Continue from where we left off on Phase X, Step Y.
The checklist item we need to complete is: [item].
```

### Fixing a bug

```
This is the error: [paste error]
The file is: [path]
Fix it without changing any other behaviour.
Do not introduce any new packages.
```

### Asking for a component

```
Implement the [ComponentName] widget from docs/design.md Section 3.X.
Use only AppColors, AppTypography, AppShapes tokens.
Include animation [AXX] as specified.
Include the reduced-motion fallback.
```

---

## 📝 Design Identity Reminder

```
App name:        Verso
Design language: "Sage & Vellum"
Feel:            A beautiful literary journal — cream pages, sage ink, generous margins
Primary colour:  Deep sage-teal → AppColors.primary  (#1F6B5A)
Background:      Vellum white   → AppColors.surface   (#F6FAF8)
Type heroes:     Playfair Display (all poetry + titles) · DM Sans (all UI chrome)
Bengali text:    System font — NEVER set fontFamily
Motion:          Every animation communicates state. Nothing is decorative.
Copy:            Every string is poetic. If it sounds like a SaaS app, rewrite it.
Cost:            $0.00/month at launch. No credit card. No paid services.
```
