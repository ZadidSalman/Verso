import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';
import '../../../shared/models/notification_model.dart';

/// Provider for NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Notifications provider with pagination
class NotificationListNotifier extends AsyncNotifier<NotificationsResponse> {
  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  @override
  Future<NotificationsResponse> build() async {
    return _repository.getNotifications();
  }

  /// Load more notifications
  Future<void> loadMore() async {
    if (!state.hasValue) return;
    final current = state.value!;
    if (!current.hasMore || current.nextCursor == null) return;

    state = AsyncData(current.copyWith(isLoading: true));
    final response = await _repository.getNotifications(
      cursor: current.nextCursor,
    );
    state = AsyncData(
      NotificationsResponse(
        items: [...current.items, ...response.items],
        nextCursor: response.nextCursor,
        hasMore: response.hasMore,
        unreadCount: current.unreadCount,
      ),
    );
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    ref.invalidateSelf();
  }

  /// Mark single as read
  Future<void> markAsRead(String notificationId) async {
    await _repository.markAsRead(notificationId);
    ref.invalidateSelf();
  }
}

final notificationListProvider =
    AsyncNotifierProvider<NotificationListNotifier, NotificationsResponse>(
      NotificationListNotifier.new,
    );

/// Extension for copyWith on NotificationsResponse
extension _NotificationsResponseCopyWith on NotificationsResponse {
  NotificationsResponse copyWith({
    List<NotificationModel>? items,
    String? nextCursor,
    bool? hasMore,
    int? unreadCount,
    bool isLoading = false,
  }) {
    return NotificationsResponse(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
