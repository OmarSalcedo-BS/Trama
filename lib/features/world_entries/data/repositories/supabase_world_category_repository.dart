import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/world_category.dart';
import '../../domain/repositories/world_category_repository.dart';

class SupabaseWorldCategoryRepository implements WorldCategoryRepository {
  final sb.SupabaseClient _client;

  SupabaseWorldCategoryRepository(this._client);

  @override
  Future<List<WorldCategory>> getByProject(String projectId) async {
    try {
      final data = await _client
          .from('world_categories')
          .select('''
            *,
            world_entries(count)
          ''')
          .eq('project_id', projectId)
          .order('order_index', ascending: true)
          .order('name', ascending: true);

      return (data as List).map((json) {
        final map = Map<String, dynamic>.from(json);
        map['entry_count'] = _extractCount(map['world_entries']);
        map.remove('world_entries');
        return WorldCategory.fromJson(map);
      }).toList();
    } catch (e) {
      throw AppException('Error al cargar categorías: $e');
    }
  }

  @override
  Future<WorldCategory?> getById(String id) async {
    try {
      final data = await _client
          .from('world_categories')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return WorldCategory.fromJson(data);
    } catch (e) {
      throw AppException('Error al cargar la categoría: $e');
    }
  }

  @override
  Future<WorldCategory> create({
    required String projectId,
    required String name,
    String? description,
    required String icon,
    required String color,
  }) async {
    try {
      final category = WorldCategory(
        id: '',
        projectId: projectId,
        name: name.trim(),
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        icon: icon,
        color: color,
        createdAt: DateTime.now(),
      );

      final data = await _client
          .from('world_categories')
          .insert(category.toInsertJson())
          .select()
          .single();

      return WorldCategory.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al crear la categoría: $e');
    }
  }

  @override
  Future<WorldCategory> update(WorldCategory category) async {
    try {
      final data = await _client
          .from('world_categories')
          .update(category.toUpdateJson())
          .eq('id', category.id)
          .select()
          .single();

      return WorldCategory.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al actualizar la categoría: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from('world_categories').delete().eq('id', id);
    } catch (e) {
      throw AppException('Error al eliminar la categoría: $e');
    }
  }

  int _extractCount(dynamic value) {
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map && first['count'] is int) {
        return first['count'] as int;
      }
    }
    return 0;
  }
}