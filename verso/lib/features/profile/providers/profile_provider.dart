import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../../../shared/models/poem_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileState {
  final List<FeedItem> poems;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isOwnProfile;
  final String? username;
  final String? error;

  const ProfileState({
    this.poems = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isOwnProfile = true,
    this.username,
    this.error,
  });

  ProfileState copyWith({
    List<FeedItem>? poems,
    String? nextCursor,
    bool? hasMore,
    bool? isLoading,
    bool? isOwnProfile,
    String? username,
    String? error,
  }) {
    return ProfileState(
      poems: poems ?? this.poems,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isOwnProfile: isOwnProfile ?? this.isOwnProfile,
      username: username ?? this.username,
      error: error,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  ProfileState build() {
    return const ProfileState(isLoading: true);
  }

  Future<void> loadMyPoems({String? cursor}) async {
    if (cursor == null) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _repository.getMyPoems(cursor: cursor);
      final newPoems = cursor == null
          ? response.items
          : [...state.poems, ...response.items];

      state = state.copyWith(
        poems: newPoems,
        nextCursor: response.nextCursor,
        hasMore: response.hasMore,
        isLoading: false,
        isOwnProfile: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadUserPoems(String username, {String? cursor}) async {
    if (cursor == null) {
      state = state.copyWith(isLoading: true, error: null, poems: []);
    }

    try {
      final response = await _repository.getUserPoems(
        username: username,
        cursor: cursor,
      );
      final newPoems = cursor == null
          ? response.items
          : [...state.poems, ...response.items];

      state = state.copyWith(
        poems: newPoems,
        nextCursor: response.nextCursor,
        hasMore: response.hasMore,
        isLoading: false,
        isOwnProfile: false,
        username: username,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.hasMore && state.nextCursor != null && !state.isLoading) {
      if (state.isOwnProfile) {
        await loadMyPoems(cursor: state.nextCursor);
      } else if (state.username != null) {
        await loadUserPoems(state.username!, cursor: state.nextCursor);
      }
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
