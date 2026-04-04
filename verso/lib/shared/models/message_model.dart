/// Message model
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageSender? sender;
  final String content;
  final String type;
  final List<String> readBy;
  final DateTime sentAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.sender,
    required this.content,
    required this.type,
    required this.readBy,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      sender: json['sender'] != null
          ? MessageSender.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      readBy: json['readBy'] != null
          ? List<String>.from(json['readBy'] as List)
          : [],
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }
}

class MessageSender {
  final String? displayName;
  final String? username;
  final String? avatarUrl;

  const MessageSender({this.displayName, this.username, this.avatarUrl});

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

/// Conversation model
class ConversationModel {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final ConversationUser? otherUser;

  const ConversationModel({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    this.otherUser,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
      otherUser: json['otherUser'] != null
          ? ConversationUser.fromJson(json['otherUser'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ConversationUser {
  final String id;

  const ConversationUser({required this.id});

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    return ConversationUser(id: json['id'] as String);
  }
}
