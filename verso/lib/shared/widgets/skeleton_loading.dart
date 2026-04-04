import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';

/// Shimmer skeleton rectangle for loading placeholders
class ShimmerRect extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerRect({
    super.key,
    required this.width,
    required this.height,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.outlineVariant,
            borderRadius: BorderRadius.circular(radius),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: AppDurations.shimmer,
          color: Colors.white.withValues(alpha: 0.65),
          angle: 0.0,
          stops: const [0.0, 0.5, 1.0],
        );
  }
}

/// Skeleton loading card that mimics PoemCard layout
class PoemCardSkeleton extends StatelessWidget {
  const PoemCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.radiusMd,
        border: Border(
          left: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.8),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + author row
          Row(
            children: [
              const ShimmerRect(width: 40, height: 40, radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerRect(width: 120, height: 14, radius: 4),
                    const SizedBox(height: 4),
                    const ShimmerRect(width: 80, height: 12, radius: 4),
                  ],
                ),
              ),
              const ShimmerRect(width: 40, height: 12, radius: 4),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          const ShimmerRect(width: double.infinity, height: 20, radius: 4),
          const SizedBox(height: 8),
          // Content lines
          const ShimmerRect(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 4),
          const ShimmerRect(width: 240, height: 14, radius: 4),
          const SizedBox(height: 4),
          const ShimmerRect(width: 200, height: 14, radius: 4),
          const SizedBox(height: 12),
          // Action bar
          Row(
            children: [
              const ShimmerRect(width: 48, height: 12, radius: 4),
              const SizedBox(width: 16),
              const ShimmerRect(width: 48, height: 12, radius: 4),
              const SizedBox(width: 16),
              const ShimmerRect(width: 48, height: 12, radius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// List of 3 shimmer cards for feed loading state
class FeedSkeletonList extends StatelessWidget {
  const FeedSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const PoemCardSkeleton();
      },
    );
  }
}
