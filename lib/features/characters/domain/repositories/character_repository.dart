import '../models/character.dart';

/// Contrato del repositorio de personajes.
abstract class CharacterRepository {
  /// Todos los personajes de un proyecto.
  Future<List<Character>> getByProject(String projectId);

  /// Un personaje por id.
  Future<Character?> getById(String id);

  /// Crea un personaje.
  Future<Character> create({
    required String projectId,
    required String name,
    String? surname,
    String? familyName,
    String? lineageNotes,
    String? role,
    String? age,
    String? appearance,
    String? personality,
    String? motivations,
    String? backstory,
    String? arc,
    String? notes,
  });

  /// Actualiza un personaje.
  Future<Character> update(Character character);

  /// Actualiza solo los campos incluidos en el parche.
  Future<Character> updateFields({
    required String id,
    required CharacterPatch patch,
  });

  /// Elimina un personaje.
  Future<void> delete(String id);
}