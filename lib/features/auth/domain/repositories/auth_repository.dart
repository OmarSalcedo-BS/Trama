import '../models/app_user.dart';

/// Contrato del repositorio de autenticación.
/// Cualquier implementación (Supabase, Firebase, mock) debe cumplirlo.
abstract class AuthRepository {
  /// Usuario actualmente logueado, o null si no hay sesión.
  AppUser? get currentUser;

  /// Stream que emite cambios de sesión (login, logout, refresh).
  Stream<AppUser?> authStateChanges();

  /// Registro con email y contraseña.
  /// Devuelve el usuario o lanza AppException.
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Inicio de sesión con email y contraseña.
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  /// Cerrar sesión.
  Future<void> signOut();

  /// Enviar email de recuperación de contraseña.
  Future<void> sendPasswordReset(String email);
}