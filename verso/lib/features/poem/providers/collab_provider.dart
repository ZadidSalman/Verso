import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collab_repository.dart';
import '../../../shared/models/collab_poem_model.dart';

/// Provider for CollabRepository
final collabRepositoryProvider = Provider<CollabRepository>((ref) {
  return CollabRepository();
});

/// Collab poem provider — keyed by poem ID
final collabPoemProvider = FutureProvider.family<CollabPoemModel, String>((
  ref,
  poemId,
) async {
  final repository = ref.watch(collabRepositoryProvider);
  return repository.getCollabPoem(poemId);
});

/// Submit stanza action
Future<void> submitCollabStanza(
  WidgetRef ref,
  String poemId,
  String content,
) async {
  final repository = ref.read(collabRepositoryProvider);
  await repository.submitStanza(poemId: poemId, content: content);
  ref.invalidate(collabPoemProvider(poemId));
}

/// Close collab poem action
Future<void> closeCollabPoem(WidgetRef ref, String poemId) async {
  final repository = ref.read(collabRepositoryProvider);
  await repository.closeCollabPoem(poemId);
  ref.invalidate(collabPoemProvider(poemId));
}
