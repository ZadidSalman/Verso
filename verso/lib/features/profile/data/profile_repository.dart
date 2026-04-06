import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/poem_model.dart';

class ProfileRepository {
  final Dio _dio = DioClient.instance;

  Future<FeedResponse> getMyPoems({String? cursor, int limit = 20}) async {
    final response = await _dio.get(
      '/api/users/me/poems',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    return FeedResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FeedResponse> getUserPoems({
    required String username,
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/poems/by/$username',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    return FeedResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
