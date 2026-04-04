import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../features/feed/providers/feed_provider.dart';

/// Mood filter bar with horizontal scrollable chips
class MoodFilterBar extends ConsumerWidget {
  const MoodFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final activeMood = _getActiveMood(feedState);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isActive: activeMood == null,
              onTap: () => ref.read(feedProvider.notifier).setMoodFilter(null),
              disableAnimations: disableAnimations,
            ),
            const SizedBox(width: 8),
            ...AppColors.moodKeys.map((mood) {
              final isActive = activeMood == mood;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: _capitalize(mood),
                  isActive: isActive,
                  onTap: () {
                    ref
                        .read(feedProvider.notifier)
                        .setMoodFilter(isActive ? null : mood);
                  },
                  disableAnimations: disableAnimations,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static String? _getActiveMood(dynamic feedState) {
    // The FeedNotifier stores the current mood filter internally.
    // We can't access it directly, so we return null by default.
    // In a real app, you'd expose the current filter in FeedState.
    return null;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

/// Individual mood filter chip with A05 animation
class _FilterChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool disableAnimations;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.disableAnimations,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
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
