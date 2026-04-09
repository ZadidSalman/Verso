import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_shapes.dart';
import '../../shared/models/poem_model.dart';

/// PoemCard Variant A — with mood left border
class PoemCard extends StatelessWidget {
  final PoemModel poem;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PoemCard({
    super.key,
    required this.poem,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryMood = poem.mood.isNotEmpty ? poem.mood.first : '';
    final moodColor = AppColors.mood(primaryMood);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppShapes.radiusMd,
          border: Border(
            left: BorderSide(color: moodColor.withValues(alpha: 0.8), width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Author + timestamp
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: poem.author?.avatarUrl != null
                        ? NetworkImage(poem.author!.avatarUrl!)
                        : null,
                    child: poem.author?.avatarUrl == null
                        ? Icon(
                            Icons.person_outline,
                            size: 20,
                            color: AppColors.onSurfaceVariant,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  // Author info
                  Expanded(
                    child: Column(
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!poem.isAnonymous && poem.author?.username != null)
                          Text(
                            '@${poem.author!.username}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Timestamp
                  Text(
                    _formatTimestamp(poem.publishedAt ?? poem.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // More options
                  IconButton(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.space2),

              // Mood + Language chips
              Row(
                children: [
                  if (poem.mood.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: moodColor.withValues(alpha: 0.12),
                        borderRadius: AppShapes.radiusXs,
                      ),
                      child: Text(
                        _capitalize(primaryMood),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: moodColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (poem.mood.isNotEmpty) const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppShapes.radiusXs,
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      poem.language.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.space2),

              // Title
              Text(
                poem.title,
                style: AppTypography.poemTitle(poem.language),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.space1),

              // Content preview
              Text(
                poem.content ?? '',
                style: AppTypography.poemPreview(poem.language),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.space3),

              // Divider
              Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),

              const SizedBox(height: AppSpacing.space2),

              // Action bar
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.favorite_border,
                    count: poem.likesCount,
                    onTap: onLike,
                  ),
                  const SizedBox(width: AppSpacing.space4),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    count: poem.commentsCount,
                    onTap: onComment,
                  ),
                  const SizedBox(width: AppSpacing.space4),
                  _ActionButton(
                    icon: Icons.visibility_outlined,
                    count: poem.readsCount,
                    onTap: null,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 18),
                    onPressed: onShare,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

/// Reusable action button with icon + count
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.radiusXs,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
