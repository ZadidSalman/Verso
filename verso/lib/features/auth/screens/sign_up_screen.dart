import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

/// Sign Up screen
///
/// Design: BG-06 - Card on BG-02 background
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _validationError;

  // Email validation regex
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _validationError = 'Please enter your email');
      return false;
    }

    if (!_emailRegex.hasMatch(email)) {
      setState(() => _validationError = 'Please enter a valid email address');
      return false;
    }

    if (password.isEmpty) {
      setState(() => _validationError = 'Please enter a password');
      return false;
    }

    if (password.length < 8) {
      setState(
        () => _validationError = 'Password must be at least 8 characters',
      );
      return false;
    }

    setState(() => _validationError = null);
    return true;
  }

  void _onSubmit() {
    if (!_validateInputs()) return;

    ref
        .read(authProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    // Show validation error OR auth error
    final String? errorText =
        _validationError ?? (authState is AuthError ? authState.message : null);

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

          // Back Button
          SafeArea(
            child: Semantics(
              button: true,
              label: 'Go back',
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
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
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Semantics(
                  label: 'Sign up form',
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: AppShapes.lg,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create your account',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFamily:
                                  'Playfair Display', // Since the theme might not have it strictly set yet, but per docs: Playfair
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          Semantics(
                            label: 'Email address',
                            child: SizedBox(
                              height: 56,
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    size: 20,
                                  ),
                                  hintText: 'your@email.com',
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                  border: const OutlineInputBorder(
                                    borderRadius: AppShapes.radiusSm,
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: AppShapes.radiusSm,
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password Field
                          Semantics(
                            label: 'Password',
                            child: SizedBox(
                              height: 56,
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                onSubmitted: (_) => _onSubmit(),
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                  ),
                                  hintText: 'At least 8 characters',
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                  border: const OutlineInputBorder(
                                    borderRadius: AppShapes.radiusSm,
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: AppShapes.radiusSm,
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    child: IconButton(
                                      key: ValueKey(_obscurePassword),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Error Text
                          if (errorText != null)
                            Text(
                              errorText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                            ).animate().fadeIn(duration: 200.ms),

                          const SizedBox(height: 24),

                          // Submit Button
                          Semantics(
                            button: true,
                            label: 'Sign up button',
                            child: SizedBox(
                              height: 56,
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: AppShapes.sm,
                                ),
                                onPressed: isLoading ? null : _onSubmit,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.surface,
                                        ),
                                      ).animate().fadeIn(duration: 200.ms)
                                    : Text(
                                        'Begin your story',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: AppColors.surface,
                                            ),
                                      ).animate().fadeIn(duration: 200.ms),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Sign in link
                          Semantics(
                            button: true,
                            label: 'Navigate to sign in',
                            child: Center(
                              child: TextButton(
                                onPressed: () =>
                                    context.pushReplacement(AppRoutes.signIn),
                                child: Text(
                                  'Already a poet? Sign in',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
