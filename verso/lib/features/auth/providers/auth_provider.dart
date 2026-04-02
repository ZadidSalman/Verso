import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';
import '../../../core/services/fcm_handler.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth state
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final String? code;
  const AuthError(this.message, {this.code});
}

class AuthOtpSent extends AuthState {
  final String email;
  final String message;
  const AuthOtpSent({required this.email, required this.message});
}

/// Auth notifier for managing authentication state
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitial();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Check if user is already logged in on app start
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      // Try to fetch user profile
      try {
        final user = await _repository.getMe();
        state = AuthAuthenticated(user);
        return;
      } catch (_) {
        // Token expired or invalid - clear and go to unauthenticated
        await _repository.logout();
      }
    }
    state = const AuthUnauthenticated();
  }

  /// Register a new user
  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      final message = await _repository.register(
        email: email,
        password: password,
      );
      state = AuthOtpSent(email: email, message: message);
    } on DioException catch (e) {
      state = AuthError(_extractErrorMessage(e));
    } catch (e) {
      state = const AuthError('Something went wrong. Please try again.');
    }
  }

  /// Verify OTP
  Future<void> verifyOtp({required String email, required String otp}) async {
    state = const AuthLoading();

    try {
      final response = await _repository.verifyOtp(email: email, otp: otp);
      state = AuthAuthenticated(response.user);

      // Register FCM token after successful verification
      FCMHandler.instance.registerFCMToken();
    } on DioException catch (e) {
      state = AuthError(_extractErrorMessage(e));
    } catch (e) {
      state = const AuthError('Something went wrong. Please try again.');
    }
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();

    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );
      state = AuthAuthenticated(response.user);

      // Register FCM token after successful login
      FCMHandler.instance.registerFCMToken();
    } on DioException catch (e) {
      final code = e.response?.data?['code'] as String?;
      if (code == 'EMAIL_NOT_VERIFIED') {
        state = AuthOtpSent(email: email, message: _extractErrorMessage(e));
      } else {
        state = AuthError(_extractErrorMessage(e), code: code);
      }
    } catch (e) {
      state = const AuthError('Something went wrong. Please try again.');
    }
  }

  /// Logout
  Future<void> logout() async {
    state = const AuthLoading();

    // Clear FCM token
    await FCMHandler.instance.clearToken();

    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    state = const AuthLoading();

    try {
      final message = await _repository.forgotPassword(email);
      state = AuthOtpSent(email: email, message: message);
    } on DioException catch (e) {
      state = AuthError(_extractErrorMessage(e));
    } catch (e) {
      state = const AuthError('Something went wrong. Please try again.');
    }
  }

  /// Reset password
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = const AuthLoading();

    try {
      await _repository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      state = const AuthUnauthenticated();
    } on DioException catch (e) {
      state = AuthError(_extractErrorMessage(e));
    } catch (e) {
      state = const AuthError('Something went wrong. Please try again.');
    }
  }

  /// Resend OTP
  Future<void> resendOtp(String email) async {
    try {
      await _repository.resendOtp(email);
    } catch (_) {
      // Silently fail - user can try again
    }
  }

  /// Update user after onboarding changes
  void updateUser(AuthUser user) {
    if (state is AuthAuthenticated) {
      state = AuthAuthenticated(user);
    }
  }

  /// Extract error message from DioException
  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      return data['message'] as String;
    }
    return 'Something went wrong. Please try again.';
  }
}

/// Provider for AuthNotifier
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Convenience provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});

/// Convenience provider for getting current user (if authenticated)
final currentUserProvider = Provider<AuthUser?>((ref) {
  final state = ref.watch(authProvider);
  if (state is AuthAuthenticated) {
    return state.user;
  }
  return null;
});
