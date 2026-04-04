import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/follow_repository.dart';

/// Provider for FollowRepository
final followRepositoryProvider = Provider<FollowRepository>((ref) {
  return FollowRepository();
});

/// Provider for follow state of a single user
final followProvider =
    FutureProvider.family<({bool isFollowing, bool isMutual}), String>((
      ref,
      userId,
    ) async {
      final repository = ref.watch(followRepositoryProvider);
      final status = await repository.getFollowStatus(userId);
      return (isFollowing: status.isFollowing, isMutual: status.isMutual);
    });

/// Toggle follow action provider
final followToggleProvider = Provider.family<Future<void> Function(), String>((
  ref,
  userId,
) {
  return () async {
    final repository = ref.read(followRepositoryProvider);
    final current = ref.read(followProvider(userId)).value;
    if (current == null) return;

    if (current.isFollowing) {
      await repository.unfollow(userId);
    } else {
      await repository.follow(userId);
    }

    // Invalidate to refresh
    ref.invalidate(followProvider(userId));
  };
});
