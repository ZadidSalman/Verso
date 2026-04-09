import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../shared/models/story_model.dart';

enum _NavDirection { forward, backward, none }

/// Story part reader screen with A21 prev/next navigation
class StoryPartScreen extends ConsumerStatefulWidget {
  final String storyId;
  final String partId;

  const StoryPartScreen({
    super.key,
    required this.storyId,
    required this.partId,
  });

  @override
  ConsumerState<StoryPartScreen> createState() => _StoryPartScreenState();
}

class _StoryPartScreenState extends ConsumerState<StoryPartScreen>
    with TickerProviderStateMixin {
  StoryPartModel? _part;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPart();
  }

  Future<void> _loadPart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _fetchPart(widget.storyId, widget.partId);
      if (mounted) {
        setState(() {
          _part = response['part'] as StoryPartModel;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load this part.';
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _fetchPart(String storyId, String partId) async {
    // TODO: Replace with actual API call via repository
    // This is a placeholder — in production, use StoryRepository.getPart()
    throw UnimplementedError('Story API not yet connected');
  }

  void _navigateToPart(String partId) {
    context.go('/story/${widget.storyId}/part/$partId');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(
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
                      _error!,
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
            )
          : _part != null
          ? _buildContent(context, theme, disableAnimations)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool disableAnimations,
  ) {
    final totalParts = _part!.partNumber + 1;
    final hasPrev = _part!.partNumber > 1;
    final hasNext = _part!.partNumber < totalParts;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: LinearProgressIndicator(
                value: _part!.partNumber / (_part!.partNumber + 1),
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
              ),
            ),
            SliverAppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Part ${_part!.partNumber}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _part!.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            if (_part!.coverImageUrl != null)
              SliverToBoxAdapter(
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_part!.coverImageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 160),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppShapes.radiusXs,
                    ),
                    child: Text(
                      'Part ${_part!.partNumber}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _part!.title,
                    style: AppTypography.storyTitle(_part!.language),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceVariant,
                        child: const Icon(Icons.person, size: 16, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _part!.author?.displayName ?? _part!.author?.username ?? 'Unknown',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_part!.publishedAt ?? _part!.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_part!.mood.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final mood in _part!.mood)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.mood(mood).withValues(alpha: 0.12),
                              borderRadius: AppShapes.radiusXs,
                            ),
                            child: Text(
                              mood[0].toUpperCase() + mood.substring(1),
                              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mood(mood)),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Text(
                    _part!.content,
                    style: AppTypography.poemBody(_part!.language).copyWith(height: 1.8),
                  ),
                ]),
              ),
            ),
            SliverFillRemaining(hasScrollBody: false, child: SizedBox.shrink()),
          ],
        ),
        if (!disableAnimations && hasPrev)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 80,
            child: GestureDetector(
              onTap: () => _navigateWithAnimation(context, _part!.partNumber - 1),
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
        if (!disableAnimations && hasNext)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 80,
            child: GestureDetector(
              onTap: () => _navigateWithAnimation(context, _part!.partNumber + 1),
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
        if (!disableAnimations)
          Positioned(
            bottom: 100,
            left: hasPrev ? 16 : 0,
            right: hasNext ? 16 : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasPrev)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.chevron_left, color: AppColors.primary),
                  ),
                if (hasNext)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.chevron_right, color: AppColors.primary),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  void _navigateWithAnimation(BuildContext context, int targetPart) {
    if (targetPart == _part!.partNumber) return;

    // Slide transition to the next/prev part
    final direction = targetPart > _part!.partNumber ? 1.0 : -1.0;
    context.go('/story/${widget.storyId}/part/$targetPart');
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays < 1) return 'today';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
