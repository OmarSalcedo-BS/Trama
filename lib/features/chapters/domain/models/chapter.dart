import 'package:flutter/foundation.dart';

@immutable
class Chapter {
  final String id;
  final String projectId;
  final String title;
  final String content;
  final int orderIndex;
  final DateTime updatedAt;

  const Chapter({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.orderIndex,
    required this.updatedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        title: (json['title'] as String?) ?? 'Sin título',
        content: (json['content'] as String?) ?? '',
        orderIndex: (json['order_index'] as int?) ?? 0,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'project_id': projectId,
        'title': title,
        'content': content,
        'order_index': orderIndex,
      };

  Map<String, dynamic> toUpdateJson() => {
        'title': title,
        'content': content,
        'order_index': orderIndex,
        'updated_at': DateTime.now().toIso8601String(),
      };

  Chapter copyWith({
    String? title,
    String? content,
    int? orderIndex,
  }) =>
      Chapter(
        id: id,
        projectId: projectId,
        title: title ?? this.title,
        content: content ?? this.content,
        orderIndex: orderIndex ?? this.orderIndex,
        updatedAt: updatedAt,
      );
}
