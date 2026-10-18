import 'package:flutter/foundation.dart';

@immutable
class WorldEntry {
  final String id;
  final String projectId;
  final String categoryId;
  final String title;
  final String? summary;
  final String? content;
  final List<String> tags;
  final List<String> characterIds;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorldEntry({
    required this.id,
    required this.projectId,
    required this.categoryId,
    required this.title,
    this.summary,
    this.content,
    this.tags = const [],
    this.characterIds = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorldEntry.fromJson(Map<String, dynamic> json) {
    return WorldEntry(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      content: json['content'] is String
          ? json['content'] as String
          : null,
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      characterIds: (json['character_ids'] as List?)?.cast<String>() ?? const [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'project_id': projectId,
        'category_id': categoryId,
        'title': title,
        'summary': summary,
        'content': content,
        'tags': tags,
        'metadata': metadata,
      };

  Map<String, dynamic> toUpdateJson() => {
        'category_id': categoryId,
        'title': title,
        'summary': summary,
        'content': content,
        'tags': tags,
        'metadata': metadata,
        'updated_at': DateTime.now().toIso8601String(),
      };

  WorldEntry copyWith({
    String? id,
    String? projectId,
    String? categoryId,
    String? title,
    String? summary,
    String? content,
    List<String>? tags,
    List<String>? characterIds,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorldEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      characterIds: characterIds ?? this.characterIds,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}