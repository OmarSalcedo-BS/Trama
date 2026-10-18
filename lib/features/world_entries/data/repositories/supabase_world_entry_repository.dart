import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/world_entry.dart';
import '../../domain/repositories/world_entry_repository.dart';

class SupabaseWorldEntryRepository implements WorldEntryRepository {
  final sb.SupabaseClient _client;

  SupabaseWorldEntryRepository(this._client);

  @override
  Future<List<WorldEntry>> getByCategory(String categoryId) async {
    try {
      final data = await _client
          .from('world_entries')
          .select()
          .eq('category_id', categoryId)
          .order('title', ascending: true);

      return (data as List).map((json) => WorldEntry.fromJson(json)).toList();
    } catch (e) {
      throw AppException('Error al cargar las fichas: $e');
    }
  }

  @override
  Future<List<WorldEntry>> getByProject(String projectId) async {
    try {
      final data = await _client
          .from('world_entries')
          .select()
          .eq('project_id', projectId)
          .order('title', ascending: true);

      return (data as List).map((json) => WorldEntry.fromJson(json)).toList();
    } catch (e) {
      throw AppException('Error al cargar las fichas: $e');
    }
  }

  @override
  Future<WorldEntry?> getById(String id) async {
    try {
      final data = await _client
          .from('world_entries')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return WorldEntry.fromJson(data);
    } catch (e) {
      throw AppException('Error al cargar la ficha: $e');
    }
  }

  @override
  Future<WorldEntry> create({
    required String projectId,
    required String categoryId,
    required String title,
    String? summary,
    String? content,
    List<String> tags = const [],
  }) async {
    try {
      final entry = WorldEntry(
        id: '',
        projectId: projectId,
        categoryId: categoryId,
        title: title.trim(),
        summary: summary?.trim().isEmpty == true ? null : summary?.trim(),
        content: content?.trim().isEmpty == true ? null : content?.trim(),
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final data = await _client
          .from('world_entries')
          .insert(entry.toInsertJson())
          .select()
          .single();

      return WorldEntry.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al crear la ficha: $e');
    }
  }

  @override
  Future<WorldEntry> update(WorldEntry entry) async {
    try {
      final data = await _client
          .from('world_entries')
          .update(entry.toUpdateJson())
          .eq('id', entry.id)
          .select()
          .single();

      return WorldEntry.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al actualizar la ficha: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from('world_entries').delete().eq('id', id);
    } catch (e) {
      throw AppException('Error al eliminar la ficha: $e');
    }
  }

  @override
  Future<List<String>> getCharacterIds(String entryId) async {
    try {
      final data = await _client
          .from('world_entry_characters')
          .select('character_id')
          .eq('world_entry_id', entryId);
      return (data as List)
          .map((row) => row['character_id'] as String)
          .toList();
    } catch (e) {
      throw AppException('Error al cargar los personajes vinculados: $e');
    }
  }

  @override
  Future<void> setCharacterIds(
    String entryId,
    List<String> characterIds,
  ) async {
    try {
      await _client
          .from('world_entry_characters')
          .delete()
          .eq('world_entry_id', entryId);
      if (characterIds.isEmpty) return;
      await _client
          .from('world_entry_characters')
          .insert(
            characterIds
                .toSet()
                .map(
                  (characterId) => {
                    'world_entry_id': entryId,
                    'character_id': characterId,
                  },
                )
                .toList(),
          );
    } catch (e) {
      throw AppException('Error al guardar los personajes vinculados: $e');
    }
  }

  @override
  Future<List<String>> getBestiaryIds(String entryId) async {
    try {
      final data = await _client
          .from('world_entry_bestiary')
          .select('bestiary_id')
          .eq('world_entry_id', entryId);
      return (data as List).map((row) => row['bestiary_id'] as String).toList();
    } catch (error) {
      throw AppException(
        'No se pudieron cargar las criaturas vinculadas: $error',
      );
    }
  }

  @override
  Future<void> setBestiaryIds(String entryId, List<String> bestiaryIds) async {
    try {
      await _client
          .from('world_entry_bestiary')
          .delete()
          .eq('world_entry_id', entryId);
      if (bestiaryIds.isEmpty) return;
      await _client
          .from('world_entry_bestiary')
          .insert(
            bestiaryIds
                .toSet()
                .map((id) => {'world_entry_id': entryId, 'bestiary_id': id})
                .toList(),
          );
    } catch (error) {
      throw AppException(
        'No se pudieron guardar las criaturas vinculadas: $error',
      );
    }
  }

  @override
  Future<List<String>> getRelatedEntryIds(String entryId) async {
    try {
      final data = await _client
          .from('world_entry_links')
          .select('target_entry_id')
          .eq('source_entry_id', entryId);
      return (data as List)
          .map((row) => row['target_entry_id'] as String)
          .toList();
    } catch (error) {
      throw AppException(
        'No se pudieron cargar las fichas relacionadas: $error',
      );
    }
  }

  @override
  Future<void> setRelatedEntryIds(
    String entryId,
    List<String> relatedEntryIds,
  ) async {
    try {
      await _client
          .from('world_entry_links')
          .delete()
          .eq('source_entry_id', entryId);
      final ids = relatedEntryIds.where((id) => id != entryId).toSet();
      if (ids.isEmpty) return;
      await _client
          .from('world_entry_links')
          .insert(
            ids
                .map(
                  (id) => {'source_entry_id': entryId, 'target_entry_id': id},
                )
                .toList(),
          );
    } catch (error) {
      throw AppException(
        'No se pudieron guardar las fichas relacionadas: $error',
      );
    }
  }
}
