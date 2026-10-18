import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/characters/domain/models/character.dart';
import '../../features/story_tools/domain/models/story_tool_models.dart';

/// Almacenamiento local para persistir las posiciones personalizadas de los personajes
/// en el lienzo de relaciones por proyecto.
class RelationshipPositionStore {
  static String _key(String projectId) => 'relationship_node_positions_$projectId';

  /// Carga las coordenadas guardadas de los personajes.
  static Future<Map<String, Offset>> loadPositions(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(projectId));
      if (raw == null) return {};
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((id, coords) {
        final point = coords as Map<String, dynamic>;
        return MapEntry(
          id,
          Offset(
            (point['x'] as num).toDouble(),
            (point['y'] as num).toDouble(),
          ),
        );
      });
    } catch (_) {
      return {};
    }
  }

  /// Guarda las coordenadas en memoria local persistente.
  static Future<void> savePositions(
    String projectId,
    Map<String, Offset> positions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = positions.map(
        (id, offset) => MapEntry(id, {'x': offset.dx, 'y': offset.dy}),
      );
      await prefs.setString(_key(projectId), jsonEncode(map));
    } catch (_) {}
  }
}

/// Filtra los personajes visibles según la búsqueda:
/// Si query está vacía, devuelve todos los personajes.
/// Si query tiene texto, incluye los personajes coincidentes Y además
/// a todos los personajes que mantienen vínculos con ellos.
List<Character> filterCharactersWithConnectedRelationships(
  List<Character> allCharacters,
  List<CharacterRelationship> links,
  String query,
) {
  final cleanQuery = normalizeSearchText(query);
  if (cleanQuery.isEmpty) return allCharacters;

  // 1. Personajes que coinciden con el texto buscado
  final matchedIds = allCharacters
      .where((c) =>
          c.searchableNames.any((name) => normalizeSearchText(name).contains(cleanQuery)))
      .map((c) => c.id)
      .toSet();

  if (matchedIds.isEmpty) return const [];

  // 2. Extender a todos los personajes que comparten relación con los coincidentes
  final connectedIds = <String>{...matchedIds};
  for (final link in links) {
    if (matchedIds.contains(link.sourceCharacterId)) {
      connectedIds.add(link.targetCharacterId);
    }
    if (matchedIds.contains(link.targetCharacterId)) {
      connectedIds.add(link.sourceCharacterId);
    }
  }

  return allCharacters.where((c) => connectedIds.contains(c.id)).toList();
}

/// Extrae de forma dinámica todos los tipos de vínculos registrados en el proyecto,
/// asegurando que cualquier categoría personalizada aparezca en el filtro.
List<String> extractUniqueRelationTypes(List<CharacterRelationship> links) {
  final types = <String>{'Todos'};
  for (final link in links) {
    final clean = link.relationType.trim();
    if (clean.isNotEmpty) {
      types.add(clean);
    }
  }
  return types.toList();
}

/// Comprueba si el tipo de relación coincide con el filtro seleccionado.
bool matchesRelationFilter(String relationType, String selectedFilter) {
  if (selectedFilter == 'Todos') return true;
  return relationType.trim().toLowerCase() == selectedFilter.trim().toLowerCase();
}

/// Calcula posiciones automáticas en disposición circular sobre un tamaño de lienzo dado.
Map<String, Offset> calculateDefaultNodePositions(
  List<Character> characters,
  Size canvasSize, {
  double radiusMultiplier = 0.32,
}) {
  final positions = <String, Offset>{};
  if (characters.isEmpty) return positions;

  final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
  final radius =
      math.min(canvasSize.width, canvasSize.height) * radiusMultiplier;

  for (var i = 0; i < characters.length; i++) {
    final angle = -math.pi / 2 + (i * 2 * math.pi / characters.length);
    positions[characters[i].id] = center +
        Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }

  return positions;
}

/// Asigna colores representativos a los tipos de relación.
Color relationTypeColor(String relation) {
  final value = normalizeSearchText(relation);
  if (value.contains('famil') ||
      value.contains('padre') ||
      value.contains('madre') ||
      value.contains('hijo') ||
      value.contains('herman')) {
    return Colors.cyan;
  }
  if (value.contains('pareja') ||
      value.contains('romance') ||
      value.contains('amor') ||
      value.contains('conyuge')) {
    return Colors.pinkAccent;
  }
  if (value.contains('rival') ||
      value.contains('enem') ||
      value.contains('odio') ||
      value.contains('adversario')) {
    return Colors.deepOrange;
  }
  if (value.contains('aliad') ||
      value.contains('amig') ||
      value.contains('socio') ||
      value.contains('leal')) {
    return Colors.green;
  }
  if (value.contains('mentor') ||
      value.contains('maestr') ||
      value.contains('guia')) {
    return Colors.amber;
  }
  return Colors.indigoAccent;
}

/// Determina si la relación es tensa/conflictiva para dibujarla punteada.
bool isTenseRelation(String relation) {
  final value = normalizeSearchText(relation);
  return value.contains('rival') ||
      value.contains('enem') ||
      value.contains('tens') ||
      value.contains('odio');
}
