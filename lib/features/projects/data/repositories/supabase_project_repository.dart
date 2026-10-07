import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/project_repository.dart';

class SupabaseProjectRepository implements ProjectRepository {
  final sb.SupabaseClient _client;

  SupabaseProjectRepository(this._client);

  @override
  Future<List<Project>> getByCurrentUser() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AppException(
          'No hay sesión activa.',
          code: 'no_session',
        );
      }

      // Consulta con conteos agregados de capítulos y personajes.
      // Usamos select anidado con count para no hacer N+1 consultas.
      final data = await _client
          .from('projects')
          .select('''
            *,
            chapters(count),
            characters(count)
          ''')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      return (data as List).map((json) {
        final map = Map<String, dynamic>.from(json);
        map['chapter_count'] = _extractCount(map['chapters']);
        map['character_count'] = _extractCount(map['characters']);
        map.remove('chapters');
        map.remove('characters');
        return Project.fromJson(map);
      }).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al cargar proyectos: $e');
    }
  }

  @override
  Future<Project?> getById(String id) async {
    try {
      final data = await _client
          .from('projects')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return Project.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al cargar el proyecto: $e');
    }
  }

  @override
  Future<Project> create({
    required String title,
    String? synopsis,
    String? genre,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AppException(
          'No hay sesión activa.',
          code: 'no_session',
        );
      }

      final project = Project(
        id: '',
        userId: userId,
        title: title.trim(),
        synopsis: synopsis?.trim().isEmpty == true ? null : synopsis?.trim(),
        genre: genre,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final data = await _client
          .from('projects')
          .insert(project.toInsertJson())
          .select()
          .single();

      return Project.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al crear el proyecto: $e');
    }
  }

  @override
  Future<Project> update(Project project) async {
    try {
      final data = await _client
          .from('projects')
          .update(project.toUpdateJson())
          .eq('id', project.id)
          .select()
          .single();

      return Project.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al actualizar el proyecto: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from('projects').delete().eq('id', id);
    } catch (e) {
      throw AppException('Error al eliminar el proyecto: $e');
    }
  }

  /// Extrae el count de una relación anidada de Supabase.
  /// Supabase devuelve [{count: N}] cuando pedimos `.select('chapters(count)')`.
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