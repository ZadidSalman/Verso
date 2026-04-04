import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/duel_repository.dart';
import '../../../shared/models/duel_model.dart';

/// Provider for DuelRepository
final duelRepositoryProvider = Provider<DuelRepository>((ref) {
  return DuelRepository();
});

/// Duel provider — keyed by duel ID
final duelProvider = FutureProvider.family<DuelModel, String>((
  ref,
  duelId,
) async {
  final repository = ref.watch(duelRepositoryProvider);
  return repository.getDuel(duelId);
});

/// Vote in a duel
Future<void> voteInDuel(WidgetRef ref, String duelId, String side) async {
  final repository = ref.read(duelRepositoryProvider);
  await repository.voteDuel(duelId: duelId, side: side);
  ref.invalidate(duelProvider(duelId));
}

/// Accept a duel
Future<void> acceptDuelAction(
  WidgetRef ref,
  String duelId, {
  String? poemId,
}) async {
  final repository = ref.read(duelRepositoryProvider);
  await repository.acceptDuel(duelId: duelId, challengeePoemId: poemId);
  ref.invalidate(duelProvider(duelId));
}
