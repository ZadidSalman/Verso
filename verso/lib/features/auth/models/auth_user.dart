/// User model for auth responses
class AuthUser {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final bool hasCompletedOnboarding;

  const AuthUser({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    required this.hasCompletedOnboarding,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['_id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'hasCompletedOnboarding': hasCompletedOnboarding,
  };

  AuthUser copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? hasCompletedOnboarding,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

/// Auth response containing tokens and user
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
