/// Story model matching backend schema
class StoryModel {
  final String id;
  final String authorId;
  final StoryAuthor? author;
  final String title;
  final String description;
  final String? coverImageUrl;
  final String language;
  final List<String> mood;
  final List<String> tags;
  final String? genre;
  final bool isCollab;
  final String collabMode;
  final String storyMode;
  final String status;
  final int partsCount;
  final int followersCount;
  final int totalReads;
  final double trendingScore;
  final DateTime? publishedAt;
  final DateTime? lastPartAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoryModel({
    required this.id,
    required this.authorId,
    this.author,
    required this.title,
    required this.description,
    this.coverImageUrl,
    required this.language,
    required this.mood,
    required this.tags,
    this.genre,
    required this.isCollab,
    required this.collabMode,
    required this.storyMode,
    required this.status,
    required this.partsCount,
    required this.followersCount,
    required this.totalReads,
    required this.trendingScore,
    this.publishedAt,
    this.lastPartAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] != null
          ? StoryAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String?,
      language: json['language'] as String? ?? 'en',
      mood: json['mood'] != null ? List<String>.from(json['mood'] as List) : [],
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      genre: json['genre'] as String?,
      isCollab: json['isCollab'] as bool? ?? false,
      collabMode: json['collabMode'] as String? ?? 'none',
      storyMode: json['storyMode'] as String? ?? 'linear',
      status: json['status'] as String? ?? 'ongoing',
      partsCount: json['partsCount'] as int? ?? 0,
      followersCount: json['followersCount'] as int? ?? 0,
      totalReads: json['totalReads'] as int? ?? 0,
      trendingScore: (json['trendingScore'] as num?)?.toDouble() ?? 0.0,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      lastPartAt: json['lastPartAt'] != null
          ? DateTime.parse(json['lastPartAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Story author info
class StoryAuthor {
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final bool isVerifiedPoet;

  const StoryAuthor({
    this.displayName,
    this.username,
    this.avatarUrl,
    this.isVerifiedPoet = false,
  });

  factory StoryAuthor.fromJson(Map<String, dynamic> json) {
    return StoryAuthor(
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isVerifiedPoet: json['isVerifiedPoet'] as bool? ?? false,
    );
  }
}

/// Story part model
class StoryPartModel {
  final String id;
  final String storyId;
  final String authorId;
  final StoryAuthor? author;
  final int partNumber;
  final String title;
  final String content;
  final String? coverImageUrl;
  final String language;
  final List<String> mood;
  final String? parentPartId;
  final String? branchLabel;
  final String status;
  final bool isCollabContribution;
  final int likesCount;
  final int commentsCount;
  final int readsCount;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoryPartModel({
    required this.id,
    required this.storyId,
    required this.authorId,
    this.author,
    required this.partNumber,
    required this.title,
    required this.content,
    this.coverImageUrl,
    required this.language,
    required this.mood,
    this.parentPartId,
    this.branchLabel,
    required this.status,
    required this.isCollabContribution,
    required this.likesCount,
    required this.commentsCount,
    required this.readsCount,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoryPartModel.fromJson(Map<String, dynamic> json) {
    return StoryPartModel(
      id: json['id'] as String,
      storyId: json['storyId'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] != null
          ? StoryAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      partNumber: json['partNumber'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      language: json['language'] as String? ?? 'en',
      mood: json['mood'] != null ? List<String>.from(json['mood'] as List) : [],
      parentPartId: json['parentPartId'] as String?,
      branchLabel: json['branchLabel'] as String?,
      status: json['status'] as String? ?? 'published',
      isCollabContribution: json['isCollabContribution'] as bool? ?? false,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      readsCount: json['readsCount'] as int? ?? 0,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
