import 'package:flutter/foundation.dart';

@immutable
class WorldCategory {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final String icon;   // código del catálogo WorldIcons
  final String color;  // código del catálogo WorldColors
  final int orderIndex;
  final DateTime createdAt;

  // Conteo de fichas (derivado, no se guarda)
  final int entryCount;

  const WorldCategory({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    this.orderIndex = 0,
    required this.createdAt,
    this.entryCount = 0,
  });

  factory WorldCategory.fromJson(Map<String, dynamic> json) {
    return WorldCategory(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? 'category',
      color: json['color'] as String? ?? 'indigo',
      orderIndex: json['order_index'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      entryCount: (json['entry_count'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'project_id': projectId,
        'name': name,
        'description': description,
        'icon': icon,
        'color': color,
        'order_index': orderIndex,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'description': description,
        'icon': icon,
        'color': color,
        'order_index': orderIndex,
      };

  WorldCategory copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    String? icon,
    String? color,
    int? orderIndex,
    DateTime? createdAt,
    int? entryCount,
  }) {
    return WorldCategory(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      entryCount: entryCount ?? this.entryCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}