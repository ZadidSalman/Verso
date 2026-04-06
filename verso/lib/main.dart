import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sentry for crash reporting
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue: '',
      );
      options.tracesSampleRate = kDebugMode ? 1.0 : 0.2;
      options.profilesSampleRate = kDebugMode ? 1.0 : 0.2;
      options.environment = kDebugMode ? 'development' : 'production';
    },
  );

  // Initialize PostHog for analytics
  final posthogConfig = PostHogConfig(
    const String.fromEnvironment(
      'POSTHOG_KEY',
      defaultValue: '',
    ),
  );
  await PostHog().setup(posthogConfig);

  // Initialize Firebase with timeout (cold starts can be slow)
  try {
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        if (kDebugMode) {
          debugPrint('Firebase init timed out - continuing without FCM');
        }
        throw TimeoutException('Firebase init timed out');
      },
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase init failed: $e');
    }
    // App will work, but FCM won't be available
  }

  runApp(const ProviderScope(child: VersoApp()));
}

class VersoApp extends ConsumerStatefulWidget {
  const VersoApp({super.key});

  @override
  ConsumerState<VersoApp> createState() => _VersoAppState();
}

class _VersoAppState extends ConsumerState<VersoApp> {
  @override
  void initState() {
    super.initState();
    // Check auth status on app start
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Verso',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
