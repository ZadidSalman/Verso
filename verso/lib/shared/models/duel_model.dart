/// Duel model matching backend schema
class DuelModel {
  final String id;
  final String theme;
  final String challengerId;
  final String challengeeId;
  final String? challengerPoemId;
  final String? challengeePoemId;
  final String status;
  final int votesForChallenger;
  final int votesForChallengee;
  final int challengerPercent;
  final int challengeePercent;
  final int totalVotes;
  final List<String> voterIds;
  final String? winnerId;
  final DateTime? endsAt;
  final DateTime createdAt;

  const DuelModel({
    required this.id,
    required this.theme,
    required this.challengerId,
    required this.challengeeId,
    this.challengerPoemId,
    this.challengeePoemId,
    required this.status,
    required this.votesForChallenger,
    required this.votesForChallengee,
    required this.challengerPercent,
    required this.challengeePercent,
    required this.totalVotes,
    required this.voterIds,
    this.winnerId,
    this.endsAt,
    required this.createdAt,
  });

  factory DuelModel.fromJson(Map<String, dynamic> json) {
    return DuelModel(
      id: json['id'] as String,
      theme: json['theme'] as String,
      challengerId: json['challengerId'] as String,
      challengeeId: json['challengeeId'] as String,
      challengerPoemId: json['challengerPoemId'] as String?,
      challengeePoemId: json['challengeePoemId'] as String?,
      status: json['status'] as String,
      votesForChallenger: json['votesForChallenger'] as int? ?? 0,
      votesForChallengee: json['votesForChallengee'] as int? ?? 0,
      challengerPercent: json['challengerPercent'] as int? ?? 50,
      challengeePercent: json['challengeePercent'] as int? ?? 50,
      totalVotes: json['totalVotes'] as int? ?? 0,
      voterIds: json['voterIds'] != null
          ? List<String>.from(json['voterIds'] as List)
          : [],
      winnerId: json['winnerId'] as String?,
      endsAt: json['endsAt'] != null
          ? DateTime.parse(json['endsAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool hasVoted(String userId) => voterIds.contains(userId);
}
