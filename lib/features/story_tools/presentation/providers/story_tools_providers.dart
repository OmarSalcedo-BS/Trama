import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/supabase_story_tools_repository.dart';
import '../../domain/models/story_tool_models.dart';
import '../../domain/repositories/story_tools_repository.dart';

final storyToolsRepositoryProvider = Provider<StoryToolsRepository>((ref) {
  return SupabaseStoryToolsRepository(ref.watch(supabaseClientProvider));
});

final notesProvider = FutureProvider.family<List<DraftNote>, String>(
  (ref, projectId) => ref.watch(storyToolsRepositoryProvider).getNotes(projectId),
);
final glossaryProvider = FutureProvider.family<List<GlossaryTerm>, String>(
  (ref, projectId) => ref.watch(storyToolsRepositoryProvider).getGlossary(projectId),
);
final timelineProvider = FutureProvider.family<List<TimelineEvent>, String>(
  (ref, projectId) => ref.watch(storyToolsRepositoryProvider).getTimeline(projectId),
);
final bestiaryProvider = FutureProvider.family<List<BestiaryEntry>, String>(
  (ref, projectId) =>
      ref.watch(storyToolsRepositoryProvider).getBestiary(projectId),
);
final relationshipsProvider =
    FutureProvider.family<List<CharacterRelationship>, String>(
  (ref, projectId) =>
      ref.watch(storyToolsRepositoryProvider).getRelationships(projectId),
);

final relationshipsStreamProvider =
    StreamProvider.family<List<CharacterRelationship>, String>(
  (ref, projectId) =>
      ref.watch(storyToolsRepositoryProvider).watchRelationships(projectId),
);

class StoryToolsController extends StateNotifier<AsyncValue<void>> {
  final StoryToolsRepository repository;
  final Ref ref;

  StoryToolsController(this.repository, this.ref)
      : super(const AsyncValue.data(null));

  Future<bool> run(Future<void> Function() operation) async {
    state = const AsyncValue.loading();
    try {
      await operation();
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      return false;
    }
  }
}

final storyToolsControllerProvider =
    StateNotifierProvider<StoryToolsController, AsyncValue<void>>(
  (ref) => StoryToolsController(ref.watch(storyToolsRepositoryProvider), ref),
);
