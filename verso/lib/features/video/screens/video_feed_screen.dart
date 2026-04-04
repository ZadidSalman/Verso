import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/router/app_router.dart';
import '../providers/video_provider.dart';
import '../../../shared/models/poem_model.dart';

/// Video feed screen — TikTok-style vertical snap scroll
class VideoFeedScreen extends ConsumerStatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  ConsumerState<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends ConsumerState<VideoFeedScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final Map<int, VideoPlayerController> _controllers = {};

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _initController(int index, String url) async {
    if (_controllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controllers[index] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      if (index == _currentPage) {
        controller.play();
      }
      if (mounted) setState(() {});
    } catch (_) {
      // Silently fail
    }
  }

  void _onPageChanged(int index) {
    // Pause previous
    for (final entry in _controllers.entries) {
      if (entry.key != index) {
        entry.value.pause();
      }
    }
    // Play current
    _controllers[index]?.play();
    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    final videoAsync = ref.watch(videoFeedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: videoAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'The screen is dark. No videos yet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        data: (poems) {
          if (poems.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.videocam_off_outlined,
                    size: 64,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recitations yet.\nYour voice could be the first.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            physics: const PageScrollPhysics().applyTo(
              const ClampingScrollPhysics(),
            ),
            onPageChanged: _onPageChanged,
            itemCount: poems.length,
            itemBuilder: (context, index) {
              final poem = poems[index];
              if (poem.videoUrl != null) {
                _initController(index, poem.videoUrl!);
              }

              return _VideoFeedItem(
                poem: poem,
                controller: _controllers[index],
                isActive: index == _currentPage,
              );
            },
          );
        },
      ),
    );
  }
}

/// Individual video feed item
class _VideoFeedItem extends StatefulWidget {
  final PoemModel poem;
  final VideoPlayerController? controller;
  final bool isActive;

  const _VideoFeedItem({
    required this.poem,
    this.controller,
    required this.isActive,
  });

  @override
  State<_VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<_VideoFeedItem> {
  bool _showPlayPause = false;

  void _togglePlayPause() {
    if (widget.controller == null) return;

    if (widget.controller!.value.isPlaying) {
      widget.controller!.pause();
    } else {
      widget.controller!.play();
    }

    setState(() => _showPlayPause = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showPlayPause = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        if (widget.controller != null && widget.controller!.value.isInitialized)
          GestureDetector(
            onTap: _togglePlayPause,
            child: AspectRatio(
              aspectRatio: widget.controller!.value.aspectRatio,
              child: VideoPlayer(widget.controller!),
            ),
          )
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),

        // Top gradient
        Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
            ),
          ),
        ),

        // Bottom gradient
        Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.75),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Top bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                Text(
                  'For You',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right actions column
        Positioned(
          right: 16,
          bottom: 120,
          child: _RightActions(poem: widget.poem),
        ),

        // Bottom info
        Positioned(
          left: 16,
          right: 80,
          bottom: 88,
          child: _BottomInfo(poem: widget.poem),
        ),

        // Play/pause indicator
        if (_showPlayPause)
          Center(
            child: AnimatedOpacity(
              opacity: _showPlayPause ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.controller?.value.isPlaying ?? false
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Right action column (like, comment, save, share)
class _RightActions extends StatelessWidget {
  final PoemModel poem;

  const _RightActions({required this.poem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white24,
          backgroundImage: poem.author?.avatarUrl != null
              ? NetworkImage(poem.author!.avatarUrl!)
              : null,
          child: poem.author?.avatarUrl == null
              ? const Icon(Icons.person, color: Colors.white70)
              : null,
        ),
        const SizedBox(height: 16),

        // Like
        _ActionIcon(icon: Icons.favorite_border, count: poem.likesCount),
        const SizedBox(height: 16),

        // Comment
        _ActionIcon(icon: Icons.chat_bubble_outline, count: poem.commentsCount),
        const SizedBox(height: 16),

        // Save
        _ActionIcon(icon: Icons.bookmark_border, count: poem.savesCount),
        const SizedBox(height: 16),

        // Share
        _ActionIcon(icon: Icons.share_outlined, count: null),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final int? count;

  const _ActionIcon({required this.icon, this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: () {},
            icon: Icon(icon, color: Colors.white, size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        if (count != null)
          Text(
            _formatCount(count!),
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
      ],
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

/// Bottom info (author, title, snippet, mood)
class _BottomInfo extends StatelessWidget {
  final PoemModel poem;

  const _BottomInfo({required this.poem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author name
        Text(
          '@${poem.author?.username ?? 'poet'}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),

        // Title
        Text(
          poem.title,
          style: AppTypography.englishPoem.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Snippet
        Text(
          poem.content.length > 100
              ? '${poem.content.substring(0, 100)}…'
              : poem.content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Mood chip
        if (poem.mood.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mood(poem.mood.first).withValues(alpha: 0.7),
              borderRadius: AppShapes.radiusXs,
            ),
            child: Text(
              poem.mood.first[0].toUpperCase() + poem.mood.first.substring(1),
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
