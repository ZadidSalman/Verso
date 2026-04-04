import 'package:flutter/material.dart';

/// Notification model matching backend schema
class NotificationModel {
  final String id;
  final String recipientId;
  final String type;
  final String actorId;
  final NotificationActor? actor;
  final String? entityId;
  final String? entityType;
  final String poeticMessage;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.actorId,
    this.actor,
    this.entityId,
    this.entityType,
    required this.poeticMessage,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      type: json['type'] as String,
      actorId: json['actorId'] as String,
      actor: json['actor'] != null
          ? NotificationActor.fromJson(json['actor'] as Map<String, dynamic>)
          : null,
      entityId: json['entityId'] as String?,
      entityType: json['entityType'] as String?,
      poeticMessage: json['poeticMessage'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NotificationActor {
  final String? displayName;
  final String? username;
  final String? avatarUrl;

  const NotificationActor({this.displayName, this.username, this.avatarUrl});

  factory NotificationActor.fromJson(Map<String, dynamic> json) {
    return NotificationActor(
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

/// Notification type icon mapping
extension NotificationTypeExt on String {
  IconData get icon {
    switch (this) {
      case 'poem_liked':
      case 'storyPart_liked':
      case 'thought_reacted':
        return Icons.favorite;
      case 'new_follower':
        return Icons.person_add;
      case 'comment':
      case 'comment_story':
        return Icons.chat_bubble;
      case 'duel_invite':
      case 'duel_result':
        return Icons.gavel;
      case 'stanza_added':
        return Icons.edit_note;
      case 'new_story_part':
        return Icons.menu_book;
      case 'story_collab_invite':
        return Icons.group_add;
      default:
        return Icons.notifications;
    }
  }

  String get actorName {
    switch (this) {
      case 'poem_liked':
      case 'storyPart_liked':
      case 'thought_reacted':
        return 'liked';
      case 'new_follower':
        return 'followed';
      case 'comment':
      case 'comment_story':
        return 'commented on';
      case 'duel_invite':
        return 'challenged';
      case 'duel_result':
        return 'announced';
      case 'stanza_added':
        return 'added a line to';
      case 'new_story_part':
        return 'published';
      case 'story_collab_invite':
        return 'invited';
      default:
        return '';
    }
  }
}
