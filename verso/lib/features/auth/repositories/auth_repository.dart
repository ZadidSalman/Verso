import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_user.dart';

/// Repository for authentication API calls
class AuthRepository {
  final Dio _dio = DioClient.instance;

  /// Register a new user
  /// Returns a message (OTP sent confirmation)
  Future<String> register({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/auth/register',
      data: {'email': email, 'password': password},
    );
    return response.data['message'] as String;
  }

  /// Verify OTP and get tokens
  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post(
      '/api/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );

    final authResponse = AuthResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    // Save tokens
    await SecureStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      userId: authResponse.user.id,
    );

    return authResponse;
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final authResponse = AuthResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    // Save tokens
    await SecureStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      userId: authResponse.user.id,
    );

    return authResponse;
  }

  /// Logout and revoke refresh token
  Future<void> logout() async {
    final refreshToken = await SecureStorage.getRefreshToken();

    // Clear local storage first (even if API call fails)
    await SecureStorage.clearAll();

    if (refreshToken != null) {
      try {
        await _dio.post(
          '/api/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // Ignore errors - user is logged out locally anyway
      }
    }
  }

  /// Request password reset OTP
  Future<String> forgotPassword(String email) async {
    final response = await _dio.post(
      '/api/auth/forgot-password',
      data: {'email': email},
    );
    return response.data['message'] as String;
  }

  /// Reset password with OTP
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _dio.post(
      '/api/auth/reset-password',
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
    return response.data['message'] as String;
  }

  /// Resend OTP
  Future<String> resendOtp(String email) async {
    final response = await _dio.post(
      '/api/auth/resend-otp',
      data: {'email': email},
    );
    return response.data['message'] as String;
  }

  /// Check if user is logged in (has valid tokens)
  Future<bool> isLoggedIn() async {
    return SecureStorage.isLoggedIn();
  }
}
