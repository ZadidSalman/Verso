import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

/// Onboarding username screen - Step 1 of 3
///
/// Design: BG-02 background
/// - Progress indicator (3 dots, step 1 filled)
/// - "Choose your pen name" headline
/// - Username text field with @ prefix and availability indicator
/// - "This is my name" CTA
/// - "I'll choose later" skip link
class OnboardingUsernameScreen extends ConsumerStatefulWidget {
  const OnboardingUsernameScreen({super.key});

  @override
  ConsumerState<OnboardingUsernameScreen> createState() =>
      _OnboardingUsernameScreenState();
}

class _OnboardingUsernameScreenState
    extends ConsumerState<OnboardingUsernameScreen> {
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();

  Timer? _debounceTimer;
  _UsernameAvailability _availability = _UsernameAvailability.empty;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Validates username format (3-20 chars, letters/numbers/underscore only)
  bool _isValidFormat(String username) {
    if (username.length < 3 || username.length > 20) return false;
    return RegExp(r'^[a-z0-9_]+$').hasMatch(username);
  }

  /// Check username availability with debounce
  void _onUsernameChanged(String value) {
    final username = value.toLowerCase().trim();

    _debounceTimer?.cancel();

    if (username.isEmpty) {
      setState(() => _availability = _UsernameAvailability.empty);
      return;
    }

    if (!_isValidFormat(username)) {
      setState(() => _availability = _UsernameAvailability.invalid);
      return;
    }

    setState(() => _availability = _UsernameAvailability.checking);

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final response = await DioClient.instance.get(
          '/api/users/check-username',
          queryParameters: {'u': username},
        );
        final isAvailable = response.data['available'] as bool? ?? false;
        if (mounted) {
          setState(() {
            _availability = isAvailable
                ? _UsernameAvailability.available
                : _UsernameAvailability.taken;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _availability = _UsernameAvailability.error);
        }
      }
    });
  }

  Future<void> _submit() async {
    final username = _usernameController.text.toLowerCase().trim();
    if (!_isValidFormat(username) ||
        _availability != _UsernameAvailability.available) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await DioClient.instance.put(
        '/api/users/me/onboarding',
        data: {'username': username},
      );

      if (mounted) {
        // Update user in auth provider
        final userData = response.data['user'];
        if (userData != null) {
          final updatedUser = (ref.read(authProvider) as AuthAuthenticated).user
              .copyWith(username: userData['username'] as String?);
          ref.read(authProvider.notifier).updateUser(updatedUser);
        }

        context.push(AppRoutes.onboardingMoods);
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
    context.push(AppRoutes.onboardingMoods);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit =
        _availability == _UsernameAvailability.available && !_isSubmitting;

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
                  // Progress indicator - 3 dots, step 1 filled
                  _buildProgressIndicator(currentStep: 1, totalSteps: 3),
                  const SizedBox(height: 48),
                  // Headline
                  Text(
                    'Choose your pen name',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subheadline
                  Text(
                    'This is how the world will know you.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Username text field
                  TextField(
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    onChanged: _onUsernameChanged,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => canSubmit ? _submit() : null,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      prefixText: '@',
                      prefixStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                      hintText: 'yourname',
                      suffixIcon: _buildAvailabilitySuffix(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Availability feedback
                  _buildAvailabilityText(),
                  const SizedBox(height: 4),
                  // Rule hint
                  Text(
                    '3–20 characters · letters, numbers, underscore only',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
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
                        : const Text('This is my name'),
                  ),
                  const SizedBox(height: 16),
                  // Skip link
                  TextButton(
                    onPressed: _skipForNow,
                    child: Text(
                      "I'll choose later",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
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

  Widget _buildAvailabilitySuffix() {
    switch (_availability) {
      case _UsernameAvailability.empty:
      case _UsernameAvailability.invalid:
        return const SizedBox.shrink();
      case _UsernameAvailability.checking:
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      case _UsernameAvailability.available:
        return const Icon(Icons.check_circle, color: AppColors.success);
      case _UsernameAvailability.taken:
      case _UsernameAvailability.error:
        return const Icon(Icons.cancel, color: AppColors.error);
    }
  }

  Widget _buildAvailabilityText() {
    final theme = Theme.of(context);

    switch (_availability) {
      case _UsernameAvailability.empty:
      case _UsernameAvailability.checking:
        return const SizedBox(height: 20);
      case _UsernameAvailability.invalid:
        return const SizedBox(height: 20);
      case _UsernameAvailability.available:
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 200),
          child: Text(
            '✓ This name is available',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.success,
            ),
          ),
        );
      case _UsernameAvailability.taken:
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 200),
          child: Text(
            '✗ This name is taken',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        );
      case _UsernameAvailability.error:
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'Could not check availability',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        );
    }
  }
}

enum _UsernameAvailability { empty, invalid, checking, available, taken, error }
