import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/notification_model.dart';

/// Repository for notification API calls
class NotificationRepository {
  final Dio _dio = DioClient.instance;

  /// Get notifications list
  Future<NotificationsResponse> getNotifications({
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/notifications',
      queryParameters: {if (cursor != null) 'cursor': cursor, 'limit': limit},
    );
    return NotificationsResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _dio.put('/api/notifications/read-all');
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    await _dio.put('/api/notifications/$notificationId/read');
  }
}

/// Notifications response with pagination
class NotificationsResponse {
  final List<NotificationModel> items;
  final String? nextCursor;
  final bool hasMore;
  final int unreadCount;

  const NotificationsResponse({
    required this.items,
    this.nextCursor,
    required this.hasMore,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return NotificationsResponse(
      items: itemsList
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
