import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/duel_model.dart';

/// Repository for duel API calls
class DuelRepository {
  final Dio _dio = DioClient.instance;

  /// Create a duel
  Future<DuelModel> createDuel({
    required String challengeeId,
    required String theme,
    required String challengerPoemId,
  }) async {
    final response = await _dio.post(
      '/api/duels',
      data: {
        'challengeeId': challengeeId,
        'theme': theme,
        'challengerPoemId': challengerPoemId,
      },
    );
    return DuelModel.fromJson(response.data['duel'] as Map<String, dynamic>);
  }

  /// Get a duel by ID
  Future<DuelModel> getDuel(String id) async {
    final response = await _dio.get('/api/duels/$id');
    return DuelModel.fromJson(response.data['duel'] as Map<String, dynamic>);
  }

  /// Accept a duel
  Future<DuelModel> acceptDuel({
    required String duelId,
    String? challengeePoemId,
  }) async {
    final response = await _dio.post(
      '/api/duels/$duelId/accept',
      data: {'challengeePoemId': challengeePoemId},
    );
    return DuelModel.fromJson(response.data['duel'] as Map<String, dynamic>);
  }

  /// Vote in a duel
  Future<DuelModel> voteDuel({
    required String duelId,
    required String side,
  }) async {
    final response = await _dio.post(
      '/api/duels/$duelId/vote',
      data: {'side': side},
    );
    return DuelModel.fromJson(response.data['duel'] as Map<String, dynamic>);
  }

  /// Get active duels
  Future<List<DuelModel>> getActiveDuels({int limit = 10}) async {
    final response = await _dio.get(
      '/api/duels/active',
      queryParameters: {'limit': limit},
    );
    final items = response.data['items'] as List? ?? [];
    return items
        .map((e) => DuelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
