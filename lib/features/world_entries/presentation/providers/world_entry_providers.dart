import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/supabase_world_entry_repository.dart';
import '../../domain/models/world_entry.dart';
import '../../domain/repositories/world_entry_repository.dart';
import 'world_category_providers.dart';

final worldEntryRepositoryProvider =
    Provider<WorldEntryRepository>((ref) {
  return SupabaseWorldEntryRepository(ref.watch(supabaseClientProvider));
});

final worldEntriesByCategoryProvider =
    FutureProvider.family<List<WorldEntry>, String>((ref, categoryId) async {
  return ref.watch(worldEntryRepositoryProvider).getByCategory(categoryId);
});

final worldEntriesByProjectProvider =
    FutureProvider.family<List<WorldEntry>, String>((ref, projectId) async {
  return ref.watch(worldEntryRepositoryProvider).getByProject(projectId);
});

final worldEntryByIdProvider =
    FutureProvider.family<WorldEntry?, String>((ref, id) async {
  return ref.watch(worldEntryRepositoryProvider).getById(id);
});

class WorldEntriesController extends StateNotifier<AsyncValue<void>> {
  final WorldEntryRepository _repo;
  final Ref _ref;

  WorldEntriesController(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> create({
    required String projectId,
    required String categoryId,
    required String title,
    String? summary,
    String? content,
    List<String> tags = const [],
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.create(
        projectId: projectId,
        categoryId: categoryId,
        title: title,
        summary: summary,
        content: content,
        tags: tags,
      );
      _ref.invalidate(worldEntriesByCategoryProvider(categoryId));
      _ref.invalidate(worldEntriesByProjectProvider(projectId));
      _ref.invalidate(worldCategoriesListProvider(projectId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> update(WorldEntry entry) async {
    state = const AsyncValue.loading();
    try {
      await _repo.update(entry);
      _ref.invalidate(worldEntriesByCategoryProvider(entry.categoryId));
      _ref.invalidate(worldEntriesByProjectProvider(entry.projectId));
      _ref.invalidate(worldEntryByIdProvider(entry.id));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> delete(
    String id,
    String categoryId,
    String projectId,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(id);
      _ref.invalidate(worldEntriesByCategoryProvider(categoryId));
      _ref.invalidate(worldEntriesByProjectProvider(projectId));
      _ref.invalidate(worldCategoriesListProvider(projectId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final worldEntriesControllerProvider =
    StateNotifierProvider<WorldEntriesController, AsyncValue<void>>((ref) {
  return WorldEntriesController(
    ref.watch(worldEntryRepositoryProvider),
    ref,
  );
});

// Añadimos el import necesario para worldCategoriesListProvider
