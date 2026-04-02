import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required for FCM)
  // ⚠️ Requires google-services.json in android/app/
  await Firebase.initializeApp();

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
