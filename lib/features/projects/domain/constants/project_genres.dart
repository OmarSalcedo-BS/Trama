/// Catálogo oficial de géneros de proyecto.
/// Fuente única de verdad. Cambiar aquí afecta a toda la app.
class ProjectGenres {
  ProjectGenres._();

  static const String fantasy = 'Fantasía';
  static const String sciFi = 'Ciencia ficción';
  static const String thriller = 'Thriller';
  static const String romance = 'Romance';
  static const String historical = 'Histórico';
  static const String horror = 'Terror';
  static const String adventure = 'Aventura';
  static const String drama = 'Drama';
  static const String other = 'Otro';

  static const List<String> all = [
    fantasy,
    sciFi,
    thriller,
    romance,
    historical,
    horror,
    adventure,
    drama,
    other,
  ];

  /// Géneros que no requieren campo de texto adicional.
  static const Set<String> predefined = {
    fantasy,
    sciFi,
    thriller,
    romance,
    historical,
    horror,
    adventure,
    drama,
  };

  static bool isPredefined(String? genre) {
    if (genre == null) return false;
    return predefined.contains(genre);
  }
}