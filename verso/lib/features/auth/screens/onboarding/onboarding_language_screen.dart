import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

/// Language options for onboarding
enum _LanguageOption {
  english('en', 'English'),
  bengali('bn', 'বাংলা'),
  both('both', 'Both');

  final String id;
  final String label;

  const _LanguageOption(this.id, this.label);
}

/// Onboarding language screen - Step 3 of 3
///
/// Design: BG-02 background
/// - Progress indicator (3 dots, step 3 filled)
/// - "What language do you write in?" headline
/// - Column of 3 radio cards
/// - "Take me to my feed" CTA
class OnboardingLanguageScreen extends ConsumerStatefulWidget {
  const OnboardingLanguageScreen({super.key});

  @override
  ConsumerState<OnboardingLanguageScreen> createState() =>
      _OnboardingLanguageScreenState();
}

class _OnboardingLanguageScreenState
    extends ConsumerState<OnboardingLanguageScreen> {
  _LanguageOption? _selectedLanguage;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_selectedLanguage == null) return;

    setState(() => _isSubmitting = true);

    try {
      await DioClient.instance.put(
        '/api/users/me/onboarding',
        data: {
          'preferredLanguage': _selectedLanguage!.id,
          'hasCompletedOnboarding': true,
        },
      );

      if (mounted) {
        // Update user in auth provider to mark onboarding complete
        final authState = ref.read(authProvider);
        if (authState is AuthAuthenticated) {
          final updatedUser = authState.user.copyWith(
            hasCompletedOnboarding: true,
          );
          ref.read(authProvider.notifier).updateUser(updatedUser);
        }

        // Navigate to feed
        context.go(AppRoutes.feed);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = _selectedLanguage != null && !_isSubmitting;

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Progress indicator - 3 dots, step 3 filled
                  _buildProgressIndicator(currentStep: 3, totalSteps: 3),
                  const SizedBox(height: 48),
                  // Headline
                  Text(
                    'What language do you write in?',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subheadline
                  Text(
                    "This shapes what content you'll see in your feed.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Language options
                  ...List.generate(_LanguageOption.values.length, (index) {
                    final option = _LanguageOption.values[index];
                    final isSelected = _selectedLanguage == option;
                    return Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                      child: _LanguageCard(
                        option: option,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedLanguage = option),
                      ),
                    );
                  }),
                  const Spacer(),
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
                        : const Text('Take me to my feed'),
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

/// Individual language card widget
class _LanguageCard extends StatelessWidget {
  final _LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.option,
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
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: AppShapes.radiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.outline,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Language icon
              Icon(
                option == _LanguageOption.english
                    ? Icons.language
                    : option == _LanguageOption.bengali
                    ? Icons.translate
                    : Icons.public,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              // Language label
              // Note: Bengali text should NOT have fontFamily set (uses system font)
              Text(
                option.label,
                style: option == _LanguageOption.bengali
                    ? theme.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                      )
                    : theme.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
