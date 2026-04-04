import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/like_repository.dart';
import '../data/comment_repository.dart';

/// Provider for LikeRepository
final likeRepositoryProvider = Provider<LikeRepository>((ref) {
  return LikeRepository();
});

/// Provider for CommentRepository
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});

/// Like state for a target
class LikeState {
  final bool isLiked;
  final int count;

  const LikeState({this.isLiked = false, this.count = 0});

  LikeState toggle() {
    return LikeState(isLiked: !isLiked, count: isLiked ? count - 1 : count + 1);
  }
}

/// Like provider — simple family provider
final likeProvider = FutureProvider.family<LikeState, String>((
  ref,
  targetId,
) async {
  final repository = ref.watch(likeRepositoryProvider);
  final isLiked = await repository.isLiked(targetId, 'poem');
  return LikeState(isLiked: isLiked, count: 0);
});

/// Toggle like with optimistic update and rollback
Future<void> toggleLike(
  WidgetRef ref,
  String targetId, {
  String targetType = 'poem',
}) async {
  final repository = ref.read(likeRepositoryProvider);
  final previous = ref.read(likeProvider(targetId)).value;
  if (previous == null) return;

  // Invalidate to refresh
  ref.invalidate(likeProvider(targetId));

  try {
    if (previous.isLiked) {
      await repository.unlike(targetId, targetType);
    } else {
      await repository.like(targetId, targetType);
    }
  } catch (_) {
    // Re-invalidate to restore correct state
    ref.invalidate(likeProvider(targetId));
  }
}

/// Comment list provider — keyed by targetId
final commentListProvider = FutureProvider.family<List<CommentModel>, String>((
  ref,
  targetId,
) async {
  final repository = ref.watch(commentRepositoryProvider);
  final response = await repository.getComments(
    targetId: targetId,
    targetType: 'poem',
  );
  return response.items;
});

/// Add comment action
Future<void> addComment(WidgetRef ref, String targetId, String content) async {
  final repository = ref.read(commentRepositoryProvider);
  await repository.createComment(
    targetId: targetId,
    targetType: 'poem',
    content: content,
  );
  ref.invalidate(commentListProvider(targetId));
}
