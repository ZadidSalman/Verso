/// Thought model matching backend schema
class ThoughtModel {
  final String id;
  final String authorId;
  final ThoughtAuthor? author;
  final String content;
  final String visibility;
  final String? mood;
  final int reactionsCount;
  final DateTime createdAt;

  const ThoughtModel({
    required this.id,
    required this.authorId,
    this.author,
    required this.content,
    required this.visibility,
    this.mood,
    required this.reactionsCount,
    required this.createdAt,
  });

  factory ThoughtModel.fromJson(Map<String, dynamic> json) {
    return ThoughtModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] != null
          ? ThoughtAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      content: json['content'] as String,
      visibility: json['visibility'] as String? ?? 'public',
      mood: json['mood'] as String?,
      reactionsCount: json['reactionsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorId': authorId,
    'content': content,
    'visibility': visibility,
    'mood': mood,
    'reactionsCount': reactionsCount,
    'createdAt': createdAt.toIso8601String(),
  };
}

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
