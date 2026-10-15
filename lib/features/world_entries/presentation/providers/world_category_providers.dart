import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/supabase_world_category_repository.dart';
import '../../domain/models/world_category.dart';
import '../../domain/repositories/world_category_repository.dart';

final worldCategoryRepositoryProvider =
    Provider<WorldCategoryRepository>((ref) {
  return SupabaseWorldCategoryRepository(ref.watch(supabaseClientProvider));
});

final worldCategoriesListProvider =
    FutureProvider.family<List<WorldCategory>, String>((ref, projectId) async {
  return ref.watch(worldCategoryRepositoryProvider).getByProject(projectId);
});

final worldCategoryByIdProvider =
    FutureProvider.family<WorldCategory?, String>((ref, id) async {
  return ref.watch(worldCategoryRepositoryProvider).getById(id);
});

class WorldCategoriesController extends StateNotifier<AsyncValue<void>> {
  final WorldCategoryRepository _repo;
  final Ref _ref;

  WorldCategoriesController(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> create({
    required String projectId,
    required String name,
    String? description,
    required String icon,
    required String color,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.create(
        projectId: projectId,
        name: name,
        description: description,
        icon: icon,
        color: color,
      );
      _ref.invalidate(worldCategoriesListProvider(projectId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> update(WorldCategory category) async {
    state = const AsyncValue.loading();
    try {
      await _repo.update(category);
      _ref.invalidate(worldCategoriesListProvider(category.projectId));
      _ref.invalidate(worldCategoryByIdProvider(category.id));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> delete(String id, String projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(id);
      _ref.invalidate(worldCategoriesListProvider(projectId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final worldCategoriesControllerProvider =
    StateNotifierProvider<WorldCategoriesController, AsyncValue<void>>((ref) {
  return WorldCategoriesController(
    ref.watch(worldCategoryRepositoryProvider),
    ref,
  );
});