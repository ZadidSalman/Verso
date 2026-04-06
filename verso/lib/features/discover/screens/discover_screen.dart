import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/poem_card.dart';
import '../../feed/providers/feed_provider.dart';

/// Discover screen — explore trending poems, moods, writers
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String _languageFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedState = ref.watch(feedProvider);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Discover',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ],
          ),

          // Language toggle
          SliverPersistentHeader(
            pinned: true,
            delegate: _LanguageToggleDelegate(
              language: _languageFilter,
              onChanged: (lang) => setState(() => _languageFilter = lang),
            ),
          ),

          // Trending Poems section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Trending',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Trending poems horizontal list
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: feedState.isLoading && feedState.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : feedState.items.isEmpty
                  ? Center(
                      child: Text(
                        'No trending poems yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: feedState.items.length > 10
                          ? 10
                          : feedState.items.length,
                      itemBuilder: (context, index) {
                        final poem = feedState.items[index];
                        return Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              margin: const EdgeInsets.only(right: 12),
                              child: PoemCard(
                                poem: poem,
                                onTap: () => context.push(
                                  '${AppRoutes.poem}/${poem.id}',
                                ),
                              ),
                            )
                            .animate(
                              delay: disableAnimations
                                  ? Duration.zero
                                  : Duration(milliseconds: index * 50),
                            )
                            .fadeIn(
                              duration: disableAnimations
                                  ? Duration.zero
                                  : AppDurations.standard,
                            );
                      },
                    ),
            ),
          ),

          // Mood Collections section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Moods',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppColors.moodKeys.map((mood) {
                  final moodColor = AppColors.mood(mood);
                  return InkWell(
                    onTap: () {
                      ref.read(feedProvider.notifier).setMoodFilter(mood);
                      context.go(AppRoutes.feed);
                    },
                    borderRadius: AppShapes.radiusSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: moodColor.withValues(alpha: 0.12),
                        borderRadius: AppShapes.radiusSm,
                        border: Border.all(
                          color: moodColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: moodColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _capitalize(mood),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: moodColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Writers to Follow section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Writers to Follow',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppShapes.radiusMd,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.person,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Poet ${index + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '@poet${index + 1}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                      .animate(
                        delay: disableAnimations
                            ? Duration.zero
                            : Duration(milliseconds: index * 50),
                      )
                      .fadeIn(
                        duration: disableAnimations
                            ? Duration.zero
                            : AppDurations.standard,
                      );
                },
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

/// Language toggle delegate for pinned header
class _LanguageToggleDelegate extends SliverPersistentHeaderDelegate {
  final String language;
  final ValueChanged<String> onChanged;

  _LanguageToggleDelegate({required this.language, required this.onChanged});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _ToggleChip(
            label: 'All',
            isActive: language == 'all',
            onTap: () => onChanged('all'),
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: 'English',
            isActive: language == 'en',
            onTap: () => onChanged('en'),
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: 'বাংলা',
            isActive: language == 'bn',
            onTap: () => onChanged('bn'),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_LanguageToggleDelegate oldDelegate) =>
      language != oldDelegate.language;
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.quick,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryContainer
              : AppColors.surfaceVariant,
          borderRadius: AppShapes.radiusSm,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
