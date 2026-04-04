import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/poem_repository.dart';
import '../../../shared/models/poem_model.dart';

/// Provider for PoemRepository
final poemRepositoryProvider = Provider<PoemRepository>((ref) {
  return PoemRepository();
});

/// Provider for a single poem by ID
final poemProvider = FutureProvider.family<PoemModel, String>((
  ref,
  poemId,
) async {
  return ref.read(poemRepositoryProvider).getPoem(poemId);
});

/// Provider for creating a poem
class CreatePoemNotifier extends AsyncNotifier<PoemModel> {
  PoemRepository get _repository => ref.read(poemRepositoryProvider);

  @override
  Future<PoemModel> build() async {
    throw UnimplementedError();
  }

  Future<void> create({
    required String title,
    required String content,
    required String language,
    List<String>? mood,
    List<String>? tags,
    String? category,
    String? genre,
    bool isAnonymous = false,
    bool isUnsent = false,
    String? unsentTo,
    String status = 'draft',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.createPoem(
        title: title,
        content: content,
        language: language,
        mood: mood,
        tags: tags,
        category: category,
        genre: genre,
        isAnonymous: isAnonymous,
        isUnsent: isUnsent,
        unsentTo: unsentTo,
        status: status,
      ),
    );
  }
}

final createPoemProvider = AsyncNotifierProvider<CreatePoemNotifier, PoemModel>(
  CreatePoemNotifier.new,
);
