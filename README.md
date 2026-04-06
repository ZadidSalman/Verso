# Verso

Verso is a Flutter + Node.js poetry social app.

This repository contains two main projects:

- `verso/` - Flutter Android app (Riverpod, go_router, Dio, Firebase Messaging)
- `verso-api/` - Node.js + Express backend (TypeScript, MongoDB)

## Repository layout

```text
.
├── docs/                  # Product/design/build documentation
├── verso/                 # Flutter application
├── verso-api/             # Express API server
└── .github/workflows/     # Android CI build workflows
```

## Quick start

### 1) Backend

```bash
cd verso-api
npm install
npm run build
npm run start
```

### 2) Flutter app

```bash
cd verso
flutter pub get
flutter run \
  --dart-define=API_URL=https://verso-zjri.onrender.com \
  --dart-define=PUSHER_KEY=your_key \
  --dart-define=PUSHER_CLUSTER=ap2 \
  --dart-define=SENTRY_DSN=your_dsn \
  --dart-define=POSTHOG_KEY=your_key
```

## CI workflows

- `Build Android Release (APK)` on push to `main`

Firebase Android config in CI is provided via repository secret:

- `ANDROID_GOOGLE_SERVICES_JSON_B64` (base64 of `google-services.json`)

## Environment Variables

Required for building:

| Variable | Description | Example |
|----------|-------------|---------|
| `API_URL` | Backend API base URL | `https://verso-zjri.onrender.com` |
| `PUSHER_KEY` | Pusher Channels app key | From Pusher dashboard |
| `PUSHER_CLUSTER` | Pusher cluster | `ap2` |
| `SENTRY_DSN` | Sentry error tracking DSN | From Sentry project |
| `POSTHOG_KEY` | PostHog analytics API key | From PostHog project |

## Build APK locally

```bash
cd verso
flutter build apk --release \
  --dart-define=API_URL=https://verso-zjri.onrender.com \
  --dart-define=PUSHER_KEY=your_key \
  --dart-define=PUSHER_CLUSTER=ap2 \
  --dart-define=SENTRY_DSN=your_dsn \
  --dart-define=POSTHOG_KEY=your_key
```

## Notes

- Do not commit `google-services.json` to git.
- Set required GitHub Actions secrets before running builds.

## Firebase CI secret setup

Use this once to generate and validate `ANDROID_GOOGLE_SERVICES_JSON_B64`:

```bash
base64 -w 0 verso/android/app/google-services.json > /tmp/google-services.b64
python3 - <<'PY'
import base64, json
s = open('/tmp/google-services.b64').read().strip()
json.loads(base64.b64decode(s).decode())
print('VALID')
PY
```

If CI fails with `MalformedJsonException` or `base64: invalid input`, regenerate this value and update the repository secret.
