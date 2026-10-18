import 'package:flutter/foundation.dart';

@immutable
class DraftNote {
  final String id;
  final String projectId;
  final String title;
  final String content;
  final String status;
  final DateTime updatedAt;

  const DraftNote({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.status,
    required this.updatedAt,
  });

  factory DraftNote.fromJson(Map<String, dynamic> json) => DraftNote(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        title: json['title'] as String,
        content: (json['content'] as String?) ?? '',
        status: (json['status'] as String?) ?? 'draft',
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'project_id': projectId,
        'title': title,
        'content': content,
        'status': status,
      };
}

@immutable
class GlossaryTerm {
  final String id;
  final String projectId;
  final String term;
  final String definition;
  final String? category;
  final DateTime updatedAt;

  const GlossaryTerm({
    required this.id,
    required this.projectId,
    required this.term,
    required this.definition,
    this.category,
    required this.updatedAt,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) => GlossaryTerm(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        term: json['term'] as String,
        definition: (json['definition'] as String?) ?? '',
        category: json['category'] as String?,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'project_id': projectId,
        'term': term,
        'definition': definition,
        'category': category,
      };
}

@immutable
class TimelineEvent {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final DateTime updatedAt;

  const TimelineEvent({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.eventDate,
    required this.updatedAt,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        eventDate: DateTime.parse(json['event_date'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'project_id': projectId,
        'title': title,
        'description': description,
        'event_date': eventDate.toIso8601String(),
      };
}

@immutable
class CharacterRelationship {
  final String id;
  final String projectId;
  final String sourceCharacterId;
  final String targetCharacterId;
  final String relationType;
  final String? description;

  const CharacterRelationship({
    required this.id,
    required this.projectId,
    required this.sourceCharacterId,
    required this.targetCharacterId,
    required this.relationType,
    this.description,
  });

  factory CharacterRelationship.fromJson(Map<String, dynamic> json) =>
      CharacterRelationship(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        sourceCharacterId: json['source_character_id'] as String,
        targetCharacterId: json['target_character_id'] as String,
        relationType: json['relation_type'] as String,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toInsertJson() => {
        'project_id': projectId,
        'source_character_id': sourceCharacterId,
        'target_character_id': targetCharacterId,
        'relation_type': relationType,
        'description': description,
      };
}

@immutable
class BestiaryEntry {
  final String id;
  final String projectId;
  final String name;
  final String? category;
  final String? mythology;
  final String description;
  final String? weaknesses;
  final String? abilities;
  final String? habitat;
  final String? dangerLevel;
  final String? historicalReferences;
  final String? diet;
  final String? storyContext;
  final DateTime updatedAt;

  const BestiaryEntry({
    required this.id,
    required this.projectId,
    required this.name,
    this.category,
    this.mythology,
    required this.description,
    this.weaknesses,
    this.abilities,
    this.habitat,
    this.dangerLevel,
    this.historicalReferences,
    this.diet,
    this.storyContext,
    required this.updatedAt,
  });

  factory BestiaryEntry.fromJson(Map<String, dynamic> json) => BestiaryEntry(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        name: json['name'] as String,
        category: json['category'] as String?,
        mythology: json['mythology'] as String?,
        description: (json['description'] as String?) ?? '',
        weaknesses: json['weaknesses'] as String?,
        abilities: json['abilities'] as String?,
        habitat: json['habitat'] as String?,
        dangerLevel: json['danger_level'] as String?,
        historicalReferences: json['historical_references'] as String?,
        diet: json['diet'] as String?,
        storyContext: json['story_context'] as String?,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'project_id': projectId,
        'name': name,
        'category': category,
        'mythology': mythology,
        'description': description,
        'weaknesses': weaknesses,
        'abilities': abilities,
        'habitat': habitat,
        'danger_level': dangerLevel,
        'historical_references': historicalReferences,
        'diet': diet,
        'story_context': storyContext,
      };
}
