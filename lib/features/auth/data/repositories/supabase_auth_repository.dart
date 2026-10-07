import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final sb.SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  // ============================================
  // GETTERS
  // ============================================

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _toAppUser(user);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user == null ? null : _toAppUser(user);
    });
  }

  // ============================================
  // SIGN UP
  // ============================================

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // 1. Registrar usuario en Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      final user = response.user;
      if (user == null) {
        throw const AppException(
          'No se pudo completar el registro.',
          code: 'sign_up_failed',
        );
      }

      // 2. Crear el perfil en la tabla profiles
      //    Si falla, no bloqueamos el registro.
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'display_name': displayName,
        });
      } catch (profileError) {
        // ignore: avoid_print
        print('Aviso: no se pudo crear el perfil: $profileError');
      }

      return _toAppUser(user);
    } on sb.AuthException catch (e) {
      throw AppException(
        _translateAuthError(e),
        code: e.statusCode,
      );
    } catch (e) {
      throw AppException('Error inesperado al registrarse: $e');
    }
  }

  // ============================================
  // SIGN IN
  // ============================================

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AppException(
          'Credenciales incorrectas.',
          code: 'sign_in_failed',
        );
      }

      return _toAppUser(user);
    } on sb.AuthException catch (e) {
      throw AppException(
        _translateAuthError(e),
        code: e.statusCode,
      );
    } catch (e) {
      throw AppException('Error inesperado al iniciar sesión: $e');
    }
  }

  // ============================================
  // SIGN OUT
  // ============================================

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppException('Error al cerrar sesión: $e');
    }
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on sb.AuthException catch (e) {
      throw AppException(
        _translateAuthError(e),
        code: e.statusCode,
      );
    }
  }

  // ============================================
  // HELPERS PRIVADOS
  // ============================================

  /// Convierte un User de Supabase en nuestro AppUser.
  AppUser _toAppUser(sb.User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  /// Traduce los errores de Supabase Auth a mensajes en español.
  String _translateAuthError(sb.AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Email o contraseña incorrectos.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Debes confirmar tu email antes de iniciar sesión.';
    }
    if (msg.contains('user already registered')) {
      return 'Ya existe una cuenta con ese email.';
    }
    if (msg.contains('password should be at least')) {
      return 'La contraseña es demasiado corta.';
    }
    if (msg.contains('unable to validate email')) {
      return 'El formato del email no es válido.';
    }
    if (msg.contains('rate limit')) {
      return 'Demasiados intentos. Espera un momento.';
    }
    if (msg.contains('signup is disabled')) {
      return 'El registro está desactivado temporalmente.';
    }
    return e.message;
  }
}