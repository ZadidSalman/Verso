/// Union type for all feed item types
enum FeedItemType { poem, story, thought }

/// Unified feed item wrapper for poems, stories, and thoughts
class FeedItem {
  final FeedItemType type;
  final String id;
  final String? authorId;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatar;
  final String? title;
  final String? content;
  final String? language;
  final List<String> mood;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final String? coverImageUrl;
  final int partsCount;
  final String? visibility; // for thoughts: public/mutual/private

  const FeedItem({
    required this.type,
    required this.id,
    this.authorId,
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
    this.title,
    this.content,
    this.language,
    this.mood = const [],
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.coverImageUrl,
    this.partsCount = 0,
    this.visibility,
  });

  /// Create from PoemModel
  factory FeedItem.fromPoem(PoemModel poem) {
    return FeedItem(
      type: FeedItemType.poem,
      id: poem.id,
      authorId: poem.authorId,
      authorName: poem.author?.displayName,
      authorUsername: poem.author?.username,
      authorAvatar: poem.author?.avatarUrl,
      title: poem.title,
      content: poem.content,
      language: poem.language,
      mood: poem.mood,
      createdAt: poem.createdAt,
      likesCount: poem.likesCount,
      commentsCount: poem.commentsCount,
    );
  }

  /// Create dummy story for testing
  factory FeedItem.dummyStory(int index) {
    return FeedItem(
      type: FeedItemType.story,
      id: 'story_$index',
      authorId: 'user_1',
      authorName: 'Poet ${index + 1}',
      authorUsername: 'poet$index',
      title: 'Chapter ${index + 1}: The Beginning',
      content: 'Once upon a time, in a land far away... This is a sample story content that shows the first few lines of a longer narrative.',
      language: 'en',
      mood: ['melancholy'],
      createdAt: DateTime.now().subtract(Duration(hours: index * 3)),
      likesCount: 10 + index * 2,
      commentsCount: 3 + index,
      coverImageUrl: null,
      partsCount: 5,
    );
  }

  /// Create dummy thought for testing
  factory FeedItem.dummyThought(int index) {
    final thoughts = [
      'Sometimes the simplest words carry the deepest meanings.',
      'Every sunset brings promise of a new dawn.',
      'In the quiet moments, we find ourselves.',
      'Poetry is the language of the soul.',
      'Words, when chosen wisely, can heal wounds that medicine cannot.',
    ];
    return FeedItem(
      type: FeedItemType.thought,
      id: 'thought_$index',
      authorId: 'user_1',
      authorName: 'Poet ${index + 1}',
      authorUsername: 'poet$index',
      content: thoughts[index % thoughts.length],
      language: 'en',
      createdAt: DateTime.now().subtract(Duration(hours: index * 5)),
      likesCount: 5 + index,
      commentsCount: index + 1,
      visibility: index % 3 == 0 ? 'public' : (index % 3 == 1 ? 'mutual' : 'private'),
    );
  }
}