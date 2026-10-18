import '../models/story_tool_models.dart';

abstract class StoryToolsRepository {
  Future<List<DraftNote>> getNotes(String projectId);
  Future<DraftNote> createNote(String projectId, String title, String content);
  Future<void> deleteNote(String id);

  Future<List<GlossaryTerm>> getGlossary(String projectId);
  Future<GlossaryTerm> createTerm(
    String projectId,
    String term,
    String definition,
    String? category,
  );
  Future<void> deleteTerm(String id);

  Future<List<TimelineEvent>> getTimeline(String projectId);
  Future<TimelineEvent> createEvent(
    String projectId,
    String title,
    String? description,
    DateTime eventDate,
  );
  Future<void> deleteEvent(String id);

  Future<List<BestiaryEntry>> getBestiary(String projectId);
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
  });
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
  });
  Future<void> deleteBestiaryEntry(String id);

  Future<List<CharacterRelationship>> getRelationships(String projectId);
  Stream<List<CharacterRelationship>> watchRelationships(String projectId);
  Future<CharacterRelationship> createRelationship({
    required String projectId,
    required String sourceCharacterId,
    required String targetCharacterId,
    required String relationType,
    String? description,
  });
  Future<CharacterRelationship> updateRelationship({
    required String id,
    required String sourceCharacterId,
    required String targetCharacterId,
    required String relationType,
    String? description,
  });
  Future<void> deleteRelationship(String id);
}
