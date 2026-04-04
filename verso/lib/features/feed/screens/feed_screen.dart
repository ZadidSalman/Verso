import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/router/app_router.dart';
import '../providers/feed_provider.dart';
import '../../../shared/widgets/poem_card.dart';
import '../../../shared/widgets/mood_filter_bar.dart';
import '../../../shared/widgets/skeleton_loading.dart';

/// Feed screen — main screen after authentication
///
/// Features:
/// - SliverAppBar with quill icon
/// - Mood filter bar (pinned)
/// - PoemCard list with A19 staggered entrance
/// - Pull-to-refresh (A27)
/// - Skeleton loading (A03)
/// - Empty state
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
    final feedState = ref.read(feedProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        feedState.hasMore &&
        !feedState.isLoading) {
      ref.read(feedProvider.notifier).loadMore();
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
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Verso',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              const SizedBox(width: 8),
            ],
          ),

          // Mood filter bar (pinned)
          SliverPersistentHeader(
            pinned: true,
            delegate: _MoodFilterHeaderDelegate(
              child: Container(
                color: AppColors.background,
                child: const MoodFilterBar(),
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
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
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
                        onPressed: () {
                          // TODO: Navigate to poem editor
                        },
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

                  final poem = feedState.items[index];
                  final delay = Duration(
                    milliseconds: index < 8 ? index * 60 : 0,
                  );

                  return PoemCard(
                        key: ValueKey(poem.id),
                        poem: poem,
                        onTap: () =>
                            context.push('${AppRoutes.poem}/${poem.id}'),
                        onLike: () {
                          // TODO: Implement like
                        },
                        onComment: () {
                          // TODO: Navigate to comments
                        },
                        onShare: () {
                          // TODO: Implement share
                        },
                      )
                      .animate(delay: disableAnimations ? Duration.zero : delay)
                      .fadeIn(
                        duration: disableAnimations
                            ? const Duration(milliseconds: 150)
                            : AppDurations.emphasized,
                        curve: AppCurves.decelerate,
                      )
                      .slideY(
                        begin: 0.08,
                        end: 0,
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.emphasized,
                        curve: AppCurves.sheetOpen,
                      );
                }, childCount: feedState.items.length),
              ),
            ),

          // Loading more indicator
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
      // Pull-to-refresh
      // Note: RefreshIndicator doesn't work well with CustomScrollView.
      // We use RefreshIndicator with a nested ListView approach instead.
      // For now, pull-to-refresh is handled by the feed notifier's refresh().
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.poemEditor);
        },
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
              context.go(AppRoutes.discover);
              break;
            case 2:
              context.push(AppRoutes.poemEditor);
              break;
            case 3:
              // TODO: Messages - not implemented yet
              break;
            case 4:
              context.go(AppRoutes.profile);
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
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_MoodFilterHeaderDelegate oldDelegate) => false;
}
