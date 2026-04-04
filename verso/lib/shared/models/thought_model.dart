/// Thought model matching backend schema
class ThoughtModel {
  final String id;
  final String authorId;
  final ThoughtAuthor? author;
  final String content;
  final String visibility;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ThoughtModel({
    required this.id,
    required this.authorId,
    this.author,
    required this.content,
    required this.visibility,
    required this.likesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ThoughtModel.fromJson(Map<String, dynamic> json) {
    return ThoughtModel(
      id: json['id'] as String,
      authorId: json['authorId'] is String
          ? json['authorId'] as String
          : (json['authorId'] as Map<String, dynamic>)['_id'] as String? ?? '',
      author: json['author'] != null
          ? ThoughtAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      content: json['content'] as String,
      visibility: json['visibility'] as String? ?? 'public',
      likesCount: json['likesCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Thought author info
class ThoughtAuthor {
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final bool isVerifiedPoet;

  const ThoughtAuthor({
    this.displayName,
    this.username,
    this.avatarUrl,
    this.isVerifiedPoet = false,
  });

  factory ThoughtAuthor.fromJson(Map<String, dynamic> json) {
    return ThoughtAuthor(
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isVerifiedPoet: json['isVerifiedPoet'] as bool? ?? false,
    );
  }
}
