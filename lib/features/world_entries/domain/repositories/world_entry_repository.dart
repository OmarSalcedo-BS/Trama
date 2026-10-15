import '../models/world_entry.dart';

abstract class WorldEntryRepository {
  Future<List<WorldEntry>> getByCategory(String categoryId);
  Future<List<WorldEntry>> getByProject(String projectId);
  Future<WorldEntry?> getById(String id);
  Future<WorldEntry> create({
    required String projectId,
    required String categoryId,
    required String title,
    String? summary,
    String? content,
    List<String> tags,
  });
  Future<WorldEntry> update(WorldEntry entry);
  Future<void> delete(String id);
  Future<List<String>> getCharacterIds(String entryId);
  Future<void> setCharacterIds(String entryId, List<String> characterIds);
  Future<List<String>> getBestiaryIds(String entryId);
  Future<void> setBestiaryIds(String entryId, List<String> bestiaryIds);
  Future<List<String>> getRelatedEntryIds(String entryId);
  Future<void> setRelatedEntryIds(String entryId, List<String> relatedEntryIds);
}