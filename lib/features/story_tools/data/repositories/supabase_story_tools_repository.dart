import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/errors/app_exception.dart';
import '../../constants/story_tool_constants.dart';
import '../../domain/models/story_tool_models.dart';
import '../../domain/repositories/story_tools_repository.dart';

class SupabaseStoryToolsRepository implements StoryToolsRepository {
  final sb.SupabaseClient _client;

  SupabaseStoryToolsRepository(this._client);

  @override
  Future<List<DraftNote>> getNotes(String projectId) async {
    final data = await _read(() => _client.from('draft_notes').select()
        .eq('project_id', projectId).order('updated_at', ascending: false));
    return (data as List).map((e) => DraftNote.fromJson(e)).toList();
  }

  @override
  Future<DraftNote> createNote(
    String projectId,
    String title,
    String content,
  ) async {
    final cleanTitle = _required(title, 'El título de la nota');
    final cleanContent = _bounded(content, 'El contenido', 5000);
    await _assertUnique('draft_notes', 'title', cleanTitle, projectId);
    final data = await _insert(
      'draft_notes',
      DraftNote(
        id: '',
        projectId: projectId,
        title: cleanTitle,
        content: cleanContent,
        status: 'draft',
        updatedAt: DateTime.now(),
      ).toInsertJson(),
    );
    return DraftNote.fromJson(data);
  }

  @override
  Future<void> deleteNote(String id) => _delete('draft_notes', id);

  @override
  Future<List<GlossaryTerm>> getGlossary(String projectId) async {
    final data = await _read(() => _client.from('glossary_terms').select()
        .eq('project_id', projectId).order('term', ascending: true));
    return (data as List).map((e) => GlossaryTerm.fromJson(e)).toList();
  }

  @override
  Future<GlossaryTerm> createTerm(
    String projectId,
    String term,
    String definition,
    String? category,
  ) async {
    final cleanTerm = _required(term, 'El término');
    final cleanDefinition = _bounded(definition, 'La definición', 5000);
    await _assertUnique('glossary_terms', 'term', cleanTerm, projectId);
    final data = await _insert(
      'glossary_terms',
      GlossaryTerm(
        id: '',
        projectId: projectId,
        term: cleanTerm,
        definition: cleanDefinition,
        category: _optional(category),
        updatedAt: DateTime.now(),
      ).toInsertJson(),
    );
    return GlossaryTerm.fromJson(data);
  }

  @override
  Future<void> deleteTerm(String id) => _delete('glossary_terms', id);

  @override
  Future<List<TimelineEvent>> getTimeline(String projectId) async {
    final data = await _read(() => _client.from('timeline_events').select()
        .eq('project_id', projectId).order('event_date', ascending: true));
    return (data as List).map((e) => TimelineEvent.fromJson(e)).toList();
  }

  @override
  Future<TimelineEvent> createEvent(
    String projectId,
    String title,
    String? description,
    DateTime eventDate,
  ) async {
    final cleanTitle = _required(title, 'El título del evento');
    await _assertUnique('timeline_events', 'title', cleanTitle, projectId);
    final data = await _insert(
      'timeline_events',
      TimelineEvent(
        id: '',
        projectId: projectId,
        title: cleanTitle,
        description: _optional(description),
        eventDate: eventDate,
        updatedAt: DateTime.now(),
      ).toInsertJson(),
    );
    return TimelineEvent.fromJson(data);
  }

  @override
  Future<void> deleteEvent(String id) => _delete('timeline_events', id);

  @override
  Future<List<BestiaryEntry>> getBestiary(String projectId) async {
    final data = await _read(() => _client.from('bestiary_entries').select()
        .eq('project_id', projectId).order('name', ascending: true));
    return (data as List).map((e) => BestiaryEntry.fromJson(e)).toList();
  }

  @override
  Future<BestiaryEntry> createBestiaryEntry({
    required String projectId,
    required String name,
    String? category,
    String? mythology,
    required String description,
    String? weaknesses,
    String? abilities,
    String? habitat,
    String? dangerLevel,
    String? historicalReferences,
    String? diet,
    String? storyContext,
  }) async {
    final cleanName = _required(name, 'El nombre de la criatura');
    final cleanDescription = _bounded(description, 'La descripción', 8000);
    await _assertUnique('bestiary_entries', 'name', cleanName, projectId);
    final data = await _insert(
      'bestiary_entries',
      BestiaryEntry(
        id: '',
        projectId: projectId,
        name: cleanName,
        category: _optional(category),
        mythology: _optional(mythology),
        description: cleanDescription,
        weaknesses: _optional(weaknesses),
        abilities: _optional(abilities),
        habitat: _optional(habitat),
        dangerLevel: _optional(dangerLevel),
        historicalReferences: _optional(historicalReferences),
        diet: _optional(diet),
        storyContext: _optional(storyContext),
        updatedAt: DateTime.now(),
      ).toInsertJson(),
    );
    return BestiaryEntry.fromJson(data);
  }

  @override
  Future<void> deleteBestiaryEntry(String id) =>
      _delete('bestiary_entries', id);

