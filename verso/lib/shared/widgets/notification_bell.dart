import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/router/app_router.dart';

/// Bell icon with A13 bounce animation and unread badge
class NotificationBell extends ConsumerStatefulWidget {
  const NotificationBell({super.key});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellController;
  late Animation<double> _bellRotation;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bellRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.033), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.033, end: -0.033), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.033, end: 0.033), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.033, end: -0.033), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.033, end: 0.0), weight: 1),
    ]).animate(_bellController);
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  void _onTap() {
    _bellController.forward(from: 0);
    context.push(AppRoutes.notifications);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual unread count from notification provider
    const unreadCount = 3;

    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          RotationTransition(
            turns: _bellRotation,
            child: const Icon(Icons.notifications_outlined, size: 24),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -2,
              right: -4,
              child:
                  Container(
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: theme.textTheme.labelExtraSmall?.copyWith(
                            color: AppColors.surface,
                          ),
                        ),
                      )
                      .animate(key: ValueKey(unreadCount))
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        duration: const Duration(milliseconds: 200),
                        curve: AppCurves.spring,
                      ),
            ),
        ],
      ),
    );
  }
}
