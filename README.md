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
- `Build Android Debug (APK)` on pull requests

Firebase Android config in CI is provided via repository secret:

- `ANDROID_GOOGLE_SERVICES_JSON_B64` (base64 of `google-services.json`)

## Notes

- Do not commit `google-services.json` to git.
- Set required GitHub Actions secrets before running release builds.
