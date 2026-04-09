import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../features/feed/providers/feed_provider.dart';

class TypeFilterBar extends ConsumerWidget {
  const TypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _TypeChip(
              label: 'All',
              isActive: feedState.typeFilter == null,
              onTap: () => ref.read(feedProvider.notifier).setTypeFilter(null),
              disableAnimations: disableAnimations,
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label: 'Poems',
              isActive: feedState.typeFilter == 'poems',
              onTap: () => ref.read(feedProvider.notifier).setTypeFilter('poems'),
              disableAnimations: disableAnimations,
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label: 'Stories',
              isActive: feedState.typeFilter == 'stories',
              onTap: () => ref.read(feedProvider.notifier).setTypeFilter('stories'),
              disableAnimations: disableAnimations,
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label: 'Thoughts',
              isActive: feedState.typeFilter == 'thoughts',
              onTap: () => ref.read(feedProvider.notifier).setTypeFilter('thoughts'),
              disableAnimations: disableAnimations,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool disableAnimations;

  const _TypeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.disableAnimations,
  });

  @override
  State<_TypeChip> createState() => _TypeChipState();
}

class _TypeChipState extends State<_TypeChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActive = widget.isActive && !_isPressed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: widget.disableAnimations ? Duration.zero : AppDurations.quick,
        curve: AppCurves.standard,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: effectiveActive
              ? AppColors.secondaryContainer
              : AppColors.surfaceVariant,
          borderRadius: AppShapes.radiusXs,
          border: effectiveActive
              ? null
              : Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: effectiveActive ? AppColors.primary : AppColors.outline,
            fontWeight: effectiveActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}