import '../models/chapter.dart';

abstract class ChapterRepository {
  Future<List<Chapter>> getByProject(String projectId);
  Future<Chapter> create(String projectId, String title, int orderIndex);
  Future<Chapter> update(Chapter chapter);
  Future<void> delete(String id);
}
