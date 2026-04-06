import 'package:dio/dio.dart';
import 'dart:io';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_user.dart';

/// Repository for authentication API calls
class AuthRepository {
  final Dio _dio = DioClient.instance;

  /// Safely extract a string message from response data
  String _extractMessage(
    dynamic data, {
    String fallback = 'Operation successful',
  }) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;
    }
    return fallback;
  }

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
    return _extractMessage(response.data, fallback: 'Verification code sent');
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

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid response format');
    }

    final authResponse = AuthResponse.fromJson(data);

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

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid response format');
    }

    final authResponse = AuthResponse.fromJson(data);

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
    return _extractMessage(response.data, fallback: 'Reset code sent');
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
    return _extractMessage(
      response.data,
      fallback: 'Password reset successful',
    );
  }

  /// Resend OTP
  Future<String> resendOtp(String email) async {
    final response = await _dio.post(
      '/api/auth/resend-otp',
      data: {'email': email},
    );
    return _extractMessage(response.data, fallback: 'Code resent');
  }

  /// Check if user is logged in (has valid tokens)
  Future<bool> isLoggedIn() async {
    return SecureStorage.isLoggedIn();
  }

  /// Get current user profile
  Future<AuthUser> getMe() async {
    final response = await _dio.get('/api/users/me');
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid response format');
    }
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw FormatException('Invalid user data in response');
    }
    return AuthUser.fromJson(user);
  }

  /// Upload avatar image
  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        filePath,
        filename: 'avatar.jpg',
      ),
    });
    final response = await _dio.post(
      '/api/users/me/avatar',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid response format');
    }
    return data['avatarUrl'] as String;
  }

  /// Upload cover photo
  Future<String> uploadCover(String filePath) async {
    final formData = FormData.fromMap({
      'cover': await MultipartFile.fromFile(
        filePath,
        filename: 'cover.jpg',
      ),
    });
    final response = await _dio.post(
      '/api/users/me/cover',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw FormatException('Invalid response format');
    }
    return data['coverUrl'] as String;
  }
}
