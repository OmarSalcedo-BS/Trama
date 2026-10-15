import 'package:flutter/foundation.dart';

import '../constants/character_roles.dart';

@immutable
class Character {
  static const _unset = Object();

  final String id;
  final String projectId;
  final String name;
  final String? surname;
  final String? familyName;
  final String? lineageNotes;
  final String? avatarId;
  final String? imageUrl;
  final String? role; // código DB: protagonist, antagonist...
  final String? age;
  final String? appearance;
  final String? personality;
  final String? motivations;
  final String? backstory;
  final String? arc;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Character({
    required this.id,
    required this.projectId,
    required this.name,
    this.surname,
    this.familyName,
    this.lineageNotes,
    this.avatarId,
    this.imageUrl,
    this.role,
    this.age,
    this.appearance,
    this.personality,
    this.motivations,
    this.backstory,
    this.arc,
    this.notes,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String?,
      familyName: json['family_name'] as String?,
      lineageNotes: json['lineage_notes'] as String?,
      avatarId: json['avatar_id'] as String?,
      imageUrl: json['image_url'] as String?,
      role: json['role'] as String?,
      age: json['age'] as String?,
      appearance: json['appearance'] as String?,
      personality: json['personality'] as String?,
      motivations: json['motivations'] as String?,
      backstory: json['backstory'] as String?,
      arc: json['arc'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
    );
  }

  String get fullName {
    final parts = [
      name.trim(),
      surname?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
    return parts.isEmpty ? name : parts;
  }

  /// Variantes que el editor puede reconocer dentro del manuscrito.
  List<String> get searchableNames => {
    name,
    ?surname,
    fullName,
  }.map(normalizeSearchText).where((value) => value.isNotEmpty).toList();

  Map<String, dynamic> toInsertJson() => {
    'project_id': projectId,
    'name': name,
    'surname': surname,
    'family_name': familyName,
    'lineage_notes': lineageNotes,
    'avatar_id': avatarId,
    'image_url': imageUrl,
    'role': role,
    'age': age,
    'appearance': appearance,
    'personality': personality,
    'motivations': motivations,
    'backstory': backstory,
    'arc': arc,
    'notes': notes,
    'metadata': metadata,
  };

  Map<String, dynamic> toUpdateJson() => {
    'name': name,
    'surname': surname,
    'family_name': familyName,
    'lineage_notes': lineageNotes,
    'avatar_id': avatarId,
    'image_url': imageUrl,
    'role': role,
    'age': age,
    'appearance': appearance,
    'personality': personality,
    'motivations': motivations,
    'backstory': backstory,
    'arc': arc,
    'notes': notes,
    'metadata': metadata,
  };

  /// Etiqueta legible del rol.
  String get roleLabel => CharacterRoles.fromDbCode(role);

  /// Inicial para el avatar.
  String get initial {
    if (fullName.trim().isEmpty) return '?';
    return fullName.trim()[0].toUpperCase();
  }

  Character copyWith({
    String? id,
    String? projectId,
    String? name,
    Object? surname = _unset,
    Object? familyName = _unset,
    Object? lineageNotes = _unset,
    String? avatarId,
    String? imageUrl,
    String? role,
    String? age,
    String? appearance,
    String? personality,
    String? motivations,
    String? backstory,
    String? arc,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      surname: surname == _unset ? this.surname : surname as String?,
      familyName: familyName == _unset
          ? this.familyName
          : familyName as String?,
      lineageNotes: lineageNotes == _unset
          ? this.lineageNotes
          : lineageNotes as String?,
      avatarId: avatarId ?? this.avatarId,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      age: age ?? this.age,
      appearance: appearance ?? this.appearance,
      personality: personality ?? this.personality,
      motivations: motivations ?? this.motivations,
      backstory: backstory ?? this.backstory,
      arc: arc ?? this.arc,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Character && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const _unsetCharacterField = Object();

class CharacterPatch {
  final Object? name;
  final Object? surname;
  final Object? familyName;
  final Object? lineageNotes;
  final Object? role;
  final Object? age;
  final Object? appearance;
  final Object? personality;
  final Object? motivations;
  final Object? backstory;
  final Object? arc;
  final Object? notes;

  const CharacterPatch({
    this.name = _unsetCharacterField,
    this.surname = _unsetCharacterField,
    this.familyName = _unsetCharacterField,
    this.lineageNotes = _unsetCharacterField,
    this.role = _unsetCharacterField,
    this.age = _unsetCharacterField,
    this.appearance = _unsetCharacterField,
    this.personality = _unsetCharacterField,
    this.motivations = _unsetCharacterField,
    this.backstory = _unsetCharacterField,
    this.arc = _unsetCharacterField,
    this.notes = _unsetCharacterField,
  });

  Map<String, dynamic> toJson() {
    final values = <String, Object?>{
      'name': name,
      'surname': surname,
      'family_name': familyName,
      'lineage_notes': lineageNotes,
      'role': role,
      'age': age,
      'appearance': appearance,
      'personality': personality,
      'motivations': motivations,
      'backstory': backstory,
      'arc': arc,
      'notes': notes,
    };
    values.removeWhere((_, value) => identical(value, _unsetCharacterField));
    return values.map(
      (key, value) =>
          MapEntry(key, value is String && value.trim().isEmpty ? null : value),
    );
  }
}

String normalizeSearchText(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp('[áàäâãå]'), 'a')
      .replaceAll(RegExp('[éèëê]'), 'e')
      .replaceAll(RegExp('[íìïî]'), 'i')
      .replaceAll(RegExp('[óòöôõ]'), 'o')
      .replaceAll(RegExp('[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool containsSearchWord(String text, String query) {
  final normalizedText = normalizeSearchText(text);
  final normalizedQuery = normalizeSearchText(query);
  if (normalizedQuery.isEmpty) return false;
  return RegExp(
    r'(?<![\p{L}\p{N}])' + RegExp.escape(normalizedQuery) + r'(?![\p{L}\p{N}])',
    unicode: true,
  ).hasMatch(normalizedText);
}
