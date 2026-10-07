import 'package:flutter/foundation.dart';

/// Modelo de proyecto (novela/saga).
/// Es un modelo propio, independiente de Supabase.
/// Incluye ya campos que quizás no usemos en el MVP pero que
/// evitaremos añadir después con migraciones.
@immutable
class Project {
  final String id;
  final String userId;
  final String title;
  final String? synopsis;
  final String? genre;
  final String? coverUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos derivados (se calculan al vuelo, no se guardan)
  final int chapterCount;
  final int characterCount;

  const Project({
    required this.id,
    required this.userId,
    required this.title,
    this.synopsis,
    this.genre,
    this.coverUrl,
    required this.createdAt,
    required this.updatedAt,
    this.chapterCount = 0,
    this.characterCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      synopsis: json['synopsis'] as String?,
      genre: json['genre'] as String?,
      coverUrl: json['cover_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      chapterCount: (json['chapter_count'] as int?) ?? 0,
      characterCount: (json['character_count'] as int?) ?? 0,
    );
  }

  /// Solo los campos que van a la base de datos.
  /// No incluye id ni timestamps (los gestiona Postgres).
  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'title': title,
        'synopsis': synopsis,
        'genre': genre,
        'cover_url': coverUrl,
      };

  /// Solo los campos editables.
  Map<String, dynamic> toUpdateJson() => {
        'title': title,
        'synopsis': synopsis,
        'genre': genre,
        'cover_url': coverUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

  Project copyWith({
    String? id,
    String? userId,
    String? title,
    String? synopsis,
    String? genre,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? chapterCount,
    int? characterCount,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      genre: genre ?? this.genre,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chapterCount: chapterCount ?? this.chapterCount,
      characterCount: characterCount ?? this.characterCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}