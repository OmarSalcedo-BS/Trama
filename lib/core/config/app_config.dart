/// Configuración global de la aplicación.
class AppConfig {
  /// Si está en `true`, la vista de autenticación convencional se oculta
  /// y se muestra la pantalla de acceso Alpha mediante código de prueba.
  /// Si está en `false`, se restaura la vista de registro e inicio de sesión original.
  static const bool isAlphaMode = true;

  /// Correo de contacto visible para los usuarios que quieran solicitar un código de prueba.
  static const String alphaContactEmail = 'salcedosolarteomar@gmail.com';

  /// Nombre de la versión o etiqueta del release.
  static const String appVersion = '0.1.0-alpha';
}
