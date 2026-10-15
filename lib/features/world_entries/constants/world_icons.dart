import 'package:flutter/material.dart';

/// Catálogo curado de iconos para categorías de mundo.
/// Agrupados por temática para facilitar la elección.
class WorldIcons {
  WorldIcons._();

  /// Mapa de código (guardado en DB) → IconData.
  static const Map<String, IconData> _icons = {
    // Lugares
    'public': Icons.public_outlined,
    'map': Icons.map_outlined,
    'location_city': Icons.location_city_outlined,
    'castle': Icons.castle_outlined,
    'terrain': Icons.terrain_outlined,
    'forest': Icons.forest_outlined,
    'water': Icons.water_outlined,
    'sailing': Icons.sailing_outlined,

    // Facciones y sociedades
    'groups': Icons.groups_outlined,
    'gavel': Icons.gavel_outlined,
    'military_tech': Icons.military_tech_outlined,
    'diversity_3': Icons.diversity_3_outlined,
    'handshake': Icons.handshake_outlined,
    'shield': Icons.shield_outlined,
    'flag': Icons.flag_outlined,
    'crown': Icons.workspace_premium_outlined,

    // Cultura y conocimiento
    'menu_book': Icons.menu_book_outlined,
    'history_edu': Icons.history_edu_outlined,
    'school': Icons.school_outlined,
    'translate': Icons.translate_outlined,
    'palette': Icons.palette_outlined,
    'music_note': Icons.music_note_outlined,
    'auto_stories': Icons.auto_stories_outlined,

    // Ciencia, magia y tecnología
    'science': Icons.science_outlined,
    'auto_awesome': Icons.auto_awesome_outlined,
    'bolt': Icons.bolt_outlined,
    'memory': Icons.memory_outlined,
    'rocket_launch': Icons.rocket_launch_outlined,
    'precision_manufacturing': Icons.precision_manufacturing_outlined,

    // Objetos y artefactos
    'diamond': Icons.diamond_outlined,
    'inventory_2': Icons.inventory_2_outlined,
    'key': Icons.vpn_key_outlined,
    'lock': Icons.lock_outlined,
    'star': Icons.star_outline,

    // Naturaleza y fauna
    'pets': Icons.pets_outlined,
    'eco': Icons.eco_outlined,
    'bug_report': Icons.bug_report_outlined,
    'cruelty_free': Icons.cruelty_free_outlined,

    // Eventos y conceptos
    'event': Icons.event_outlined,
    'warning': Icons.warning_amber_outlined,
    'psychology': Icons.psychology_outlined,
    'lightbulb': Icons.lightbulb_outline,
    'category': Icons.category_outlined,
  };

  /// Lista completa de códigos de icono disponibles.
  static List<String> get allCodes => _icons.keys.toList();

  /// Obtiene el IconData a partir del código. Devuelve un icono por defecto
  /// si el código no existe.
  static IconData getIcon(String? code) {
    if (code == null) return Icons.category_outlined;
    return _icons[code] ?? Icons.category_outlined;
  }

  /// Código por defecto para nuevas categorías.
  static const String defaultCode = 'category';
}