import '../models/world_category.dart';

abstract class WorldCategoryRepository {
  Future<List<WorldCategory>> getByProject(String projectId);
  Future<WorldCategory?> getById(String id);
  Future<WorldCategory> create({
    required String projectId,
    required String name,
    String? description,
    required String icon,
    required String color,
  });
  Future<WorldCategory> update(WorldCategory category);
  Future<void> delete(String id);
}