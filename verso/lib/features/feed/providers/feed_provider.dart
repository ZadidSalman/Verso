import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feed_repository.dart';
import '../../../shared/models/poem_model.dart';

/// Provider for FeedRepository
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

/// Feed state with cursor pagination
class FeedState {
  final List<PoemModel> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;

  const FeedState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoading = false,
  });

  FeedState copyWith({
    List<PoemModel>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoading,
  }) {
    return FeedState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Feed notifier with cursor pagination and mood/language filters
class FeedNotifier extends Notifier<FeedState> {
  FeedRepository get _repository => ref.read(feedRepositoryProvider);

  String? _currentMood;
  String? _currentLanguage;
  String? _currentType;

  @override
  FeedState build() {
    Future.microtask(() => _loadFeed());
    return const FeedState(isLoading: true);
  }

  Future<void> _loadFeed({String? cursor}) async {
    if (cursor == null || cursor.isNotEmpty) {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _repository.getFeed(
        cursor: cursor,
        mood: _currentMood,
        language: _currentLanguage,
        type: _currentType,
      );

      // Use poems directly
      final newItems = cursor == null
          ? response.items
          : [...state.items, ...response.items];

      state = FeedState(
        items: newItems,
        nextCursor: response.nextCursor,
        hasMore: response.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Refresh the feed from the beginning
  Future<void> refresh() async {
    await _loadFeed(cursor: null);
  }

  /// Load the next page
  Future<void> loadMore() async {
    if (state.hasMore && state.nextCursor != null) {
      await _loadFeed(cursor: state.nextCursor);
    }
  }

  /// Filter by mood
  void setMoodFilter(String? mood) {
    _currentMood = mood;
    _loadFeed(cursor: null);
  }

  /// Filter by language
  void setLanguageFilter(String? language) {
    _currentLanguage = language;
    _loadFeed(cursor: null);
  }

  /// Filter by type (all, poems, stories, thoughts)
  void setTypeFilter(String? type) {
    _currentType = type;
    _loadFeed(cursor: null);
  }
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);
