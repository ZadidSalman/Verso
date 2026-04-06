import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_animations.dart';
import '../../features/social/providers/follow_provider.dart';

/// Follow button with A26 state morph animation
/// Morphs width, text, and color between "Follow" and "Following" states
class FollowButton extends ConsumerStatefulWidget {
  final String userId;

  const FollowButton({super.key, required this.userId});

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _morphController;
  late Animation<double> _scaleAnimation;
  bool _wasFollowing = false;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: AppDurations.emphasized,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _morphController,
      curve: AppCurves.spring,
    ));
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  void _onTap() {
    _morphController.forward(from: 0);
    ref.read(followToggleProvider(widget.userId))();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final followAsync = ref.watch(followProvider(widget.userId));
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
          onPressed: () => ref.read(followToggleProvider(widget.userId))(),
          style: FilledButton.styleFrom(shape: AppShapes.sm),
          child: const Text('Retry'),
        ),
      ),
      data: (follow) {
        final isFollowing = follow.isFollowing;

        if (!disableAnimations && _wasFollowing != isFollowing) {
          _wasFollowing = isFollowing;
          _morphController.forward(from: 0);
        }

        final targetWidth = isFollowing ? 130.0 : 100.0;
        final bgColor =
            isFollowing ? AppColors.surfaceVariant : AppColors.primary;
        final borderColor = isFollowing ? AppColors.outline : null;
        final icon = isFollowing ? Icons.person : Icons.person_add_outlined;
        final iconColor =
            isFollowing ? AppColors.onSurface : AppColors.surface;
        final label = isFollowing ? 'Following' : 'Follow';
        final labelColor =
            isFollowing ? AppColors.onSurface : AppColors.surface;

        return GestureDetector(
          onTap: _onTap,
          child: AnimatedContainer(
            duration: disableAnimations ? Duration.zero : AppDurations.emphasized,
            curve: AppCurves.standard,
            height: 40,
            width: disableAnimations ? targetWidth : null,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppShapes.radiusSm,
              border: borderColor != null
                  ? Border.all(color: borderColor)
                  : null,
            ),
            child: disableAnimations
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: iconColor),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: labelColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : AnimatedSwitcher(
                    duration: AppDurations.emphasized,
                    switchInCurve: AppCurves.spring,
                    switchOutCurve: AppCurves.standard,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      key: ValueKey(isFollowing),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 18, color: iconColor),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: labelColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
