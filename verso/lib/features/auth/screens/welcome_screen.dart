import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
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
    final disableAnimations = MediaQuery.of(context).disableAnimations;

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
          // Floating leaf shapes (optional decorative layer)
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Icon
                  Semantics(
                        label: 'Verso Logo',
                        child: Container(
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.edit_outlined, // Placeholder for Quill SVG
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                      .animate()
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1, 1),
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.expressive,
                        curve: AppCurves.spring,
                      )
                      .fadeIn(
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.expressive,
                      ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                        'Verso',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ), // Playfair 700
                      )
                      .animate(delay: disableAnimations ? 0.ms : 150.ms)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.emphasized,
                        curve: AppCurves.sheetOpen,
                      )
                      .fadeIn(
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.emphasized,
                      ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                        'Where words find their world.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant,
                        ),
                      )
                      .animate(delay: disableAnimations ? 0.ms : 350.ms)
                      .fadeIn(
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.standard,
                      ),

                  const Spacer(flex: 3),

                  // CTA Button
                  Semantics(
                        button: true,
                        label: 'Sign up to begin your story',
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: AppShapes.sm,
                            ),
                            onPressed: () => context.push(AppRoutes.signUp),
                            child: Text(
                              'Begin your story',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate(delay: disableAnimations ? 0.ms : 550.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.emphasized,
                        curve: AppCurves.sheetOpen,
                      )
                      .fadeIn(
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.emphasized,
                      ),

                  const SizedBox(height: 12),

                  // Secondary link
                  Semantics(
                        button: true,
                        label: 'Sign in to existing account',
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.signIn),
                          child: Text(
                            'Already a poet? Sign in',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .animate(delay: disableAnimations ? 0.ms : 750.ms)
                      .fadeIn(
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.standard,
                      ),

                  const SizedBox(height: 16), // safe bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
