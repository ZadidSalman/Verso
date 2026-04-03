import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';

/// Predefined list of moods for onboarding
final _onboardingMoods = [
  {
    'id': 'melancholic',
    'name': 'Melancholic',
    'emoji': '🌧️',
    'color': AppColors.moodMelancholic,
  },
  {
    'id': 'romantic',
    'name': 'Romantic',
    'emoji': '🥀',
    'color': AppColors.moodRomantic,
  },
  {
    'id': 'joyful',
    'name': 'Joyful',
    'emoji': '✨',
    'color': AppColors.moodJoyful,
  },
  {
    'id': 'nostalgic',
    'name': 'Nostalgic',
    'emoji': '🕰️',
    'color': AppColors.moodNostalgic,
  },
  {'id': 'angry', 'name': 'Angry', 'emoji': '🔥', 'color': AppColors.moodAngry},
  {
    'id': 'peaceful',
    'name': 'Peaceful',
    'emoji': '🍃',
    'color': AppColors.moodPeaceful,
  },
  {
    'id': 'mysterious',
    'name': 'Mysterious',
    'emoji': '🌪️',
    'color': AppColors.moodMysterious,
  },
  {
    'id': 'spiritual',
    'name': 'Spiritual',
    'emoji': '🌅',
    'color': AppColors.moodSpiritual,
  },
];

/// Onboarding moods screen - Step 2 of 3
///
/// Design: BG-02 background
class OnboardingMoodsScreen extends ConsumerStatefulWidget {
  const OnboardingMoodsScreen({super.key});

  @override
  ConsumerState<OnboardingMoodsScreen> createState() =>
      _OnboardingMoodsScreenState();
}

class _OnboardingMoodsScreenState extends ConsumerState<OnboardingMoodsScreen> {
  final Set<String> _selectedMoods = {};
  bool _isSaving = false;

  void _toggleMood(String id) {
    setState(() {
      if (_selectedMoods.contains(id)) {
        _selectedMoods.remove(id);
      } else {
        // Max 3: 4th tap deselects oldest (first in iteration order for LinkedHashSet)
        if (_selectedMoods.length >= 3) {
          final first = _selectedMoods.first;
          _selectedMoods.remove(first);
        }
        _selectedMoods.add(id);
      }
    });
  }

  Future<void> _nextStep() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    // Save selected moods to backend
    if (_selectedMoods.isNotEmpty) {
      try {
        await DioClient.instance.put(
          '/api/users/me/onboarding',
          data: {'preferredMoods': _selectedMoods.toList()},
        );
      } catch (_) {
        // Continue even if save fails - user can update later
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      context.go(AppRoutes.onboardingLanguage);
    }
  }

  void _skipForNow() {
    context.go(AppRoutes.onboardingLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = _selectedMoods.isNotEmpty;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // BG-02 Overlay
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

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Progress indicator - dots step 2 of 3
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Headline
                Text(
                  'What moves you?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Playfair Display',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subheadline
                Text(
                  'Choose up to 3 moods to shape your feed.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // GridView
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 160 / 80,
                        ),
                    itemCount: _onboardingMoods.length,
                    itemBuilder: (context, index) {
                      final mood = _onboardingMoods[index];
                      final isSelected = _selectedMoods.contains(
                        mood['id'] as String,
                      );
                      final moodColor = mood['color'] as Color;

                      return Semantics(
                        button: true,
                        label: '${mood['name']} mood',
                        selected: isSelected,
                        child: GestureDetector(
                          onTap: () => _toggleMood(mood['id'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: disableAnimations
                                ? Curves.linear
                                : AppCurves.spring,
                            transform: Matrix4.identity()
                              ..scale(
                                isSelected && !disableAnimations ? 1.04 : 1.0,
                                isSelected && !disableAnimations ? 1.04 : 1.0,
                                1.0,
                              ),
                            transformAlignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: AppShapes.radiusMd, // 12dp
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: isSelected ? 2 : 0,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  moodColor.withValues(alpha: 0.65),
                                  moodColor.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        mood['emoji'] as String,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mood['name'] as String,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color: AppColors
                                                  .surface, // White/Surface
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child:
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 16,
                                        ).animate().fadeIn(
                                          duration: disableAnimations
                                              ? Duration.zero
                                              : 100.ms,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Area
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Submit Button
                      Semantics(
                        button: true,
                        label: 'Confirm mood selection',
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: AppShapes.sm,
                              disabledBackgroundColor: AppColors.surfaceVariant,
                              disabledForegroundColor: AppColors
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            onPressed: hasSelection && !_isSaving
                                ? _nextStep
                                : null,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.surface,
                                    ),
                                  )
                                : Text(
                                    'These are my moods',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: hasSelection
                                          ? AppColors.surface
                                          : AppColors.onSurfaceVariant
                                                .withValues(alpha: 0.5),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Skip Link
                      Semantics(
                        button: true,
                        label: 'Skip mood selection',
                        child: TextButton(
                          onPressed: _skipForNow,
                          child: Text(
                            "I'll decide later",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant, // variant
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
