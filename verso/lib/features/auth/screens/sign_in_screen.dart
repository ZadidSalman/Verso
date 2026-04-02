import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

/// Sign In screen
///
/// Design: BG-06 - Card on BG-02 background
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    
    // Check if error is specifically about wrong password or email not verified
    String? inlineError;
    if (authState is AuthError) {
      if (authState.message.toLowerCase().contains('password') || 
          authState.message.toLowerCase().contains('credentials')) {
        inlineError = authState.message;
      }
    }

    // Listen for errors
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthError) {
        if (next.message.toLowerCase().contains('verify')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Please verify your email. A new code has been sent.')),
          );
          // Navigate to OTP screen
          context.push(AppRoutes.verifyOtp, extra: {'email': _emailController.text.trim()});
        } else if (!next.message.toLowerCase().contains('password') && 
                   !next.message.toLowerCase().contains('credentials')) {
          // Show snackbar for non-inline errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.message)),
          );
        }
      }
    });

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

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Semantics(
                  label: 'Sign in form',
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    elevation: 3,
                    shadowColor: Colors.transparent,
                    shape: AppShapes.lg,
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome back.',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFamily: 'Playfair Display',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your words have been waiting.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Email field
                          Semantics(
                            label: 'Email address',
                            child: SizedBox(
                              height: 56,
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: 'poet@example.com',
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                  border: OutlineInputBorder(
                                    borderRadius: AppShapes.radiusSm,
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: AppShapes.radiusSm,
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          Semantics(
                            label: 'Password',
                            child: SizedBox(
                              height: 56,
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _onSubmit(),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                  border: const OutlineInputBorder(
                                    borderRadius: AppShapes.radiusSm,
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: AppShapes.radiusSm,
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
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
                          ).animate(target: inlineError != null ? 1 : 0).shakeX(amount: 4, duration: 400.ms),
                          
                          const SizedBox(height: 8),
                          
                          if (inlineError != null)
                            Text(
                              inlineError,
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                            ).animate().fadeIn(duration: 200.ms),

                          // Forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                // TODO: Implement forgot password flow
                              },
                              child: Text(
                                'Forgot password?',
                                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Submit button
                          Semantics(
                            button: true,
                            label: 'Sign in button',
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
                                        'Return to your page',
                                        style: theme.textTheme.labelLarge?.copyWith(color: AppColors.surface),
                                      ).animate().fadeIn(duration: 200.ms),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Sign up link
                          Semantics(
                            button: true,
                            label: 'Navigate to sign up',
                            child: Center(
                              child: TextButton(
                                onPressed: () => context.pushReplacement(AppRoutes.signUp),
                                child: Text(
                                  'New to Verso? Begin your story',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary),
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
