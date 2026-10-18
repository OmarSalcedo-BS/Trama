import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/supabase_character_repository.dart';
import '../../domain/models/character.dart';
import '../../domain/repositories/character_repository.dart';

// Repositorio
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return SupabaseCharacterRepository(ref.watch(supabaseClientProvider));
});

// Lista de personajes de un proyecto
final charactersListProvider = FutureProvider.family<List<Character>, String>((
  ref,
  projectId,
) async {
  return ref.watch(characterRepositoryProvider).getByProject(projectId);
});

// Un personaje individual
final characterByIdProvider = FutureProvider.family<Character?, String>((
  ref,
  id,
) async {
  return ref.watch(characterRepositoryProvider).getById(id);
});

// Controlador para crear/editar/eliminar
class CharactersController extends StateNotifier<AsyncValue<void>> {
  final CharacterRepository _repo;
  final Ref _ref;

  CharactersController(this._repo, this._ref)
    : super(const AsyncValue.data(null));

  Future<bool> create({
    required String projectId,
    required String name,
    String? surname,
    String? familyName,
    String? lineageNotes,
    String? role,
    String? age,
    String? appearance,
    String? personality,
    String? motivations,
    String? backstory,
    String? arc,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.create(
        projectId: projectId,
        name: name,
        surname: surname,
        familyName: familyName,
        lineageNotes: lineageNotes,
        role: role,
        age: age,
        appearance: appearance,
        personality: personality,
        motivations: motivations,
        backstory: backstory,
        arc: arc,
        notes: notes,
      );
      _ref.invalidate(charactersListProvider(projectId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> update(Character character) async {
    state = const AsyncValue.loading();
    try {
      await _repo.update(character);
      _ref.invalidate(charactersListProvider(character.projectId));
      _ref.invalidate(characterByIdProvider(character.id));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateFields({
    required String id,
    required String projectId,
    required CharacterPatch patch,
  }) async {
    if (patch.toJson().isEmpty) return true;
    state = const AsyncValue.loading();
    try {
      await _repo.updateFields(id: id, patch: patch);
      _ref.invalidate(charactersListProvider(projectId));
      _ref.invalidate(characterByIdProvider(id));
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
      _ref.invalidate(charactersListProvider(projectId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final charactersControllerProvider =
    StateNotifierProvider<CharactersController, AsyncValue<void>>((ref) {
      return CharactersController(ref.watch(characterRepositoryProvider), ref);
    });
