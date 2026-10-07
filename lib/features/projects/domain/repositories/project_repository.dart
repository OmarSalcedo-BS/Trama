import '../models/project.dart';

/// Contrato del repositorio de proyectos.
/// Cualquier implementación (Supabase, local, mock) debe cumplirlo.
abstract class ProjectRepository {
  /// Todos los proyectos del usuario actual, ordenados por updated_at desc.
  Future<List<Project>> getByCurrentUser();

  /// Un proyecto por id.
  Future<Project?> getById(String id);

  /// Crea un proyecto nuevo. Devuelve el proyecto con id y timestamps.
  Future<Project> create({
    required String title,
    String? synopsis,
    String? genre,
  });

  /// Actualiza un proyecto existente.
  Future<Project> update(Project project);

  /// Elimina un proyecto y todo su contenido (cascade).
  Future<void> delete(String id);
}