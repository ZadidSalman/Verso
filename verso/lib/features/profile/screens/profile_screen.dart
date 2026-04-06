import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../feed/providers/feed_provider.dart';
import '../../../shared/widgets/poem_card.dart';
import '../../../shared/widgets/follow_button.dart';

/// Profile screen — shows user info, stats, tabs
class ProfileScreen extends ConsumerStatefulWidget {
  final String? username; // null = own profile, string = other user's profile

  const ProfileScreen({super.key, this.username});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final feedState = ref.watch(feedProvider);
    final isOwnProfile = widget.username == null;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    // Get user info
    final user = isOwnProfile && authState is AuthAuthenticated
        ? authState.user
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Sliver App Bar with cover
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.3),
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                    // Gradient scrim
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    // Profile avatar overlapping cover (like FB/LinkedIn)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0, 40),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.surfaceVariant,
                              backgroundImage: user?.avatarUrl != null
                                  ? NetworkImage(user!.avatarUrl!)
                                  : null,
                              child: user?.avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColors.onSurfaceVariant,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Edit button for own profile
                    if (isOwnProfile)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 12,
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surface.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // User info section (reduced top margin since avatar overlaps)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
                child: Column(
                  children: [
                    // Name
                    Text(
                      user?.displayName ?? user?.username ?? 'Poet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (user?.username != null)
                      Text(
                        '@${user!.username}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Bio placeholder
                    Text(
                      'Writing poetry to express my thoughts and feelings.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(label: 'Poems', count: '12'),
                        _StatColumn(label: 'Followers', count: '234'),
                        _StatColumn(label: 'Following', count: '89'),
                      ],
                    ),
                    const SizedBox(height: 16),
                      // Action buttons
                      if (!isOwnProfile)
                        Row(
                          children: [
                            Expanded(
                              child: FollowButton(
                                userId: 'placeholder-user-id',
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.message_outlined),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_horiz),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surfaceVariant,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  shape: AppShapes.sm,
                                ),
                                child: const Text('Edit Profile'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.share_outlined),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(tabController: _tabController),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Poems tab
            _PoemsTab(
              feedState: feedState,
              disableAnimations: disableAnimations,
            ),
            // Stories tab
            Center(
              child: Text(
                'No stories yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            // Thoughts tab
            Center(
              child: Text(
                'No thoughts yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            // Liked tab
            _PoemsTab(
              feedState: feedState,
              disableAnimations: disableAnimations,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String count;

  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          count,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PoemsTab extends StatelessWidget {
  final dynamic feedState;
  final bool disableAnimations;

  const _PoemsTab({required this.feedState, required this.disableAnimations});

  @override
  Widget build(BuildContext context) {
    final items = feedState.items as List;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 48,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No poems yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Write your first poem to see it here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final poem = items[index];
        return AnimatedContainer(
          duration: disableAnimations ? Duration.zero : AppDurations.emphasized,
          child: PoemCard(
            poem: poem,
            onTap: () => context.push('${AppRoutes.poem}/${poem.id}'),
          ),
        );
      },
    );
  }
}

/// Tab bar delegate for pinned tabs
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabBarDelegate({required this.tabController});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        tabs: const [
          Tab(text: 'Poems'),
          Tab(text: 'Stories'),
          Tab(text: 'Thoughts'),
          Tab(text: 'Liked'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
