import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_animations.dart';
import '../../features/social/providers/follow_provider.dart';

/// Follow button with A26 state morph animation
class FollowButton extends ConsumerWidget {
  final String userId;

  const FollowButton({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final followAsync = ref.watch(followProvider(userId));
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return followAsync.when(
      loading: () => SizedBox(
        height: 40,
        width: 120,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      error: (_, __) => SizedBox(
        height: 40,
        child: FilledButton.tonal(
          onPressed: () => ref.read(followToggleProvider(userId))(),
          style: FilledButton.styleFrom(shape: AppShapes.sm),
          child: const Text('Retry'),
        ),
      ),
      data: (follow) {
        final isFollowing = follow.isFollowing;

        return GestureDetector(
          onTap: () => ref.read(followToggleProvider(userId))(),
          child: AnimatedContainer(
            duration: disableAnimations ? Duration.zero : AppDurations.standard,
            curve: AppCurves.standard,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isFollowing ? AppColors.surfaceVariant : AppColors.primary,
              borderRadius: AppShapes.radiusSm,
              border: isFollowing ? Border.all(color: AppColors.outline) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: disableAnimations
                      ? Duration.zero
                      : AppDurations.quick,
                  child: Icon(
                    isFollowing ? Icons.person : Icons.person_add_outlined,
                    key: ValueKey(isFollowing),
                    size: 18,
                    color: isFollowing
                        ? AppColors.onSurface
                        : AppColors.surface,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: disableAnimations
                      ? Duration.zero
                      : AppDurations.quick,
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    key: ValueKey(isFollowing),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isFollowing
                          ? AppColors.onSurface
                          : AppColors.surface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
