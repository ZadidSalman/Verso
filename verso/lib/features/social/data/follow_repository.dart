import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

/// Repository for follow/unfollow API calls
class FollowRepository {
  final Dio _dio = DioClient.instance;

  /// Follow a user
  Future<FollowStatus> follow(String userId) async {
    final response = await _dio.post('/api/users/$userId/follow');
    return FollowStatus.fromJson(response.data as Map<String, dynamic>);
  }

  /// Unfollow a user
  Future<FollowStatus> unfollow(String userId) async {
    final response = await _dio.delete('/api/users/$userId/follow');
    return FollowStatus.fromJson(response.data as Map<String, dynamic>);
  }

  /// Check follow status
  Future<FollowStatus> getFollowStatus(String userId) async {
    final response = await _dio.get('/api/users/$userId/follow-status');
    return FollowStatus.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Follow status DTO
class FollowStatus {
  final bool isFollowing;
  final bool isMutual;
  final int? followersCount;

  const FollowStatus({
    required this.isFollowing,
    required this.isMutual,
    this.followersCount,
  });

  factory FollowStatus.fromJson(Map<String, dynamic> json) {
    return FollowStatus(
      isFollowing: json['isFollowing'] as bool? ?? false,
      isMutual: json['isMutual'] as bool? ?? false,
      followersCount: json['followersCount'] as int?,
    );
  }
}
