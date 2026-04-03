import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

/// API environment configuration
/// Values come from --dart-define at build time
class ApiConfig {
  ApiConfig._();

  static const _baseUrlFromEnv = String.fromEnvironment('API_URL');

  /// Fallback URL for local development when API_URL is not set
  /// Only available in debug mode - release builds must set API_URL
  static const _devFallbackUrl =
      'http://10.0.2.2:3000'; // Android emulator localhost

  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }
    // Only allow fallback in debug mode
    if (kDebugMode) {
      debugPrint(
        '[DIO] WARNING: API_URL not set, using fallback: $_devFallbackUrl',
      );
      return _devFallbackUrl;
    }
    // In release mode, throw if API_URL is not set
    throw StateError('API_URL must be set via --dart-define in release builds');
  }

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}

/// Singleton Dio client with auto-refresh interceptor
///
/// Usage:
/// ```dart
/// final response = await DioClient.instance.get('/api/feed');
/// ```
class DioClient {
  DioClient._();

  static final Dio instance = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth header interceptor
    dio.interceptors.add(_AuthInterceptor());

    // Add auto-refresh interceptor (must be after auth interceptor)
    dio.interceptors.add(_AutoRefreshInterceptor(dio));

    // Add logging in debug mode
    assert(() {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => print('[DIO] $obj'),
        ),
      );
      return true;
    }());

    return dio;
  }
}

/// Interceptor to add Authorization header to requests
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final publicPaths = [
      '/api/auth/register',
      '/api/auth/login',
      '/api/auth/verify-otp',
      '/api/auth/refresh',
      '/api/auth/forgot-password',
      '/api/auth/reset-password',
      '/api/auth/resend-otp',
      '/health',
    ];

    if (publicPaths.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

/// QueuedInterceptor for automatic token refresh on 401
///
/// Uses QueuedInterceptor to ensure only one refresh happens at a time.
/// All concurrent requests that get 401 will wait for the refresh to complete.
class _AutoRefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;

  _AutoRefreshInterceptor(this._dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Check if this was already a refresh attempt (prevent infinite loop)
    if (err.requestOptions.path.contains('/api/auth/refresh')) {
      await SecureStorage.clearAll();
      return handler.next(err);
    }

    // Try to refresh the token
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) {
      await SecureStorage.clearAll();
      return handler.next(err);
    }

    try {
      // Use a fresh Dio instance to avoid interceptor loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        ),
      );

      final response = await refreshDio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      // Save new tokens
      await SecureStorage.updateTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Retry the original request with new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await _dio.fetch(opts);
      return handler.resolve(retryResponse);
    } catch (_) {
      // Refresh failed - clear tokens and propagate error
      await SecureStorage.clearAll();
      return handler.next(err);
    }
  }
}
