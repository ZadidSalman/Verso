import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_animations.dart';
import '../../features/auth/providers/auth_provider.dart';

// Auth screens
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/verify_otp_screen.dart';
import '../../features/auth/screens/onboarding/onboarding_username_screen.dart';
import '../../features/auth/screens/onboarding/onboarding_moods_screen.dart';
import '../../features/auth/screens/onboarding/onboarding_language_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/poem/screens/poem_editor_screen.dart';
import '../../features/poem/screens/poem_reader_screen.dart';
import '../../features/discover/screens/discover_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/story/screens/story_editor_screen.dart';
import '../../features/story/screens/story_part_screen.dart';
import '../../features/poem/screens/collab_poem_screen.dart';
import '../../features/duel/screens/duel_screen.dart';
import '../../features/video/screens/video_feed_screen.dart';

/// Route paths
class AppRoutes {
  AppRoutes._();

  // Splash
  static const splash = '/';

  // Auth
  static const welcome = '/auth/welcome';
  static const signUp = '/auth/sign-up';
  static const signIn = '/auth/sign-in';
  static const verifyOtp = '/auth/verify-otp';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  // Onboarding
  static const onboardingUsername = '/auth/onboarding/username';
  static const onboardingMoods = '/auth/onboarding/moods';
  static const onboardingLanguage = '/auth/onboarding/language';

  // Main app
  static const feed = '/feed';
  static const discover = '/discover';
  static const profile = '/profile';
  static const notifications = '/notifications';
  static const messages = '/messages';

  // Content
  static const poem = '/poem/:id';
  static const story = '/story/:id';
  static const user = '/user/:username';
  static const poemEditor = '/editor/poem';
  static const collabPoem = '/collab/:id';
  static const duel = '/duel/:id';
  static const videoFeed = '/video-feed';
  static const storyEditor = '/write/story';
  static const storyPart = '/story/:storyId/part/:partId';
}

/// GoRouter provider with auth redirect
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Auth redirect logic
    redirect: (context, state) {
      final isSplashRoute = state.matchedLocation == AppRoutes.splash;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isOnboardingRoute = state.matchedLocation.contains('/onboarding');

      // NEVER redirect away from splash — let SplashScreen handle navigation
      if (isSplashRoute) {
        return null;
      }

      // If initial state and NOT on splash, go to splash (app startup only)
      if (authState is AuthInitial) {
        return AppRoutes.splash;
      }

      // If loading, only redirect to splash during initial app startup.
      // Don't redirect during login/signup/OTP operations — user should stay
      // on their current screen while the async operation completes.
      if (authState is AuthLoading) {
        if (isAuthRoute || isOnboardingRoute) {
          return null;
        }
        return AppRoutes.splash;
      }

      // If authenticated
      if (authState is AuthAuthenticated) {
        final user = authState.user;

        // If on auth route (except onboarding), redirect to onboarding or feed
        if (isAuthRoute && !isOnboardingRoute) {
          if (!user.hasCompletedOnboarding) {
            return AppRoutes.onboardingUsername;
          }
          return AppRoutes.feed;
        }

        // If on onboarding but already completed, go to feed
        if (isOnboardingRoute && user.hasCompletedOnboarding) {
          return AppRoutes.feed;
        }

        return null;
      }

      // If not authenticated and trying to access protected route
      if (authState is AuthUnauthenticated) {
        // If already on an auth route, stay there
        if (isAuthRoute) {
          return null;
        }
        // Protected route → redirect to welcome
        return AppRoutes.welcome;
      }

      // If OTP sent, redirect to verify OTP
      if (authState is AuthOtpSent) {
        if (state.matchedLocation != AppRoutes.verifyOtp) {
          return AppRoutes.verifyOtp;
        }
        return null;
      }

      // If error state, don't redirect — let user stay on current screen
      if (authState is AuthError) {
        return null;
      }

      return null;
    },

    routes: [
      // Splash screen (initial route)
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const SplashScreen()),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const WelcomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const SignUpScreen()),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const SignInScreen()),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        pageBuilder: (context, state) {
          final email = state.extra is String ? state.extra as String : null;
          return _buildPage(context, state, VerifyOtpScreen(email: email));
        },
      ),

      // Onboarding routes
      GoRoute(
        path: AppRoutes.onboardingUsername,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const OnboardingUsernameScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboardingMoods,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const OnboardingMoodsScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboardingLanguage,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const OnboardingLanguageScreen()),
      ),

      // Main app routes
      GoRoute(
        path: AppRoutes.feed,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const FeedScreen()),
      ),
      GoRoute(
        path: AppRoutes.poemEditor,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const PoemEditorScreen()),
      ),
      GoRoute(
        path: AppRoutes.poem,
        pageBuilder: (context, state) {
          final poemId = state.pathParameters['id'] ?? '';
          return _buildPage(context, state, PoemReaderScreen(poemId: poemId));
        },
      ),
      GoRoute(
        path: AppRoutes.discover,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const DiscoverScreen()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.user,
        pageBuilder: (context, state) {
          final username = state.pathParameters['username'] ?? '';
          return _buildPage(context, state, ProfileScreen(username: username));
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const NotificationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.storyEditor,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const StoryEditorScreen()),
      ),
      GoRoute(
        path: AppRoutes.storyPart,
        pageBuilder: (context, state) {
          final storyId = state.pathParameters['storyId'] ?? '';
          final partId = state.pathParameters['partId'] ?? '';
          return _buildPage(
            context,
            state,
            StoryPartScreen(storyId: storyId, partId: partId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.collabPoem,
        pageBuilder: (context, state) {
          final poemId = state.pathParameters['id'] ?? '';
          return _buildPage(context, state, CollabPoemScreen(poemId: poemId));
        },
      ),
      GoRoute(
        path: AppRoutes.duel,
        pageBuilder: (context, state) {
          final duelId = state.pathParameters['id'] ?? '';
          return _buildPage(context, state, DuelScreen(duelId: duelId));
        },
      ),
      GoRoute(
        path: AppRoutes.videoFeed,
        pageBuilder: (context, state) =>
            _buildPage(context, state, const VideoFeedScreen()),
      ),
    ],

    // Error page
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(child: Text('Page not found: ${state.matchedLocation}')),
      ),
    ),
  );
});

/// Build page with custom transition (animation A06)
CustomTransitionPage<void> _buildPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.emphasized,
    reverseTransitionDuration: AppDurations.standard,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Check for reduced motion
      final noMotion = MediaQuery.of(context).disableAnimations;

      if (noMotion) {
        // Simple fade for reduced motion
        return FadeTransition(opacity: animation, child: child);
      }

      // Full animation: fade + slide up 6%
      final fade = CurvedAnimation(
        parent: animation,
        curve: AppCurves.emphasized,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: AppCurves.sheetOpen));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
