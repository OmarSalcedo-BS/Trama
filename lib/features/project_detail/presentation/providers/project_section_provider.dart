import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Secciones del proyecto.
enum ProjectSection {
  overview,
  chapters,
  characters,
  worldEntries,
  bestiary,
  timeline,
  glossary,
  relationships,
  export;

  /// Etiqueta visible.
  String get label {
    switch (this) {
      case ProjectSection.overview:      return 'Resumen';
      case ProjectSection.chapters:      return 'Capítulos';
      case ProjectSection.characters:    return 'Personajes';
      case ProjectSection.worldEntries:  return 'Fichas de mundo';
      case ProjectSection.bestiary:      return 'Bestiario';
      case ProjectSection.timeline:      return 'Cronología';
      case ProjectSection.glossary:      return 'Glosario';
      case ProjectSection.relationships: return 'Relaciones';
      case ProjectSection.export:        return 'Exportar';
    }
  }
}

/// Sección activa del proyecto actual.
/// Es un provider por proyecto (family) para poder tener varios abiertos a la vez.
final activeSectionProvider =
    StateProvider.family<ProjectSection, String>((ref, projectId) {
  return ProjectSection.overview;
});