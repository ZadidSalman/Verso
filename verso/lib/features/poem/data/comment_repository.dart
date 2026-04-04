import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

/// Comment model matching backend schema
class CommentModel {
  final String id;
  final String targetId;
  final String targetType;
  final CommentAuthor author;
  final String content;
  final String? parentCommentId;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentModel({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.author,
    required this.content,
    this.parentCommentId,
    required this.likesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      author: CommentAuthor.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      parentCommentId: json['parentCommentId'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Comment author info
class CommentAuthor {
  final String id;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final bool isVerifiedPoet;

  const CommentAuthor({
    required this.id,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.isVerifiedPoet = false,
  });

  factory CommentAuthor.fromJson(Map<String, dynamic> json) {
    return CommentAuthor(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isVerifiedPoet: json['isVerifiedPoet'] as bool? ?? false,
    );
  }
}

/// Comments response with pagination
class CommentsResponse {
  final List<CommentModel> items;
  final String? nextCursor;
  final bool hasMore;

  const CommentsResponse({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return CommentsResponse(
      items: itemsList
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

/// Repository for comment API calls
class CommentRepository {
  final Dio _dio = DioClient.instance;

  /// Get comments for a target
  Future<CommentsResponse> getComments({
    required String targetId,
    required String targetType,
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/comments/$targetId',
      queryParameters: {
        'targetType': targetType,
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    return CommentsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create a comment
  Future<CommentModel> createComment({
    required String targetId,
    required String targetType,
    required String content,
    String? parentCommentId,
  }) async {
    final response = await _dio.post(
      '/api/comments',
      data: {
        'targetId': targetId,
        'targetType': targetType,
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      },
    );
    return CommentModel.fromJson(
      response.data['comment'] as Map<String, dynamic>,
    );
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    await _dio.delete('/api/comments/$commentId');
  }
}
