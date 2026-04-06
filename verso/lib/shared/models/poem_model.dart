import 'story_model.dart';
import 'thought_model.dart';

/// Author info embedded in feed items
class PoemAuthor {
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final bool isVerifiedPoet;

  const PoemAuthor({
    this.displayName,
    this.username,
    this.avatarUrl,
    this.isVerifiedPoet = false,
  });

  factory PoemAuthor.fromJson(Map<String, dynamic> json) {
    return PoemAuthor(
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isVerifiedPoet: json['isVerifiedPoet'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'username': username,
        'avatarUrl': avatarUrl,
        'isVerifiedPoet': isVerifiedPoet,
      };
}

/// Poem model matching the backend Poem schema
class PoemModel {
  final String id;
  final String authorId;
  final PoemAuthor? author;
  final String title;
  final String? content;
  final String slug;
  final String language;
  final List<String> mood;
  final List<String> tags;
  final String? category;
  final String? genre;
  final bool isAnonymous;
  final bool isUnsent;
  final String? unsentTo;
  final String status;
  final String? audioUrl;
  final String? videoUrl;
  final String? coverImageUrl;
  final int likesCount;
  final int commentsCount;
  final int savesCount;
  final int readsCount;
  final double trendingScore;
  final int wordCount;
  final int lineCount;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PoemModel({
    required this.id,
    required this.authorId,
    this.author,
    required this.title,
    this.content,
    required this.slug,
    required this.language,
    required this.mood,
    required this.tags,
    this.category,
    this.genre,
    required this.isAnonymous,
    required this.isUnsent,
    this.unsentTo,
    required this.status,
    this.audioUrl,
    this.videoUrl,
    this.coverImageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.savesCount,
    required this.readsCount,
    required this.trendingScore,
    required this.wordCount,
    required this.lineCount,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PoemModel.fromJson(Map<String, dynamic> json) {
    return PoemModel(
      id: json['id'] as String? ?? json['_id'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] != null
          ? PoemAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      slug: json['slug'] as String,
      language: json['language'] as String? ?? 'en',
      mood: json['mood'] != null ? List<String>.from(json['mood'] as List) : [],
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      category: json['category'] as String?,
      genre: json['genre'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      isUnsent: json['isUnsent'] as bool? ?? false,
      unsentTo: json['unsentTo'] as String?,
      status: json['status'] as String? ?? 'draft',
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      savesCount: json['savesCount'] as int? ?? 0,
      readsCount: json['readsCount'] as int? ?? 0,
      trendingScore: (json['trendingScore'] as num?)?.toDouble() ?? 0.0,
      wordCount: json['wordCount'] as int? ?? 0,
      lineCount: json['lineCount'] as int? ?? 0,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'title': title,
        'content': content,
        'slug': slug,
        'language': language,
        'mood': mood,
        'tags': tags,
        'category': category,
        'genre': genre,
        'isAnonymous': isAnonymous,
        'isUnsent': isUnsent,
        'unsentTo': unsentTo,
        'status': status,
        'audioUrl': audioUrl,
        'videoUrl': videoUrl,
        'coverImageUrl': coverImageUrl,
        'likesCount': likesCount,
        'commentsCount': commentsCount,
        'savesCount': savesCount,
        'readsCount': readsCount,
        'trendingScore': trendingScore,
        'wordCount': wordCount,
        'lineCount': lineCount,
        'publishedAt': publishedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Unified feed item that can be poem, story, or thought
class FeedItem {
  final String id;
  final String type;
  final String authorId;
  final PoemAuthor? author;
  final String? title;
  final String? content;
  final String? description;
  final String language;
  final List<String> mood;
  final List<String> tags;
  final String? genre;
  final String? status;
  final int? likesCount;
  final int? commentsCount;
  final int? readsCount;
  final int? partsCount;
  final double trendingScore;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FeedItem({
    required this.id,
    required this.type,
    required this.authorId,
    this.author,
    this.title,
    this.content,
    this.description,
    required this.language,
    required this.mood,
    required this.tags,
    this.genre,
    this.status,
    this.likesCount,
    this.commentsCount,
    this.readsCount,
    this.partsCount,
    required this.trendingScore,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final itemType = json['type'] as String? ?? 'poem';
    return FeedItem(
      id: json['id'] as String,
      type: itemType,
      authorId: json['authorId'] as String,
      author: json['author'] != null
          ? PoemAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      title: json['title'] as String?,
      content: json['content'] as String?,
      description: json['description'] as String?,
      language: json['language'] as String? ?? 'en',
      mood: json['mood'] != null ? List<String>.from(json['mood'] as List) : [],
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      genre: json['genre'] as String?,
      status: json['status'] as String?,
      likesCount: json['likesCount'] as int?,
      commentsCount: json['commentsCount'] as int?,
      readsCount: json['readsCount'] as int?,
      partsCount: json['partsCount'] as int?,
      trendingScore: (json['trendingScore'] as num?)?.toDouble() ?? 0.0,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Feed response with cursor pagination
class FeedResponse {
  final List<FeedItem> items;
  final String? nextCursor;
  final bool hasMore;

  const FeedResponse({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return FeedResponse(
      items: itemsList
          .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
