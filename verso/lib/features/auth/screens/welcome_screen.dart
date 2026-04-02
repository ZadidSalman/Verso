import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';

/// Welcome screen - first screen users see
///
/// Design: BG-02 background with sage glows
/// - Quill-pen logo
/// - "Verso" display title
/// - "Where words find their world." tagline
/// - "Begin your story" CTA
/// - "Already a poet? Sign in" link
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // BG-02: Background with sage glows
          Container(
            decoration: const BoxDecoration(color: AppColors.background),
          ),
          // Top-right radial glow
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom-left soft circle
          Positioned(
            bottom: 60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.25),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo placeholder (quill icon)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text('Verso', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 8),
                  // Tagline
                  Text(
                    'Where words find their world.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Primary CTA
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.signUp),
                    child: const Text('Begin your story'),
                  ),
                  const SizedBox(height: 16),
                  // Secondary link
                  TextButton(
                    onPressed: () => context.push(AppRoutes.signIn),
                    child: const Text('Already a poet? Sign in'),
                  ),
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
