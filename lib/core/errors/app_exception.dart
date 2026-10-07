/// Excepción tipada de la aplicación.
/// Todo error controlado debe pasar por aquí.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}