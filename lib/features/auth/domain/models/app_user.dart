/// Modelo de usuario de la aplicación.
/// Es un modelo propio, no depende directamente de Supabase.
/// Esto permite cambiar de backend sin tocar el resto de la app.
class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
  });

  factory AppUser.fromSupabase(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['user_metadata']?['display_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'created_at': createdAt.toIso8601String(),
      };

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}