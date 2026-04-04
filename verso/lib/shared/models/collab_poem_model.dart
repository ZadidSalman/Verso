/// Collaborative poem model
class CollabPoemModel {
  final String id;
  final String title;
  final String language;
  final String originatorId;
  final String collabType;
  final String status;
  final List<StanzaModel> stanzas;
  final int contributorsCount;
  final List<String> mood;
  final int likesCount;
  final int commentsCount;
  final int readsCount;
  final double trendingScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollabPoemModel({
    required this.id,
    required this.title,
    required this.language,
    required this.originatorId,
    required this.collabType,
    required this.status,
    required this.stanzas,
    required this.contributorsCount,
    required this.mood,
    required this.likesCount,
    required this.commentsCount,
    required this.readsCount,
    required this.trendingScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollabPoemModel.fromJson(Map<String, dynamic> json) {
    final stanzasList = json['stanzas'] as List? ?? [];
    return CollabPoemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      language: json['language'] as String? ?? 'en',
      originatorId: json['originatorId'] as String,
      collabType: json['collabType'] as String? ?? 'open',
      status: json['status'] as String? ?? 'open',
      stanzas: stanzasList
          .map((s) => StanzaModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      contributorsCount: json['contributorsCount'] as int? ?? 0,
      mood: json['mood'] != null ? List<String>.from(json['mood'] as List) : [],
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      readsCount: json['readsCount'] as int? ?? 0,
      trendingScore: (json['trendingScore'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Stanza model
class StanzaModel {
  final String stanzaId;
  final String authorId;
  final String content;
  final int order;
  final bool isApproved;
  final DateTime createdAt;

  const StanzaModel({
    required this.stanzaId,
    required this.authorId,
    required this.content,
    required this.order,
    required this.isApproved,
    required this.createdAt,
  });

  factory StanzaModel.fromJson(Map<String, dynamic> json) {
    return StanzaModel(
      stanzaId: json['stanzaId'] as String,
      authorId: json['authorId'] as String,
      content: json['content'] as String,
      order: json['order'] as int,
      isApproved: json['isApproved'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
