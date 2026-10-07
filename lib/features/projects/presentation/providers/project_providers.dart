import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/supabase_project_repository.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/project_repository.dart';

// Repositorio
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return SupabaseProjectRepository(ref.watch(supabaseClientProvider));
});

// Lista de proyectos del usuario actual.
// Se invalida al crear/editar/eliminar para refrescar la lista.
final projectsListProvider = FutureProvider<List<Project>>((ref) async {
  // Escuchamos cambios de sesión: si el usuario cambia, recargamos.
  ref.watch(authStateProvider);
  return ref.watch(projectRepositoryProvider).getByCurrentUser();
});

// Un proyecto individual por id.
final projectByIdProvider =
    FutureProvider.family<Project?, String>((ref, id) async {
  return ref.watch(projectRepositoryProvider).getById(id);
});

// Controlador para operaciones de escritura (crear, editar, eliminar).
class ProjectsController extends StateNotifier<AsyncValue<void>> {
  final ProjectRepository _repo;
  final Ref _ref;

  ProjectsController(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> create({
    required String title,
    String? synopsis,
    String? genre,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.create(title: title, synopsis: synopsis, genre: genre);
      _ref.invalidate(projectsListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> update(Project project) async {
    state = const AsyncValue.loading();
    try {
      await _repo.update(project);
      _ref.invalidate(projectsListProvider);
      _ref.invalidate(projectByIdProvider(project.id));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(id);
      _ref.invalidate(projectsListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final projectsControllerProvider =
    StateNotifierProvider<ProjectsController, AsyncValue<void>>((ref) {
  return ProjectsController(
    ref.watch(projectRepositoryProvider),
    ref,
  );
});