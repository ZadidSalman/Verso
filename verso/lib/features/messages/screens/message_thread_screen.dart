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

  @override
  void initState() {
    super.initState();
    _sendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _sendController.forward(from: 0);

    try {
      await sendMessageAction(
        ref,
        widget.conversationId,
        _controller.text.trim(),
      );
      _controller.clear();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send message.')),
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
              backgroundColor: AppColors.surfaceVariant,
              child: Icon(
                Icons.person,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Poet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
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
                child: Text(
                  'Could not load messages.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
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
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isOwn =
                        message.senderId ==
                        'current-user-id'; // TODO: Get from auth
                    final isFirst =
                        index == 0 ||
                        messages[index - 1].senderId != message.senderId;

                    return _MessageBubble(
                      message: message,
                      isOwn: isOwn,
                      isFirst: isFirst,
                      isNew: index == 0,
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
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
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
                  const SizedBox(width: 4),
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
                        child: const Icon(
                          Icons.send,
                          size: 18,
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

    Widget bubble = Container(
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
      child: Text(
        message.content,
        style: TextStyle(
          color: isOwn ? AppColors.surface : AppColors.onSurface,
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );

    if (isNew && !disableAnimations) {
      bubble = bubble
          .animate()
          .scale(
            begin: const Offset(0.6, 0.6),
            duration: const Duration(milliseconds: 200),
            curve: AppCurves.spring,
          )
          .fadeIn(duration: const Duration(milliseconds: 150));
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
}
