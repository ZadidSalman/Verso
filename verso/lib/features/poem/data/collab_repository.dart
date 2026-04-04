import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/collab_poem_model.dart';

/// Repository for collaborative poem API calls
class CollabRepository {
  final Dio _dio = DioClient.instance;

  /// Create a new collab poem
  Future<CollabPoemModel> createCollabPoem({
    required String title,
    String language = 'en',
    String collabType = 'open',
    List<String>? mood,
  }) async {
    final response = await _dio.post(
      '/api/collab',
      data: {
        'title': title,
        'language': language,
        'collabType': collabType,
        'mood': mood ?? [],
      },
    );
    return CollabPoemModel.fromJson(
      response.data['poem'] as Map<String, dynamic>,
    );
  }

  /// Get a collab poem by ID
  Future<CollabPoemModel> getCollabPoem(String id) async {
    final response = await _dio.get('/api/collab/$id');
    return CollabPoemModel.fromJson(
      response.data['poem'] as Map<String, dynamic>,
    );
  }

  /// Submit a stanza to a collab poem
  Future<CollabPoemModel> submitStanza({
    required String poemId,
    required String content,
  }) async {
    final response = await _dio.post(
      '/api/collab/$poemId/stanzas',
      data: {'content': content},
    );
    return CollabPoemModel.fromJson(
      response.data['poem'] as Map<String, dynamic>,
    );
  }

  /// Close a collab poem (originator only)
  Future<CollabPoemModel> closeCollabPoem(String id) async {
    final response = await _dio.post('/api/collab/$id/close');
    return CollabPoemModel.fromJson(
      response.data['poem'] as Map<String, dynamic>,
    );
  }

  /// Get trending collab poems
  Future<List<CollabPoemModel>> getTrendingCollabs({int limit = 10}) async {
    final response = await _dio.get(
      '/api/collab/trending',
      queryParameters: {'limit': limit},
    );
    final items = response.data['items'] as List? ?? [];
    return items
        .map((e) => CollabPoemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
