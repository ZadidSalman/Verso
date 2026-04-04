import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

/// OTP Verification screen
///
/// Design: BG-02 background
class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String? email;

  const VerifyOtpScreen({super.key, this.email});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 0;
  Timer? _countdownTimer;
  bool _hasError = false;
  String _errorToken = ""; // Used to trigger shake animation on change

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {}); // trigger rebuild for focus scale
      });
    }
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otp.length == 6;

  String? get _email {
    final authState = ref.read(authProvider);
    if (authState is AuthOtpSent) {
      return authState.email;
    }
    return widget.email;
  }

  void _onOtpChanged(int index, String value) {
    setState(() => _hasError = false);

    if (value.isNotEmpty && index < 5) {
      // Move to next box
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Let KeyboardListener handle backspace if empty, but if value is empty here, we don't auto-reverse to avoid double jumps.
    }

    setState(() {}); // Update button state
  }

  void _submitOtp() {
    final email = _email;
    if (email == null || !_isComplete) return;

    ref.read(authProvider.notifier).verifyOtp(email: email, otp: _otp);
  }

  void _resendOtp() {
    final email = _email;
    if (email == null) return;

    ref.read(authProvider.notifier).resendOtp(email);
    _startResendCountdown();
  }

  void _triggerError(String msg) {
    setState(() {
      _hasError = true;
      _errorToken = DateTime.now().toIso8601String();
    });
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    // Listen for errors
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthError) {
        _triggerError(next.message);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.welcome);
              }
            },
          ),
        ),
      ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48), // 48dp top

                  Text(
                    'Check your email',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Playfair Display',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'We sent a 6-digit code to',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _email ?? 'your email',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // OTP Input — 6 boxes
                  Semantics(
                        label: 'OTP input boxes',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final hasText = _controllers[index].text.isNotEmpty;

                            return Container(
                              width: 44,
                              height: 56,
                              margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (event) {
                                  if (event is KeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.backspace &&
                                      _controllers[index].text.isEmpty &&
                                      index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: _hasError
                                        ? AppColors.error
                                        : AppColors.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: _hasError
                                        ? AppColors.errorContainer.withValues(
                                            alpha: 0.1,
                                          )
                                        : hasText
                                        ? AppColors.surfaceVariant
                                        : AppColors.surface,
                                    contentPadding: EdgeInsets.zero,
                                    border: const OutlineInputBorder(
                                      borderRadius: AppShapes.radiusSm,
                                      borderSide: BorderSide(
                                        color: AppColors.outlineVariant,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: AppShapes.radiusSm,
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? AppColors.error
                                            : AppColors.outlineVariant,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: AppShapes.radiusSm,
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? AppColors.error
                                            : AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) =>
                                      _onOtpChanged(index, value),
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                      .animate(
                        key: ValueKey(_errorToken), // Re-trigger on new error
                      )
                      .shakeX(
                        amount: _hasError && !disableAnimations ? 4 : 0,
                        duration: 400.ms,
                      ),

                  const SizedBox(height: 24),

                  // Verify code button
                  Semantics(
                    button: true,
                    label: 'Verify OTP code',
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
                        onPressed: (_isComplete && !isLoading)
                            ? _submitOtp
                            : null,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.surface,
                                ),
                              )
                            : Text(
                                'Verify code',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: _isComplete
                                      ? AppColors.surface
                                      : AppColors.onSurfaceVariant.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                      ),
                    ),
                  ).animate().custom(
                    duration: 300.ms,
                    builder: (context, value, child) {
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                alpha: _isComplete ? 0.3 * value : 0,
                              ),
                              blurRadius: _isComplete ? 12 * value : 0,
                              spreadRadius: _isComplete ? 2 * value : 0,
                            ),
                          ],
                          borderRadius: AppShapes.radiusSm,
                        ),
                        child: child,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Resend row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_resendCountdown == 0) ...[
                        Text(
                          "Didn't get it?",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Semantics(
                          button: true,
                          label: 'Resend code',
                          child: InkWell(
                            onTap: _resendOtp,
                            borderRadius: AppShapes.radiusXs,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Text(
                                'Resend code',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          "Resend in 0:${_resendCountdown.toString().padLeft(2, '0')}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Change email link
                  Semantics(
                    button: true,
                    label: 'Change email',
                    child: TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.signUp);
                        }
                      },
                      child: Text(
                        'Change email',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
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
