import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/message_model.dart';

/// Repository for messaging API calls
class MessageRepository {
  final Dio _dio = DioClient.instance;

  /// Get all conversations
  Future<List<ConversationModel>> getConversations() async {
    final response = await _dio.get('/api/conversations');
    final items = response.data['conversations'] as List? ?? [];
    return items
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Find or create conversation
  Future<ConversationModel> findOrCreateConversation(String otherUserId) async {
    final response = await _dio.post(
      '/api/conversations',
      data: {'otherUserId': otherUserId},
    );
    return ConversationModel.fromJson(
      response.data['conversation'] as Map<String, dynamic>,
    );
  }

  /// Get messages for a conversation
  Future<MessagesResponse> getMessages({
    required String conversationId,
    String? cursor,
    int limit = 30,
  }) async {
    final response = await _dio.get(
      '/api/conversations/$conversationId/messages',
      queryParameters: {if (cursor != null) 'cursor': cursor, 'limit': limit},
    );
    return MessagesResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Send a message
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
  }) async {
    final response = await _dio.post(
      '/api/conversations/$conversationId/messages',
      data: {'content': content, 'type': type},
    );
    return MessageModel.fromJson(
      response.data['message'] as Map<String, dynamic>,
    );
  }

  /// Mark conversation as read
  Future<void> markAsRead(String conversationId) async {
    await _dio.put('/api/conversations/$conversationId/read');
  }
}

class MessagesResponse {
  final List<MessageModel> messages;
  final String? nextCursor;
  final bool hasMore;

  const MessagesResponse({
    required this.messages,
    this.nextCursor,
    required this.hasMore,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    final items = json['messages'] as List? ?? [];
    return MessagesResponse(
      messages: items
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
