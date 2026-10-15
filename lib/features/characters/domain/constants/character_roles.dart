/// Catálogo oficial de roles de personaje.
/// Fuente única de verdad. Cambiar aquí afecta a toda la app.
class CharacterRoles {
  CharacterRoles._();

  static const String protagonist = 'Protagonista';
  static const String antagonist = 'Antagonista';
  static const String secondary = 'Secundario';
  static const String tertiary = 'Terciario';
  static const String mentioned = 'Mencionado';

  static const List<String> all = [
    protagonist,
    antagonist,
    secondary,
    tertiary,
    mentioned,
  ];

  /// Códigos cortos para la base de datos.
  /// Guardamos códigos en inglés en DB y mostramos etiquetas en español.
  static const Map<String, String> dbCodeToLabel = {
    'protagonist': protagonist,
    'antagonist': antagonist,
    'secondary': secondary,
    'tertiary': tertiary,
    'mentioned': mentioned,
  };

  static const Map<String, String> labelToDbCode = {
    protagonist: 'protagonist',
    antagonist: 'antagonist',
    secondary: 'secondary',
    tertiary: 'tertiary',
    mentioned: 'mentioned',
  };

  static String toDbCode(String? label) {
    if (label == null) return 'secondary';
    return labelToDbCode[label] ?? 'secondary';
  }

  static String fromDbCode(String? code) {
    if (code == null) return secondary;
    return dbCodeToLabel[code] ?? secondary;
  }
}