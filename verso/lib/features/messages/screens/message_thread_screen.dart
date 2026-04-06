import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/poem_share_card.dart';
import '../providers/message_provider.dart';
import '../../../shared/models/message_model.dart';

/// Message thread screen with A24 send animation
class MessageThreadScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const MessageThreadScreen({super.key, required this.conversationId});

  @override
  ConsumerState<MessageThreadScreen> createState() =>
      _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _sendController;
  bool _isSending = false;
  bool _isOtherTyping = false;

  @override
  void initState() {
    super.initState();
    _sendController = AnimationController(
      vsync: this,
      duration: AppDurations.standard,
    );
    // Mark as read on open
    ref.read(messageRepositoryProvider).markAsRead(widget.conversationId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _sendController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: AppDurations.standard,
        curve: AppCurves.decelerate,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _sendController.forward(from: 0);

    final content = _controller.text.trim();
    _controller.clear();

    try {
      await sendMessageAction(
        ref,
        widget.conversationId,
        content,
      );
      _scrollToBottom();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The words could not be sent. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final noMotion = reducedMotion(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(
                Icons.person,
                size: 20,
                color: AppColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Poet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isOtherTyping)
                  Text(
                    'writing...',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stack) => Center(
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
                      'The pages are torn. Try again.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () =>
                          ref.refresh(messagesProvider(widget.conversationId)),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Say hello.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: messages.length + (_isOtherTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isOtherTyping && index == 0) {
                      return const _TypingIndicator();
                    }

                    final messageIndex = _isOtherTyping ? index - 1 : index;
                    final message = messages[messageIndex];
                    final isOwn =
                        message.senderId ==
                        'current-user-id'; // TODO: Get from auth
                    final nextMessage = messageIndex > 0
                        ? messages[messageIndex - 1]
                        : null;
                    final isFirst =
                        nextMessage == null ||
                        nextMessage.senderId != message.senderId;

                    return _MessageBubble(
                      message: message,
                      isOwn: isOwn,
                      isFirst: isFirst,
                      isNew: messageIndex == 0 && !noMotion,
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Say something...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: AppShapes.radiusSm,
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: AnimatedBuilder(
                      animation: _sendController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _sendController.value * 2 * 3.14159,
                          child: child,
                        );
                      },
                      child: FilledButton(
                        onPressed: _isSending ? null : _sendMessage,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: Icon(
                          _isSending ? Icons.hourglass_empty : Icons.send,
                          size: 18,
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Typing indicator with animated dots
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress =
                      (_controller.value + index * 0.2) % 1.0;
                  final scale = 0.6 + 0.4 * (0.5 + 0.5 * math.sin(progress * 2 * math.pi));
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 6,
                      height: 6,
                      margin: EdgeInsets.only(
                        right: index < 2 ? 4 : 0,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Message bubble with A24 animation for new messages
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isOwn;
  final bool isFirst;
  final bool isNew;

  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.isFirst,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget bubble;

    if (message.type == 'poemShare') {
      // Parse poem data from content (format: "poemId|title|excerpt|author")
      final parts = message.content.split('|');
      if (parts.length >= 4) {
        bubble = PoemShareCard(
          poemId: parts[0],
          title: parts[1],
          excerpt: parts[2],
          authorName: parts[3],
        );
      } else {
        bubble = _buildTextBubble(context);
      }
    } else {
      bubble = _buildTextBubble(context);
    }

    if (isNew && !disableAnimations) {
      bubble = bubble
          .animate()
          .slideY(
            begin: 0.3,
            end: 0,
            duration: AppDurations.standard,
            curve: AppCurves.decelerate,
          )
          .fadeIn(duration: AppDurations.quick);
    }

    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 8 : 2,
        bottom: 2,
        left: isOwn ? 64 : 0,
        right: isOwn ? 0 : 64,
      ),
      child: Align(
        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
        child: bubble,
      ),
    );
  }

  Widget _buildTextBubble(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = _formatTime(message.sentAt);

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOwn ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isOwn ? 16 : 4),
          bottomRight: Radius.circular(isOwn ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isOwn ? AppColors.surface : AppColors.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeStr,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isOwn
                      ? AppColors.surface.withValues(alpha: 0.7)
                      : AppColors.onSurfaceVariant,
                ),
              ),
              if (isOwn) ...[
                const SizedBox(width: 4),
                Icon(
                  message.readBy.isNotEmpty
                      ? Icons.done_all
                      : Icons.done,
                  size: 12,
                  color: message.readBy.isNotEmpty
                      ? AppColors.primaryContainer
                      : AppColors.surface.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
