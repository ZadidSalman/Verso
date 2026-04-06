import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/router/app_router.dart';
import '../providers/message_provider.dart';
import '../../../shared/models/message_model.dart';

/// Messages list screen — conversation list
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final convosAsync = ref.watch(conversationsProvider);
    final noMotion = reducedMotion(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Messages',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showNewConversation(context, ref),
          ),
        ],
      ),
      body: convosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'The ink has dried. Try again.',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref.refresh(conversationsProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (convos) {
          if (convos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_outlined,
                      size: 64,
                      color: AppColors.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No conversations yet.\nSend your first word.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => _showNewConversation(context, ref),
                      child: const Text('Start a conversation'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: convos.length,
            itemBuilder: (context, index) {
              final convo = convos[index];
              return _ConversationListItem(
                conversation: convo,
                onTap: () => context.push('${AppRoutes.messages}/${convo.id}'),
                index: index,
                noMotion: noMotion,
              ).animate(
                delay: Duration(milliseconds: index * 50),
              ).slideY(
                begin: 0.15,
                end: 0,
                duration: AppDurations.emphasized,
                curve: AppCurves.standard,
              ).fadeIn(
                duration: AppDurations.standard,
              );
            },
          );
        },
      ),
    );
  }

  void _showNewConversation(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: AppShapes.sheet,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: AppShapes.radiusXs,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Text(
                    'Find a poet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search poets...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(
                        borderRadius: AppShapes.radiusSm,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Search for a poet to start messaging.',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Conversation list item with staggered entrance A19
class _ConversationListItem extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;
  final int index;
  final bool noMotion;

  const _ConversationListItem({
    required this.conversation,
    required this.onTap,
    required this.index,
    required this.noMotion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = conversation.unreadCount > 0;
    final hasAvatar = conversation.otherUser?.avatarUrl != null;

    return Dismissible(
      key: ValueKey(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.errorContainer,
        child: const Icon(Icons.archive_outlined, color: AppColors.error),
      ),
      confirmDismiss: (direction) async {
        // TODO: Archive conversation
        return false;
      },
      child: Material(
        color: isUnread ? AppColors.surfaceVariant : AppColors.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: hasAvatar
                      ? NetworkImage(conversation.otherUser!.avatarUrl!)
                      : null,
                  child: hasAvatar
                      ? null
                      : const Icon(
                          Icons.person,
                          color: AppColors.onPrimaryContainer,
                        ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.otherUser?.id ?? 'Poet',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(conversation.lastMessageAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isUnread
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                              fontWeight: isUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage.isEmpty
                                  ? 'A blank page awaits...'
                                  : conversation.lastMessage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: isUnread
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                fontStyle: conversation.lastMessage.isEmpty
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Unread badge
                if (isUnread)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        conversation.unreadCount > 9
                            ? '9+'
                            : '${conversation.unreadCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}';
  }
}
