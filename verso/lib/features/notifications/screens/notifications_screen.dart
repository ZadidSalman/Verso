import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../providers/notification_provider.dart';

/// Notifications screen with A19 staggered entrance
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationListProvider);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Alerts',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationListProvider.notifier).markAllAsRead(),
            child: Text(
              'Mark all read',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load your alerts.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => ref.invalidate(notificationListProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (response) {
          if (response.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: AppColors.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The night is quiet.\nNo one has knocked yet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationListProvider.future),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: response.items.length + (response.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= response.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  );
                }

                final notification = response.items[index];
                final delay = Duration(
                  milliseconds: index < 8 ? index * 60 : 0,
                );

                return _NotificationListItem(
                  notification: notification,
                  onTap: () => _onNotificationTap(context, notification),
                  onMarkRead: () => ref
                      .read(notificationListProvider.notifier)
                      .markAsRead(notification.id),
                  delay: disableAnimations ? Duration.zero : delay,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _onNotificationTap(BuildContext context, dynamic notification) {
    // Navigate to relevant content based on entityType
    switch (notification.entityType) {
      case 'poem':
        context.push('/poem/${notification.entityId}');
        break;
      case 'story':
        context.push('/story/${notification.entityId}');
        break;
      case 'storyPart':
        // Navigate to story part
        break;
      case 'comment':
        // Navigate to comment
        break;
      default:
        // Navigate to actor's profile
        context.push('/user/${notification.actor?.username}');
    }
  }
}

/// Notification list item with A19 staggered entrance
class _NotificationListItem extends StatelessWidget {
  final dynamic notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final Duration delay;

  const _NotificationListItem({
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = notification.isRead == false;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.check, color: AppColors.primary),
      ),
      onDismissed: (_) => onMarkRead(),
      child: Material(
        color: isUnread ? AppColors.surfaceVariant : AppColors.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread indicator
                if (isUnread)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, right: 8),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 8),

                // Avatar with type icon
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.surfaceVariant,
                      backgroundImage: notification.actor?.avatarUrl != null
                          ? NetworkImage(notification.actor!.avatarUrl!)
                          : null,
                      child: notification.actor?.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 20,
                              color: AppColors.onSurfaceVariant,
                            )
                          : null,
                    ),
                    // Type icon badge
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _badgeColor(notification.type),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          notification.type.icon,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  notification.actor?.displayName ??
                                  notification.actor?.username ??
                                  'Someone',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: ' ${notification.poeticMessage}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(notification.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _badgeColor(String type) {
    switch (type) {
      case 'poem_liked':
      case 'storyPart_liked':
      case 'thought_reacted':
        return AppColors.primary;
      case 'new_follower':
        return AppColors.secondary;
      case 'comment':
      case 'comment_story':
        return AppColors.tertiary;
      case 'duel_invite':
      case 'duel_result':
        return AppColors.error;
      default:
        return AppColors.outline;
    }
  }

  String _formatTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
