import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/poem_model.dart';

/// Repository for video feed API calls
class VideoRepository {
  final Dio _dio = DioClient.instance;

  /// Get video feed (poems with videoUrl)
  Future<List<PoemModel>> getVideoFeed({int limit = 10}) async {
    final response = await _dio.get(
      '/api/feed',
      queryParameters: {'type': 'video', 'limit': limit},
    );
    final items = response.data['items'] as List? ?? [];
    return items
        .map((e) => PoemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Upload video for a poem
  Future<String> uploadVideo({
    required String poemId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/api/poems/$poemId/video',
      data: formData,
    );
    return response.data['videoUrl'] as String;
  }
}
