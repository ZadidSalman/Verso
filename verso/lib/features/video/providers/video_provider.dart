import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/video_repository.dart';
import '../../../shared/models/poem_model.dart';

/// Provider for VideoRepository
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository();
});

/// Video feed provider
final videoFeedProvider = FutureProvider<List<PoemModel>>((ref) async {
  final repository = ref.watch(videoRepositoryProvider);
  return repository.getVideoFeed();
});
