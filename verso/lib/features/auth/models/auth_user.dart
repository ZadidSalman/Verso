/// User model for auth responses
class AuthUser {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? coverUrl;
  final bool hasCompletedOnboarding;

  const AuthUser({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.coverUrl,
    required this.hasCompletedOnboarding,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['_id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'coverUrl': coverUrl,
    'hasCompletedOnboarding': hasCompletedOnboarding,
  };

  AuthUser copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? coverUrl,
    bool? hasCompletedOnboarding,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
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
