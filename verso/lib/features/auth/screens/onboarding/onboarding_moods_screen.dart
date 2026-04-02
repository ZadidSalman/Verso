import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';

/// Mood data model for onboarding
class _MoodOption {
  final String id;
  final String label;
  final String emoji;
  final Color color;

  const _MoodOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

/// Available moods from design.md
const _moods = [
  _MoodOption(
    id: 'melancholic',
    label: 'Melancholic',
    emoji: '🌧️',
    color: AppColors.moodMelancholic,
  ),
  _MoodOption(
    id: 'romantic',
    label: 'Romantic',
    emoji: '💕',
    color: AppColors.moodRomantic,
  ),
  _MoodOption(
    id: 'joyful',
    label: 'Joyful',
    emoji: '✨',
    color: AppColors.moodJoyful,
  ),
  _MoodOption(
    id: 'angry',
    label: 'Angry',
    emoji: '🔥',
    color: AppColors.moodAngry,
  ),
  _MoodOption(
    id: 'peaceful',
    label: 'Peaceful',
    emoji: '🌿',
    color: AppColors.moodPeaceful,
  ),
  _MoodOption(
    id: 'nostalgic',
    label: 'Nostalgic',
    emoji: '📜',
    color: AppColors.moodNostalgic,
  ),
  _MoodOption(
    id: 'mysterious',
    label: 'Mysterious',
    emoji: '🌙',
    color: AppColors.moodMysterious,
  ),
  _MoodOption(
    id: 'spiritual',
    label: 'Spiritual',
    emoji: '🕊️',
    color: AppColors.moodSpiritual,
  ),
];

/// Onboarding moods screen - Step 2 of 3
///
/// Design: BG-02 background
/// - Progress indicator (3 dots, step 2 filled)
/// - "What moves you?" headline
/// - 2-column grid of mood cards with gradients
/// - Max 3 selections (4th tap deselects oldest)
/// - "These are my moods" CTA
/// - "I'll decide later" skip link
class OnboardingMoodsScreen extends ConsumerStatefulWidget {
  const OnboardingMoodsScreen({super.key});

  @override
  ConsumerState<OnboardingMoodsScreen> createState() =>
      _OnboardingMoodsScreenState();
}

class _OnboardingMoodsScreenState extends ConsumerState<OnboardingMoodsScreen> {
  final List<String> _selectedMoods = [];
  bool _isSubmitting = false;

  void _toggleMood(String moodId) {
    setState(() {
      if (_selectedMoods.contains(moodId)) {
        _selectedMoods.remove(moodId);
      } else {
        // Max 3 - if tapping 4th, deselect oldest (first)
        if (_selectedMoods.length >= 3) {
          _selectedMoods.removeAt(0);
        }
        _selectedMoods.add(moodId);
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedMoods.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await DioClient.instance.put(
        '/api/users/me/onboarding',
        data: {'preferredMoods': _selectedMoods},
      );

      if (mounted) {
        context.push(AppRoutes.onboardingLanguage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _skipForNow() {
    context.push(AppRoutes.onboardingLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = _selectedMoods.isNotEmpty && !_isSubmitting;

    return Scaffold(
      body: Stack(
        children: [
          // BG-02: Background with sage glows
          Container(color: AppColors.background),
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
          // Main content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Progress indicator - 3 dots, step 2 filled
                      _buildProgressIndicator(currentStep: 2, totalSteps: 3),
                      const SizedBox(height: 48),
                      // Headline
                      Text(
                        'What moves you?',
                        style: theme.textTheme.headlineSmall,
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Mood grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 160 / 80,
                          ),
                      itemCount: _moods.length,
                      itemBuilder: (context, index) {
                        final mood = _moods[index];
                        final isSelected = _selectedMoods.contains(mood.id);
                        return _MoodCard(
                          mood: mood,
                          isSelected: isSelected,
                          onTap: () => _toggleMood(mood.id),
                        );
                      },
                    ),
                  ),
                ),
                // Bottom actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // Submit button
                      FilledButton(
                        onPressed: canSubmit ? _submit : null,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Text('These are my moods'),
                      ),
                      const SizedBox(height: 12),
                      // Skip link
                      TextButton(
                        onPressed: _skipForNow,
                        child: Text(
                          "I'll decide later",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
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

  Widget _buildProgressIndicator({
    required int currentStep,
    required int totalSteps,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isFilled = index < currentStep;
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isFilled ? AppColors.primary : AppColors.outline,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

/// Individual mood card widget with gradient background
class _MoodCard extends StatelessWidget {
  final _MoodOption mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Check for reduced motion
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : AppDurations.standard,
        curve: AppCurves.standard,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mood.color.withValues(alpha: 0.65),
              mood.color.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: AppShapes.radiusMd,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: Stack(
          children: [
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji: 28dp per design.md spec
                  Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  // Label: titleSmall, white per design.md spec
                  Text(
                    mood.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 16, color: mood.color),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
