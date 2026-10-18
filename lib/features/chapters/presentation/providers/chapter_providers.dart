import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/supabase_chapter_repository.dart';
import '../../domain/models/chapter.dart';
import '../../domain/repositories/chapter_repository.dart';

final chapterRepositoryProvider = Provider<ChapterRepository>(
  (ref) => SupabaseChapterRepository(ref.watch(supabaseClientProvider)),
);

final chaptersProvider = FutureProvider.family<List<Chapter>, String>(
  (ref, projectId) => ref.watch(chapterRepositoryProvider).getByProject(projectId),
);

class ChapterController extends StateNotifier<AsyncValue<void>> {
  final ChapterRepository repository;
  final Ref ref;
  ChapterController(this.repository, this.ref)
      : super(const AsyncValue.data(null));

  Future<Chapter?> create(String projectId, String title, int order) async {
    state = const AsyncValue.loading();
    try {
      final chapter = await repository.create(projectId, title, order);
      ref.invalidate(chaptersProvider(projectId));
      state = const AsyncValue.data(null);
      return chapter;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> update(Chapter chapter) async {
    try {
      await repository.update(chapter);
      ref.invalidate(chaptersProvider(chapter.projectId));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> delete(Chapter chapter) async {
    state = const AsyncValue.loading();
    try {
      await repository.delete(chapter.id);
      ref.invalidate(chaptersProvider(chapter.projectId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final chapterControllerProvider =
    StateNotifierProvider<ChapterController, AsyncValue<void>>(
  (ref) => ChapterController(ref.watch(chapterRepositoryProvider), ref),
);
