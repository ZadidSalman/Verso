import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../providers/auth_provider.dart';

/// OTP Verification screen
///
/// Design:
/// - "Check your email" heading
/// - Subtitle with email
/// - 6-box OTP input with auto-advance
/// - Resend button with 60s countdown
/// - Animation A17: Error shake
class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String? email;

  const VerifyOtpScreen({super.key, this.email});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int _resendCountdown = 0;
  Timer? _countdownTimer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupShakeAnimation();
    _startResendCountdown();
  }

  void _setupShakeAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 7.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: -7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: -7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
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
    _shakeController.dispose();
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

  String? get _email {
    final authState = ref.read(authProvider);
    if (authState is AuthOtpSent) {
      return authState.email;
    }
    return widget.email;
  }

  void _onOtpChanged(int index, String value) {
    setState(() => _hasError = false);

    if (value.length == 1 && index < 5) {
      // Move to next box
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-submit when all boxes filled
    if (_otp.length == 6) {
      _submitOtp();
    }
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      // Move to previous box on backspace when empty
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _submitOtp() {
    final email = _email;
    if (email == null || _otp.length != 6) return;

    ref.read(authProvider.notifier).verifyOtp(email: email, otp: _otp);
  }

  void _resendOtp() {
    final email = _email;
    if (email == null) return;

    ref.read(authProvider.notifier).resendOtp(email);
    _startResendCountdown();
  }

  void _shakeBoxes() {
    setState(() => _hasError = true);
    _shakeController.forward(from: 0);
  }

  void _clearBoxes() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final noMotion = reducedMotion(context);

    // Listen for errors
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthError) {
        if (!noMotion) {
          _shakeBoxes();
        }
        _clearBoxes();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                'Check your email',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _email ?? 'your email',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // OTP boxes with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 48,
                      height: 56,
                      margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (event) => _onKeyPressed(index, event),
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: theme.textTheme.headlineSmall,
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: _hasError
                                ? AppColors.errorContainer
                                : AppColors.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? AppColors.error
                                    : AppColors.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
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
                          onChanged: (value) => _onOtpChanged(index, value),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              // Loading indicator
              if (isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    // Resend button
                    TextButton(
                      onPressed: _resendCountdown == 0 ? _resendOtp : null,
                      child: Text(
                        _resendCountdown > 0
                            ? 'Resend code in ${_resendCountdown}s'
                            : "Didn't get it? Resend code",
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Change email link
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Change email'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