  @override
  Future<BestiaryEntry> updateBestiaryEntry({
    required String id,
    required String name,
    String? category,
    String? mythology,
    required String description,
    String? weaknesses,
    String? abilities,
    String? habitat,
    String? dangerLevel,
    String? historicalReferences,
    String? diet,
    String? storyContext,
  }) async {
    final cleanName = _required(name, 'El nombre de la criatura');
    final cleanDescription = _bounded(description, 'La descripción', 8000);
    final existing = await _read(() => _client
        .from('bestiary_entries')
        .select('id, project_id')
        .eq('id', id)
        .maybeSingle());
    if (existing == null) {
      throw const AppException('La criatura ya no existe.');
    }
    final duplicate = await _read(() => _client
        .from('bestiary_entries')
        .select('id')
        .eq('project_id', existing['project_id'])
        .eq('name', cleanName)
        .neq('id', id)
        .maybeSingle());
    if (duplicate != null) {
      throw const AppException('Ya existe una criatura con ese nombre.');
    }
    final data = await _read(() => _client
        .from('bestiary_entries')
        .update({
          'name': cleanName,
          'category': _optional(category),
          'mythology': _optional(mythology),
          'description': cleanDescription,
          'weaknesses': _optional(weaknesses),
          'abilities': _optional(abilities),
          'habitat': _optional(habitat),
          'danger_level': _optional(dangerLevel),
          'historical_references': _optional(historicalReferences),
          'diet': _optional(diet),
          'story_context': _optional(storyContext),
        })
        .eq('id', id)
        .select()
        .single());
    return BestiaryEntry.fromJson(data);
  }

  @override
  Future<List<CharacterRelationship>> getRelationships(String projectId) async {
    final data = await _read(() => _client
        .from('character_relationships')
        .select()
        .eq('project_id', projectId));
    return (data as List).map((e) => CharacterRelationship.fromJson(e)).toList();
  }

  @override
  Stream<List<CharacterRelationship>> watchRelationships(
    String projectId,
  ) {
    return _client
        .from('character_relationships')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .map(
          (rows) => rows
              .map(
                (row) => CharacterRelationship.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<CharacterRelationship> createRelationship({
    required String projectId,
    required String sourceCharacterId,
    required String targetCharacterId,
    required String relationType,
    String? description,
  }) async {
    if (sourceCharacterId == targetCharacterId) {
      throw const AppException('Un personaje no puede relacionarse consigo mismo.');
    }
    final cleanType = _required(relationType, 'El tipo de relación');
    if (cleanType.length > StoryToolConstants.maxRelationTypeLength) {
      throw const AppException('El tipo de relación es demasiado largo.');
    }
    final duplicate = await _read(() => _client
        .from('character_relationships')
        .select('id')
        .eq('project_id', projectId)
        .eq('source_character_id', sourceCharacterId)
        .eq('target_character_id', targetCharacterId)
        .eq('relation_type', cleanType)
        .maybeSingle());
    if (duplicate != null) {
      throw const AppException('Esta relación ya existe.');
    }
    final data = await _insert(
      'character_relationships',
      CharacterRelationship(
        id: '',
        projectId: projectId,
        sourceCharacterId: sourceCharacterId,
        targetCharacterId: targetCharacterId,
        relationType: cleanType,
        description: _optional(description),
      ).toInsertJson(),
    );
    return CharacterRelationship.fromJson(data);
  }

  @override
  Future<void> deleteRelationship(String id) =>
      _delete('character_relationships', id);

  @override
  Future<CharacterRelationship> updateRelationship({
    required String id,
    required String sourceCharacterId,
    required String targetCharacterId,
    required String relationType,
    String? description,
  }) async {
    if (sourceCharacterId == targetCharacterId) {
      throw const AppException('Un personaje no puede relacionarse consigo mismo.');
    }
    final data = await _client.from('character_relationships').update({
      'source_character_id': sourceCharacterId,
      'target_character_id': targetCharacterId,
      'relation_type': _required(relationType, 'El tipo de relación'),
      'description': _optional(description),
    }).eq('id', id).select().single();
    return CharacterRelationship.fromJson(data);
  }

  Future<dynamic> _read(Future<dynamic> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AppException('Error al consultar los datos: $e');
    }
  }

  Future<Map<String, dynamic>> _insert(
    String table,
    Map<String, dynamic> values,
  ) async {
    try {
      final result = await _client.from(table).insert(values).select().single();
      return Map<String, dynamic>.from(result);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al guardar el registro: $e');
    }
  }

  Future<void> _delete(String table, String id) async {
    try {
      await _client.from(table).delete().eq('id', id);
    } catch (e) {
      throw AppException('Error al eliminar el registro: $e');
    }
  }

  Future<void> _assertUnique(
    String table,
    String column,
    String value,
    String projectId,
  ) async {
    final found = await _read(() => _client.from(table).select('id')
        .eq('project_id', projectId).eq(column, value).maybeSingle());
    if (found != null) throw const AppException('Ya existe un registro con ese nombre.');
  }

  String _required(String value, String label) {
    final clean = value.trim();
    if (clean.isEmpty) throw AppException('$label es obligatorio.');
    if (clean.length > StoryToolConstants.maxTitleLength) {
      throw AppException('$label es demasiado largo.');
    }
    return clean;
  }

  String _bounded(String value, String label, int max) {
    final clean = value.trim();
    if (clean.length > max) throw AppException('$label es demasiado largo.');
    return clean;
  }

  String? _optional(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }
}
