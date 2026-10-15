import 'package:flutter/material.dart';

/// Catálogo de colores para categorías de mundo.
/// Paleta coherente con el diseño editorial de Trama.
class WorldColors {
  WorldColors._();

  /// Mapa de código (guardado en DB) → valor de color.
  static const Map<String, Color> _colors = {
    'indigo': Color(0xFF4F46E5),     // Acento principal de Trama
    'violet': Color(0xFF7C3AED),
    'blue': Color(0xFF2563EB),
    'sky': Color(0xFF0284C7),
    'teal': Color(0xFF0D9488),
    'emerald': Color(0xFF059669),
    'green': Color(0xFF16A34A),
    'lime': Color(0xFF65A30D),
    'amber': Color(0xFFD97706),
    'orange': Color(0xFFEA580C),
    'red': Color(0xFFDC2626),
    'rose': Color(0xFFE11D48),
    'pink': Color(0xFFDB2777),
    'fuchsia': Color(0xFFC026D3),
    'purple': Color(0xFF9333EA),
    'slate': Color(0xFF475569),
  };

  static List<String> get allCodes => _colors.keys.toList();

  static Color getColor(String? code) {
    if (code == null) return _colors['indigo']!;
    return _colors[code] ?? _colors['indigo']!;
  }

  static const String defaultCode = 'indigo';

  /// Etiqueta legible en español para cada código.
  static const Map<String, String> _labels = {
    'indigo': 'Índigo',
    'violet': 'Violeta',
    'blue': 'Azul',
    'sky': 'Cielo',
    'teal': 'Turquesa',
    'emerald': 'Esmeralda',
    'green': 'Verde',
    'lime': 'Lima',
    'amber': 'Ámbar',
    'orange': 'Naranja',
    'red': 'Rojo',
    'rose': 'Rosa',
    'pink': 'Fucsia claro',
    'fuchsia': 'Fucsia',
    'purple': 'Púrpura',
    'slate': 'Pizarra',
  };

  static String getLabel(String code) => _labels[code] ?? code;
}