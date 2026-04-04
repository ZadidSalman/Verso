import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

/// Repository for like API calls
class LikeRepository {
  final Dio _dio = DioClient.instance;

  /// Like a target
  Future<void> like(String targetId, String targetType) async {
    await _dio.post(
      '/api/likes',
      data: {'targetId': targetId, 'targetType': targetType},
    );
  }

  /// Unlike a target
  Future<void> unlike(String targetId, String targetType) async {
    await _dio.delete(
      '/api/likes/$targetId',
      queryParameters: {'targetType': targetType},
    );
  }

  /// Check if user liked a target
  Future<bool> isLiked(String targetId, String targetType) async {
    final response = await _dio.get(
      '/api/likes/$targetId',
      queryParameters: {'targetType': targetType},
    );
    return response.data['isLiked'] as bool? ?? false;
  }
}
