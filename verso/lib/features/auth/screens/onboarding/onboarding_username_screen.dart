import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../models/auth_user.dart';
import '../../providers/auth_provider.dart';

/// Onboarding username screen - Step 1 of 3
///
/// Design: BG-02 background
class OnboardingUsernameScreen extends ConsumerStatefulWidget {
  const OnboardingUsernameScreen({super.key});

  @override
  ConsumerState<OnboardingUsernameScreen> createState() =>
      _OnboardingUsernameScreenState();
}

enum _UsernameAvailability { empty, invalid, checking, available, taken, error }

class _OnboardingUsernameScreenState
    extends ConsumerState<OnboardingUsernameScreen> {
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();

  Timer? _debounceTimer;
  _UsernameAvailability _availability = _UsernameAvailability.empty;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool _isValidFormat(String username) {
    if (username.length < 3 || username.length > 20) return false;
    return RegExp(r'^[a-z0-9_]+$').hasMatch(username);
  }

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
        // If backend is unreachable, allow the user to proceed anyway.
        // The backend will validate on submit and return an error if taken.
        if (mounted) {
          setState(() => _availability = _UsernameAvailability.available);
        }
      }
    });
  }

  Future<void> _submit() async {
    final username = _usernameController.text.toLowerCase().trim();
    if (!_isValidFormat(username)) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await DioClient.instance.put(
        '/api/users/me/onboarding',
        data: {'username': username},
      );

      if (mounted) {
        // Navigate immediately without updating auth state mid-flow.
        // The user data will be refreshed on next app start via checkAuthStatus.
        context.go(AppRoutes.onboardingMoods);
      }
    } on DioException catch (e) {
      if (mounted) {
        final message = e.response?.data['message'] as String?;
        if (message != null && message.toLowerCase().contains('taken')) {
          setState(() => _availability = _UsernameAvailability.taken);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Something went wrong.')),
        );
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
    context.go(AppRoutes.onboardingMoods);
  }

  Widget _buildAvailabilityIcon() {
    switch (_availability) {
      case _UsernameAvailability.checking:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        );
      case _UsernameAvailability.available:
        return const Icon(Icons.check, color: AppColors.success, size: 20);
      case _UsernameAvailability.taken:
      case _UsernameAvailability.invalid:
      case _UsernameAvailability.error:
        return const Icon(Icons.close, color: AppColors.error, size: 20);
      case _UsernameAvailability.empty:
        return const SizedBox.shrink();
    }
  }

  Color _getBorderColor() {
    if (_availability == _UsernameAvailability.available)
      return AppColors.primary;
    if (_availability == _UsernameAvailability.taken ||
        _availability == _UsernameAvailability.invalid)
      return AppColors.error;
    if (_usernameFocusNode.hasFocus) return AppColors.primary;
    return AppColors.outlineVariant;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit =
        _availability == _UsernameAvailability.available && !_isSubmitting;
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

                  // Progress indicator - 3 dots, step 1 filled
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                    'Choose your pen name',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Playfair Display',
                    ),
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

                  // Username TextField 56dp
                  Semantics(
                    label: 'Pen name text field',
                    child: SizedBox(
                      height: 56,
                      child: TextField(
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        onChanged: _onUsernameChanged,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => canSubmit ? _submit() : null,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '@',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          hintText: 'yourname',
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: AppShapes.radiusSm,
                            borderSide: BorderSide(color: _getBorderColor()),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppShapes.radiusSm,
                            borderSide: BorderSide(color: _getBorderColor()),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppShapes.radiusSm,
                            borderSide: BorderSide(
                              color: _getBorderColor(),
                              width: 2,
                            ),
                          ),
                          suffixIcon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: disableAnimations
                                        ? const AlwaysStoppedAnimation(1.0)
                                        : Tween<double>(
                                            begin: 0.5,
                                            end: 1.0,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: AppCurves.spring,
                                            ),
                                          ),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                            child: Container(
                              key: ValueKey(_availability),
                              alignment: Alignment.center,
                              width: 48,
                              height: 56,
                              child: _buildAvailabilityIcon(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Availability feedback text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Builder(
                        key: ValueKey(_availability),
                        builder: (context) {
                          if (_availability == _UsernameAvailability.empty) {
                            return Text(
                              '3–20 characters · letters, numbers, underscore only',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.tertiary,
                              ),
                            );
                          } else if (_availability ==
                              _UsernameAvailability.checking) {
                            return Text(
                              'Checking...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            );
                          } else if (_availability ==
                              _UsernameAvailability.available) {
                            return Text(
                              '✓ This name is available',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                              ),
                            );
                          } else if (_availability ==
                              _UsernameAvailability.taken) {
                            return Text(
                              '✗ This name is taken',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                            );
                          } else if (_availability ==
                              _UsernameAvailability.invalid) {
                            return Text(
                              '✗ Invalid format. Use 3-20 letters, numbers, or _',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                            );
                          } else {
                            return Text(
                              '✗ Error checking name. Try again.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  Semantics(
                    button: true,
                    label: 'Confirm pen name',
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
                                'This is my name',
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

                  const SizedBox(height: 16),

                  // Skip Link
                  Semantics(
                    button: true,
                    label: 'Skip and choose later',
                    child: TextButton(
                      onPressed: _skipForNow,
                      child: Text(
                        "I'll choose later",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant, // variant
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
