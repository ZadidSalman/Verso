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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // Progress indicator - 3 dots, step 3 filled
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
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Headline
                  Text(
                    'What language do you write in?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Playfair Display',
                    ),
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
                  Column(
                    children: [
                      _LanguageCard(
                        option: _LanguageOption.english,
                        isSelected:
                            _selectedLanguage == _LanguageOption.english,
                        onTap: () => setState(
                          () => _selectedLanguage = _LanguageOption.english,
                        ),
                        icon: Icons.language,
                        disableAnimations: disableAnimations,
                      ),
                      const SizedBox(height: 12),
                      _LanguageCard(
                        option: _LanguageOption.bengali,
                        isSelected:
                            _selectedLanguage == _LanguageOption.bengali,
                        onTap: () => setState(
                          () => _selectedLanguage = _LanguageOption.bengali,
                        ),
                        icon: Icons.translate,
                        disableAnimations: disableAnimations,
                      ),
                      const SizedBox(height: 12),
                      _LanguageCard(
                        option: _LanguageOption.both,
                        isSelected: _selectedLanguage == _LanguageOption.both,
                        onTap: () => setState(
                          () => _selectedLanguage = _LanguageOption.both,
                        ),
                        icon: Icons.public,
                        disableAnimations: disableAnimations,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  Semantics(
                    button: true,
                    label: 'Complete onboarding',
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: AppShapes.sm,
                          disabledBackgroundColor: AppColors.surfaceVariant,
                          disabledForegroundColor: AppColors.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        onPressed: canSubmit ? _submit : null,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.surface,
                                ),
                              )
                            : Text(
                                'Take me to my feed',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: canSubmit
                                      ? AppColors.surface
                                      : AppColors.onSurfaceVariant.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual language card widget
class _LanguageCard extends StatelessWidget {
  final _LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final bool disableAnimations;

  const _LanguageCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.disableAnimations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Bengali label explicitly strips fontFamily so it resolves to system (Noto Serif Bengali)
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
    );

    final labelStyle = option == _LanguageOption.bengali
        ? textStyle?.copyWith(
            fontFamily: 'system',
          ) // We strip the Playfair or DM Sans family to let system handle Bangla
        : textStyle;

    return Semantics(
      button: true,
      label: 'Select ${option.label}',
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surface,
            borderRadius: AppShapes.radiusMd, // 12dp corner
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
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),

                // Language label
                Text(option.label, style: labelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
