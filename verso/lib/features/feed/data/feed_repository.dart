import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/poem_model.dart';

/// Repository for feed API calls
class FeedRepository {
  final Dio _dio = DioClient.instance;

  /// Get paginated feed with optional filters
  Future<FeedResponse> getFeed({
    String? cursor,
    int limit = 20,
    String? mood,
    String? language,
    String? type,
  }) async {
    try {
      final response = await _dio.get(
        '/api/feed',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
          if (mood != null) 'mood': mood,
          if (language != null) 'language': language,
          if (type != null) 'type': type,
        },
      );
      if (kDebugMode) {
        debugPrint('[FEED] Raw response: ${response.data}');
      }
      return FeedResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[FEED] Error fetching feed: $e\n$stack');
      }
      rethrow;
    }
  }
}
