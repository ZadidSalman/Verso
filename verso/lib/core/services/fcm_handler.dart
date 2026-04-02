import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/dio_client.dart';

/// FCM Handler - Firebase Cloud Messaging token registration
///
/// Usage: Call registerFCMToken() after successful login/verifyOtp.
/// - Requests notification permission
/// - Gets FCM token and sends to backend
/// - Listens for token refresh and updates backend
///
/// ⚠️ Requires:
/// - google-services.json in android/app/
/// - Firebase project configured for this app
/// - Backend endpoint PUT /api/users/me/fcm-token
class FCMHandler {
  FCMHandler._();

  static final FCMHandler _instance = FCMHandler._();
  static FCMHandler get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  /// Initialize FCM and register token with backend
  ///
  /// Call this after successful authentication (login/verifyOtp).
  Future<void> registerFCMToken() async {
    if (_isInitialized) return;

    try {
      // Request permission (iOS requires this, Android auto-grants)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        final token = await _messaging.getToken();

        if (token != null) {
          await _sendTokenToBackend(token);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen(_sendTokenToBackend);

        _isInitialized = true;

        if (kDebugMode) {
          print('FCM: Token registered successfully');
        }
      } else {
        if (kDebugMode) {
          print('FCM: Permission denied by user');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM: Error registering token: $e');
      }
      // Don't throw - FCM failure shouldn't block app usage
    }
  }

  /// Send FCM token to backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      await DioClient.instance.put(
        '/api/users/me/fcm-token',
        data: {'fcmToken': token},
      );

      if (kDebugMode) {
        print('FCM: Token sent to backend');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM: Error sending token to backend: $e');
      }
      // Don't throw - will retry on next app launch
    }
  }

  /// Clear FCM token on logout
  Future<void> clearToken() async {
    try {
      await _messaging.deleteToken();
      _isInitialized = false;

      if (kDebugMode) {
        print('FCM: Token cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM: Error clearing token: $e');
      }
    }
  }

  /// Get current FCM token (for debugging)
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }
}
