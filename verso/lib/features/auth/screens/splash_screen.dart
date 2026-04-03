import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

/// Splash screen - shown while checking auth status
///
/// Design: BG-02 background with sage glows
/// - Quill-pen logo (fade in)
/// - "Verso" display title
/// - Loading indicator
/// - "Preparing your ink..." text
///
/// Logic:
/// - Minimum 1.5 seconds display time
/// - Listens to auth state
/// - When resolved AND minimum time elapsed → navigate
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _minTimeElapsed = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startMinimumTimer();
  }

  void _startMinimumTimer() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _minTimeElapsed = true;
        });
        _checkAndNavigate();
      }
    });
  }

  void _checkAndNavigate() {
    if (_hasNavigated || !_minTimeElapsed) return;

    final authState = ref.read(authProvider);

    // Only navigate if auth state has resolved
    if (authState is AuthAuthenticated) {
      _hasNavigated = true;
      final user = authState.user;
      if (!user.hasCompletedOnboarding) {
        context.go(AppRoutes.onboardingUsername);
      } else {
        context.go(AppRoutes.feed);
      }
    } else if (authState is AuthUnauthenticated || authState is AuthError) {
      _hasNavigated = true;
      context.go(AppRoutes.welcome);
    }
    // If still AuthLoading or AuthInitial, wait for state change
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      _checkAndNavigate();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // BG-02 Overlay: Radial gradient top-right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.0,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Decorative sage circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 40,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.03),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Quill icon
                  Semantics(
                        label: 'Verso Logo',
                        child: Container(
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                      .animate(target: disableAnimations ? 1 : 0)
                      .fadeIn(
                        duration: AppDurations.emphasized,
                        curve: AppCurves.emphasized,
                      ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                        'Verso',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      )
                      .animate(
                        delay: disableAnimations ? 0.ms : 200.ms,
                        target: disableAnimations ? 1 : 0,
                      )
                      .fadeIn(
                        duration: AppDurations.emphasized,
                        curve: AppCurves.emphasized,
                      ),

                  const Spacer(flex: 2),

                  // Loading indicator
                  SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                      .animate(
                        delay: disableAnimations ? 0.ms : 400.ms,
                        target: disableAnimations ? 1 : 0,
                      )
                      .fadeIn(duration: AppDurations.standard),

                  const SizedBox(height: 16),

                  // Loading text
                  Text(
                        'Preparing your ink...',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant,
                        ),
                      )
                      .animate(
                        delay: disableAnimations ? 0.ms : 500.ms,
                        target: disableAnimations ? 1 : 0,
                      )
                      .fadeIn(duration: AppDurations.standard),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
