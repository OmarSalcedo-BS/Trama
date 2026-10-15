import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/chapter.dart';
import '../../domain/repositories/chapter_repository.dart';

class SupabaseChapterRepository implements ChapterRepository {
  final sb.SupabaseClient _client;
  SupabaseChapterRepository(this._client);

  @override
  Future<List<Chapter>> getByProject(String projectId) async {
    try {
      final data = await _client.from('chapters').select()
          .eq('project_id', projectId)
          .order('order_index', ascending: true)
          .order('created_at', ascending: true);
      return (data as List).map((e) => Chapter.fromJson(e)).toList();
    } catch (e) {
      throw AppException('Error al cargar capítulos: $e');
    }
  }

  @override
  Future<Chapter> create(String projectId, String title, int orderIndex) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw const AppException('El título es obligatorio.');
    if (cleanTitle.length > 120) {
      throw const AppException('El título no puede superar 120 caracteres.');
    }
    try {
      final data = await _client.from('chapters').insert({
        'project_id': projectId,
        'title': cleanTitle,
        'content': '',
        'order_index': orderIndex,
      }).select().single();
      return Chapter.fromJson(data);
    } catch (e) {
      throw AppException('Error al crear el capítulo: $e');
    }
  }

  @override
  Future<Chapter> update(Chapter chapter) async {
    try {
      final data = await _client.from('chapters')
          .update(chapter.toUpdateJson()).eq('id', chapter.id).select().single();
      return Chapter.fromJson(data);
    } catch (e) {
      throw AppException('Error al guardar el capítulo: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from('chapters').delete().eq('id', id);
    } catch (e) {
      throw AppException('Error al eliminar el capítulo: $e');
    }
  }
}
