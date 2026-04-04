import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/duel_model.dart';
import '../providers/duel_provider.dart';

/// Duel screen with A11 vote ripple and A12 live poll fill
class DuelScreen extends ConsumerStatefulWidget {
  final String duelId;

  const DuelScreen({super.key, required this.duelId});

  @override
  ConsumerState<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends ConsumerState<DuelScreen> {
  String? _lastVoteTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duelAsync = ref.watch(duelProvider(widget.duelId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gavel, size: 18, color: AppColors.secondary),
            const SizedBox(width: 6),
            Text(
              'Duel',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: duelAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'This duel has ended.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
        data: (duel) => _buildContent(context, duel, theme),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DuelModel duel, ThemeData theme) {
    final hasVoted = duel.hasVoted('current-user-id'); // TODO: Get from auth

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              borderRadius: AppShapes.radiusXs,
            ),
            child: Text(
              'Theme: ${duel.theme}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.tertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Status + Live pill
          Row(
            children: [
              _StatusChip(status: duel.status),
              if (duel.status == 'active') ...[
                const SizedBox(width: 8),
                _LivePill(),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Two columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PoetColumn(
                  label: 'Challenger',
                  color: AppColors.primary,
                  percent: duel.challengerPercent / 100,
                  votes: duel.votesForChallenger,
                  lastVoteTime: _lastVoteTime,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PoetColumn(
                  label: 'Challengee',
                  color: AppColors.secondary,
                  percent: duel.challengeePercent / 100,
                  votes: duel.votesForChallengee,
                  lastVoteTime: _lastVoteTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Vote button
          if (duel.status == 'active')
            SizedBox(
              width: double.infinity,
              height: 48,
              child: hasVoted
                  ? OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outlineVariant),
                        shape: AppShapes.sm,
                      ),
                      child: Text(
                        'Voted',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : FilledButton(
                      onPressed: () {
                        // TODO: Show vote dialog
                        setState(
                          () => _lastVoteTime = DateTime.now().toString(),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: AppShapes.sm,
                      ),
                      child: Text(
                        'Cast your vote',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                    ),
            ),

          if (duel.status == 'pending')
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.tonal(
                onPressed: () {
                  // TODO: Accept duel
                },
                style: FilledButton.styleFrom(shape: AppShapes.sm),
                child: const Text('Accept this duel'),
              ),
            ),

          if (duel.status == 'completed')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: AppShapes.radiusMd,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'The readers have spoken.\nThis duel is complete.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Timer
          if (duel.status == 'active' && duel.endsAt != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Ends ${_formatTimeRemaining(duel.endsAt!)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          // Total votes
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${duel.totalVotes} votes cast',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRemaining(DateTime endsAt) {
    final diff = endsAt.difference(DateTime.now());
    if (diff.isNegative) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inDays}d ${diff.inHours % 24}h';
  }
}

/// Poet column with A11 animated progress bar
class _PoetColumn extends StatelessWidget {
  final String label;
  final Color color;
  final double percent;
  final int votes;
  final String? lastVoteTime;

  const _PoetColumn({
    required this.label,
    required this.color,
    required this.percent,
    required this.votes,
    this.lastVoteTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      key: ValueKey(lastVoteTime),
      tween: Tween(begin: 0.0, end: percent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label + percentage
            Row(
              children: [
                Text(
                  '${(value * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Progress bar
            ClipRRect(
              borderRadius: AppShapes.radiusXs,
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: AppColors.tertiaryContainer,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),

            // Vote count
            Text(
              '$votes votes',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Status chip
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = AppColors.secondaryContainer;
        textColor = AppColors.secondary;
        label = 'Pending';
        break;
      case 'active':
        bgColor = AppColors.primaryContainer;
        textColor = AppColors.primary;
        label = 'Active';
        break;
      case 'completed':
        bgColor = AppColors.surfaceVariant;
        textColor = AppColors.onSurfaceVariant;
        label = 'Complete';
        break;
      case 'declined':
        bgColor = AppColors.errorContainer;
        textColor = AppColors.error;
        label = 'Declined';
        break;
      default:
        bgColor = AppColors.surfaceVariant;
        textColor = AppColors.onSurfaceVariant;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppShapes.radiusXs,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// A12 Live pill with pulsing dot
class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer,
        borderRadius: AppShapes.radiusXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeOut(duration: const Duration(milliseconds: 600)),
          const SizedBox(width: 5),
          const Text(
            'Live',
            style: TextStyle(
              color: AppColors.tertiary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
