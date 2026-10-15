import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/character.dart';
import '../../domain/repositories/character_repository.dart';

class SupabaseCharacterRepository implements CharacterRepository {
  final sb.SupabaseClient _client;

  SupabaseCharacterRepository(this._client);

  @override
  Future<List<Character>> getByProject(String projectId) async {
    try {
      final data = await _client
          .from('characters')
          .select()
          .eq('project_id', projectId)
          .order('name', ascending: true);

      return (data as List)
          .map((json) => Character.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException('Error al cargar personajes: $e');
    }
  }

  @override
  Future<Character?> getById(String id) async {
    try {
      final data = await _client
          .from('characters')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return Character.fromJson(data);
    } catch (e) {
      throw AppException('Error al cargar el personaje: $e');
    }
  }

  @override
  Future<Character> create({
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
    try {
      final character = Character(
        id: '',
        projectId: projectId,
        name: name.trim(),
        surname: _nullIfEmpty(surname),
        familyName: _nullIfEmpty(familyName),
        lineageNotes: _nullIfEmpty(lineageNotes),
        role: role,
        age: _nullIfEmpty(age),
        appearance: _nullIfEmpty(appearance),
        personality: _nullIfEmpty(personality),
        motivations: _nullIfEmpty(motivations),
        backstory: _nullIfEmpty(backstory),
        arc: _nullIfEmpty(arc),
        notes: _nullIfEmpty(notes),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final data = await _client
          .from('characters')
          .insert(character.toInsertJson())
          .select()
          .single();

      return Character.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al crear el personaje: $e');
    }
  }

  @override
  Future<Character> update(Character character) async {
    try {
      final data = await _client
          .from('characters')
          .update(character.toUpdateJson())
          .eq('id', character.id)
          .select()
          .single();

      return Character.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al actualizar el personaje: $e');
    }
  }

  @override
  Future<Character> updateFields({
    required String id,
    required CharacterPatch patch,
  }) async {
    final fields = patch.toJson();
    if (fields.isEmpty) {
      final current = await getById(id);
      if (current == null) {
        throw AppException('No se encontró el personaje para actualizar.');
      }
      return current;
    }

    try {
      final data = await _client
          .from('characters')
          .update(fields)
          .eq('id', id)
          .select()
          .single();
      return Character.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al actualizar campos del personaje: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from('characters').delete().eq('id', id);
    } catch (e) {
      throw AppException('Error al eliminar el personaje: $e');
    }
  }

  String? _nullIfEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}