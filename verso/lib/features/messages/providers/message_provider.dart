import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/message_repository.dart';
import '../../../shared/models/message_model.dart';

/// Provider for MessageRepository
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

/// Conversations provider
final conversationsProvider = FutureProvider<List<ConversationModel>>((
  ref,
) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getConversations();
});

/// Messages provider for a conversation
final messagesProvider = FutureProvider.family<List<MessageModel>, String>((
  ref,
  conversationId,
) async {
  final repository = ref.watch(messageRepositoryProvider);
  final response = await repository.getMessages(conversationId: conversationId);
  return response.messages;
});

/// Send message action
Future<void> sendMessageAction(
  WidgetRef ref,
  String conversationId,
  String content,
) async {
  final repository = ref.read(messageRepositoryProvider);
  await repository.sendMessage(
    conversationId: conversationId,
    content: content,
  );
  ref.invalidate(messagesProvider(conversationId));
  ref.invalidate(conversationsProvider);
}

/// Mark as read action
Future<void> markAsReadAction(WidgetRef ref, String conversationId) async {
  final repository = ref.read(messageRepositoryProvider);
  await repository.markAsRead(conversationId);
  ref.invalidate(conversationsProvider);
}
