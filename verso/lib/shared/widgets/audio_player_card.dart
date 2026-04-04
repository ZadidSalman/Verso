import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';

/// Audio player card with A28 waveform animation
class AudioPlayerCard extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerCard({super.key, required this.audioUrl});

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Pre-generated wave heights (40 bars, 8-32dp range)
  late final List<double> _waveHeights;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _initPlayer();

    // Generate random wave heights from seed
    final rng = Random(42);
    _waveHeights = List.generate(40, (_) => 8 + rng.nextDouble() * 24);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setUrl(widget.audioUrl);
      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _player.durationStream.listen((dur) {
        if (mounted && dur != null) setState(() => _duration = dur);
      });
      _player.playerStateStream.listen((state) {
        if (mounted) setState(() => _isPlaying = state.playing);
      });
    } catch (_) {
      // Silently fail
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _seek(double fraction) {
    if (_duration.inMilliseconds > 0) {
      _player.seek(
        Duration(milliseconds: (fraction * _duration.inMilliseconds).round()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final progressFraction = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppShapes.radiusMd,
        ),
        child: Row(
          children: [
            // Play/pause button
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                onPressed: _togglePlay,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    key: ValueKey(_isPlaying),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(width: 8),

            // Waveform
            Expanded(
              child: GestureDetector(
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box != null) {
                    final localX = details.localPosition.dx;
                    _seek(localX / box.size.width);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(40, (i) {
                    final baseHeight = _waveHeights[i];
                    final isPlayed = progressFraction > (i / 40);
                    final animHeight = disableAnimations
                        ? baseHeight * 0.5
                        : baseHeight *
                              (0.5 +
                                  0.5 *
                                      sin(
                                        _waveController.value * 2 * pi +
                                            i * 0.4,
                                      ));

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (i * 15)),
                      curve: Curves.easeInOut,
                      width: 3,
                      height: _isPlaying && !disableAnimations
                          ? animHeight.clamp(8, 32)
                          : baseHeight * 0.5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isPlayed
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Timestamp
            Text(
              '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
