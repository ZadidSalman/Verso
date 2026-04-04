import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/poem_model.dart';

/// Repository for poem API calls
class PoemRepository {
  final Dio _dio = DioClient.instance;

  /// Create a new poem
  Future<PoemModel> createPoem({
    required String title,
    required String content,
    required String language,
    List<String>? mood,
    List<String>? tags,
    String? category,
    String? genre,
    bool isAnonymous = false,
    bool isUnsent = false,
    String? unsentTo,
    String status = 'draft',
  }) async {
    final response = await _dio.post(
      '/api/poems',
      data: {
        'title': title,
        'content': content,
        'language': language,
        'mood': mood ?? [],
        'tags': tags ?? [],
        'category': category,
        'genre': genre,
        'isAnonymous': isAnonymous,
        'isUnsent': isUnsent,
        'unsentTo': unsentTo,
        'status': status,
      },
    );
    return PoemModel.fromJson(response.data['poem'] as Map<String, dynamic>);
  }

  /// Get a single poem by ID
  Future<PoemModel> getPoem(String id) async {
    final response = await _dio.get('/api/poems/$id');
    return PoemModel.fromJson(response.data['poem'] as Map<String, dynamic>);
  }

  /// Update a poem (author only)
  Future<PoemModel> updatePoem(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/poems/$id', data: data);
    return PoemModel.fromJson(response.data['poem'] as Map<String, dynamic>);
  }

  /// Delete a poem (author only)
  Future<void> deletePoem(String id) async {
    await _dio.delete('/api/poems/$id');
  }

  /// Publish a draft poem
  Future<PoemModel> publishPoem(String id) async {
    final response = await _dio.post('/api/poems/$id/publish');
    return PoemModel.fromJson(response.data['poem'] as Map<String, dynamic>);
  }

  /// Get all poems by username
  Future<FeedResponse> getPoemsByUsername({
    required String username,
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/poems/by/$username',
      queryParameters: {if (cursor != null) 'cursor': cursor, 'limit': limit},
    );
    return FeedResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Track a read (after 5s dwell)
  Future<void> trackRead(String id) async {
    await _dio.post('/api/poems/$id/read');
  }

  /// Save a draft (creates new draft or updates existing)
  Future<PoemModel> saveDraft({
    String? id,
    required String title,
    required String content,
    required String language,
    List<String>? mood,
    List<String>? tags,
  }) async {
    if (id != null) {
      return updatePoem(id, {
        'title': title,
        'content': content,
        'language': language,
        'mood': mood ?? [],
        'tags': tags ?? [],
        'status': 'draft',
      });
    }
    return createPoem(
      title: title.isEmpty ? 'Untitled' : title,
      content: content,
      language: language,
      mood: mood,
      tags: tags,
      status: 'draft',
    );
  }
}
