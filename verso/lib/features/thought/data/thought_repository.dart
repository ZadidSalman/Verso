import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/thought_model.dart';

/// Repository for thought API calls
class ThoughtRepository {
  final Dio _dio = DioClient.instance;

  /// Create a thought
  Future<ThoughtModel> createThought({
    required String content,
    String visibility = 'public',
  }) async {
    final response = await _dio.post(
      '/api/thoughts',
      data: {'content': content, 'visibility': visibility},
    );
    return ThoughtModel.fromJson(
      response.data['thought'] as Map<String, dynamic>,
    );
  }

  /// Delete a thought
  Future<void> deleteThought(String thoughtId) async {
    await _dio.delete('/api/thoughts/$thoughtId');
  }

  /// Get my thoughts (for profile)
  Future<ThoughtsResponse> getMyThoughts({
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/users/me/thoughts',
      queryParameters: {if (cursor != null) 'cursor': cursor, 'limit': limit},
    );
    return ThoughtsResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Thoughts response with pagination
class ThoughtsResponse {
  final List<ThoughtModel> items;
  final String? nextCursor;
  final bool hasMore;

  const ThoughtsResponse({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  factory ThoughtsResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return ThoughtsResponse(
      items: itemsList
          .map((e) => ThoughtModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
