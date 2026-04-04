import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/models/poem_model.dart';
import '../providers/poem_provider.dart';

/// Poem reader screen — full view of a poem
///
/// Features:
/// - Full poem content with correct typography
/// - Author info with avatar
/// - Language + mood chips
/// - Reaction bar (like, comment, save, share)
/// - A02 heart burst animation on like
/// - A29 save toggle animation
/// - Read tracking (5s dwell)
class PoemReaderScreen extends ConsumerStatefulWidget {
  final String poemId;

  const PoemReaderScreen({super.key, required this.poemId});

  @override
  ConsumerState<PoemReaderScreen> createState() => _PoemReaderScreenState();
}

class _PoemReaderScreenState extends ConsumerState<PoemReaderScreen>
    with TickerProviderStateMixin {
  bool _isLiked = false;
  bool _isSaved = false;
  int _likesCount = 0;
  int _savesCount = 0;

  late AnimationController _heartController;
  late AnimationController _saveController;

  Timer? _readTimer;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: AppDurations.emphasized,
    );
    _saveController = AnimationController(
      vsync: this,
      duration: AppDurations.quick,
    );

    // Start read tracking timer (5 seconds dwell)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ref.read(poemRepositoryProvider).trackRead(widget.poemId);
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    _saveController.dispose();
    _readTimer?.cancel();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
    });

    _heartController.forward(from: 0);
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
      _savesCount = _isSaved ? _savesCount + 1 : _savesCount - 1;
    });
    _saveController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final poemAsync = ref.watch(poemProvider(widget.poemId));
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Implement share
            },
          ),
        ],
      ),
      body: poemAsync.when(
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
                  'Could not find this verse.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
        data: (poem) =>
            _buildPoemContent(context, poem, theme, disableAnimations),
      ),
      bottomNavigationBar: _ReactionBar(
        likesCount: _likesCount,
        commentsCount: 0,
        savesCount: _savesCount,
        isLiked: _isLiked,
        isSaved: _isSaved,
        onLike: _toggleLike,
        onComment: () {},
        onSave: _toggleSave,
        onShare: () {},
        heartController: _heartController,
        saveController: _saveController,
      ),
    );
  }

  Widget _buildPoemContent(
    BuildContext context,
    PoemModel poem,
    ThemeData theme,
    bool disableAnimations,
  ) {
    // Update initial counts from poem data
    if (_likesCount == 0 && poem.likesCount > 0) {
      _likesCount = poem.likesCount;
    }
    if (_savesCount == 0 && poem.savesCount > 0) {
      _savesCount = poem.savesCount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 88),

          // Title
          Text(
                poem.title,
                style: AppTypography.englishPoem.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                  height: 1.3,
                ),
              )
              .animate()
              .fadeIn(
                duration: disableAnimations
                    ? Duration.zero
                    : AppDurations.emphasized,
              )
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Author row
          Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: poem.author?.avatarUrl != null
                        ? NetworkImage(poem.author!.avatarUrl!)
                        : null,
                    child: poem.author?.avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poem.isAnonymous
                            ? 'Anonymous'
                            : (poem.author?.displayName ??
                                  poem.author?.username ??
                                  'Unknown'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!poem.isAnonymous && poem.author?.username != null)
                        Text(
                          '@${poem.author!.username}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(poem.publishedAt ?? poem.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              )
              .animate(delay: disableAnimations ? Duration.zero : 100.ms)
              .fadeIn(
                duration: disableAnimations
                    ? Duration.zero
                    : AppDurations.standard,
              ),

          const SizedBox(height: 16),

          // Mood + Language chips
          SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (poem.mood.isNotEmpty) ...[
                      for (final mood in poem.mood)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mood(
                                mood,
                              ).withValues(alpha: 0.12),
                              borderRadius: AppShapes.radiusXs,
                            ),
                            child: Text(
                              _capitalize(mood),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.mood(mood),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppShapes.radiusXs,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Text(
                        poem.language.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: disableAnimations ? Duration.zero : 200.ms)
              .fadeIn(
                duration: disableAnimations
                    ? Duration.zero
                    : AppDurations.standard,
              ),

          const SizedBox(height: 32),

          // Poem body
          _PoemBody(content: poem.content, language: poem.language)
              .animate(delay: disableAnimations ? Duration.zero : 300.ms)
              .fadeIn(
                duration: disableAnimations
                    ? Duration.zero
                    : AppDurations.emphasized,
              ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays < 1) return 'today';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

/// Poem body with correct typography per language
class _PoemBody extends StatelessWidget {
  final String content;
  final String language;

  const _PoemBody({required this.content, required this.language});

  @override
  Widget build(BuildContext context) {
    final textStyle = language == 'en'
        ? AppTypography.englishPoem.copyWith(fontSize: 18)
        : AppTypography.banglaPoem.copyWith(fontSize: 18);

    // Split content by stanza breaks (───)
    final stanzas = content.split('\n\n───\n\n');

    if (stanzas.length == 1) {
      // No stanza breaks — render as plain text
      return Text(content, style: textStyle.copyWith(height: 1.8));
    }

    // Render each stanza with spacing
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stanzas.map((stanza) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(stanza.trim(), style: textStyle.copyWith(height: 1.8)),
        );
      }).toList(),
    );
  }
}

/// Reaction bar with like, comment, save, share
class _ReactionBar extends StatelessWidget {
  final int likesCount;
  final int commentsCount;
  final int savesCount;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final AnimationController heartController;
  final AnimationController saveController;

  const _ReactionBar({
    required this.likesCount,
    required this.commentsCount,
    required this.savesCount,
    required this.isLiked,
    required this.isSaved,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onShare,
    required this.heartController,
    required this.saveController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Like button with A02 animation
            _LikeButton(
              count: likesCount,
              isActive: isLiked,
              onTap: onLike,
              controller: heartController,
            ),

            // Comment button
            _ActionButton(
              icon: Icons.chat_bubble_outline,
              count: commentsCount,
              onTap: onComment,
            ),

            // Save button with A29 animation
            _SaveButton(
              count: savesCount,
              isActive: isSaved,
              onTap: onSave,
              controller: saveController,
            ),

            // Share button
            _ActionButton(
              icon: Icons.share_outlined,
              count: null,
              onTap: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

/// Like button with A02 heart burst animation
class _LikeButton extends StatelessWidget {
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final AnimationController controller;

  const _LikeButton({
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                  isActive ? Icons.favorite : Icons.favorite_border,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 22,
                )
                .animate(controller: controller)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.4, 1.4),
                  duration: 150.ms,
                  curve: AppCurves.decelerate,
                )
                .then()
                .scale(
                  begin: const Offset(1.4, 1.4),
                  end: const Offset(1, 1),
                  duration: 150.ms,
                  curve: AppCurves.spring,
                ),
            const SizedBox(height: 2),
            Text(
              _formatCount(count),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

/// Save button with A29 animation
class _SaveButton extends StatelessWidget {
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final AnimationController controller;

  const _SaveButton({
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppDurations.quick,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: Tween(begin: 0.7, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: AppCurves.spring),
                  ),
                  child: child,
                );
              },
              child: Icon(
                isActive ? Icons.bookmark : Icons.bookmark_border,
                key: ValueKey(isActive),
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatCount(count),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

/// Reusable action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 22),
            if (count != null) ...[
              const SizedBox(height: 2),
              Text(
                _formatCount(count!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
