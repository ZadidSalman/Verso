import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for authentication tokens
///
/// Uses flutter_secure_storage which:
/// - iOS: Keychain Services
/// - Android: EncryptedSharedPreferences (AES-256)
///
/// RULE: Never store tokens in SharedPreferences or Hive.
/// Only flutter_secure_storage is acceptable for auth tokens.
class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Keys
  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUserId = 'auth_user_id';

  /// Get access token
  static Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  /// Get stored user ID
  static Future<String?> getUserId() async {
    return _storage.read(key: _keyUserId);
  }

  /// Save both tokens and user ID after login/register
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      _storage.write(key: _keyUserId, value: userId),
    ]);
  }

  /// Update only the access token (after refresh)
  static Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
  }

  /// Update both tokens (after refresh that returns new refresh token)
  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  /// Clear all auth data (logout)
  static Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserId),
    ]);
  }

  /// Check if user is logged in (has tokens)
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
