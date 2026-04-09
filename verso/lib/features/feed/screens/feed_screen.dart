import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/app_router.dart';
import '../providers/feed_provider.dart';
import '../../../shared/widgets/poem_card.dart';
import '../../../shared/models/poem_model.dart';
import '../../../shared/models/thought_model.dart';
import '../../../shared/widgets/mood_filter_bar.dart';
import '../../../shared/widgets/type_filter_bar.dart';
import '../../../shared/widgets/skeleton_loading.dart';
import '../../../shared/widgets/comment_sheet.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../poem/providers/engagement_provider.dart';
import '../../thought/widgets/thought_composer_sheet.dart';

/// Feed screen — main screen after authentication
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedState = ref.watch(feedProvider);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            pinned: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_note, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Verso',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: const [
              NotificationBell(),
              SizedBox(width: 8),
            ],
          ),

          // Mood filter bar (pinned)
          SliverPersistentHeader(
            pinned: true,
            delegate: _MoodFilterHeaderDelegate(
              child: Container(
                color: AppColors.background,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MoodFilterBar(),
                    const TypeFilterBar(),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Feed content
          if (feedState.isLoading && feedState.items.isEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const FeedSkeletonList(),
              ),
            )
          else if (feedState.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_stories_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'The feed is quiet.',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Perhaps it\'s time to write.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.poemEditor),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Write your first poem'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= feedState.items.length) return null;

                  final item = feedState.items[index];
                  final delay = Duration(
                    milliseconds: index < 8 ? index * 60 : 0,
                  );

                  if (item.type == 'thought') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _ThoughtCard(
                        key: ValueKey(item.id),
                        content: item.content ?? '',
                        author: item.author,
                        likesCount: item.likesCount ?? 0,
                        createdAt: item.createdAt,
                        onLike: () => toggleLike(ref, item.id),
                      ),
                    );
                  }

                  // Convert FeedItem to PoemModel for PoemCard
                  final poem = PoemModel(
                    id: item.id,
                    authorId: item.authorId,
                    author: item.author != null ? PoemAuthor(
                      displayName: item.author?.displayName,
                      username: item.author?.username,
                      avatarUrl: item.author?.avatarUrl,
                      isVerifiedPoet: item.author?.isVerifiedPoet ?? false,
                    ) : null,
                    title: item.title ?? '',
                    content: item.content,
                    slug: item.id,
                    language: item.language,
                    mood: item.mood,
                    tags: item.tags,
                    isAnonymous: false,
                    isUnsent: false,
                    status: item.status ?? 'published',
                    likesCount: item.likesCount ?? 0,
                    commentsCount: item.commentsCount ?? 0,
                    savesCount: 0,
                    readsCount: item.readsCount ?? 0,
                    trendingScore: item.trendingScore,
                    wordCount: 0,
                    lineCount: 0,
                    publishedAt: item.publishedAt,
                    createdAt: item.createdAt,
                    updatedAt: item.updatedAt,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: PoemCard(
                      key: ValueKey(poem.id),
                      poem: poem,
                      onTap: () => context.push('${AppRoutes.poem}/${poem.id}'),
                      onLike: () => toggleLike(ref, poem.id),
                      onComment: () => CommentSheet.show(
                        context,
                        poemId: poem.id,
                        commentCount: poem.commentsCount,
                      ),
                      onShare: () {},
                    ),
                  );
                }, childCount: feedState.items.length),
              ),
            ),

          if (feedState.isLoading && feedState.items.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ThoughtComposerSheet.show(context),
        backgroundColor: AppColors.primary,
        shape: AppShapes.xl,
        child: const Icon(Icons.edit_outlined, color: AppColors.surface),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.feed);
              break;
            case 1:
              context.push(AppRoutes.discover);
              break;
            case 2:
              context.push(AppRoutes.poemEditor);
              break;
            case 3:
              context.push(AppRoutes.messages);
              break;
            case 4:
              context.push(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Write',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Sliver delegate for the pinned mood filter bar
class _MoodFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _MoodFilterHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 96;

  @override
  double get minExtent => 96;

  @override
  bool shouldRebuild(_MoodFilterHeaderDelegate oldDelegate) => false;
}

/// Thought card for the feed
class _ThoughtCard extends StatelessWidget {
  final String content;
  final PoemAuthor? author;
  final int likesCount;
  final DateTime createdAt;
  final VoidCallback? onLike;

  const _ThoughtCard({
    super.key,
    required this.content,
    this.author,
    required this.likesCount,
    required this.createdAt,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.radiusMd,
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Author + timestamp
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: author?.avatarUrl != null
                    ? NetworkImage(author!.avatarUrl!)
                    : null,
                child: author?.avatarUrl == null
                    ? Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author?.displayName ?? author?.username ?? 'Unknown',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (author?.username != null)
                      Text(
                        '@${author!.username}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                _formatTimestamp(createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          // Thought content
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          // Actions
          Row(
            children: [
              _ActionButton(
                icon: Icons.favorite_border,
                label: likesCount.toString(),
                onTap: onLike,
                color: AppColors.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? AppColors.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.radiusXs,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: effectiveColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}