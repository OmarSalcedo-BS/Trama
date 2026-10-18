// Utilidades para procesamiento, normalización y análisis de texto editorial.

/// Cuenta las palabras de un texto, contemplando caracteres acentuados y guiones.
int countWords(String text) {
  return RegExp(
    r"\b[\wÀ-ÿ]+(?:['’-][\wÀ-ÿ]+)*\b",
    unicode: true,
  ).allMatches(text).length;
}

/// Normaliza un texto removiendo acentos, signos diacríticos y espacios redundantes
/// para comparaciones de búsqueda insensibles a mayúsculas y acentos.
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

/// Verifica de forma optimizada si una cadena previamente normalizada ([normalizedContent])
/// contiene la palabra o frase [query] respetando límites de palabra.
bool fastContainsNormalized(String normalizedContent, String query) {
  final cleanQuery = normalizeSearchText(query);
  if (cleanQuery.isEmpty) return false;
  return RegExp(
    r'(?<![\p{L}\p{N}])' + RegExp.escape(cleanQuery) + r'(?![\p{L}\p{N}])',
    unicode: true,
  ).hasMatch(normalizedContent);
}

/// Determina si [text] contiene la palabra o frase [query] normalizando ambos.
bool containsSearchWord(String text, String query) {
  final normalizedText = normalizeSearchText(text);
  return fastContainsNormalized(normalizedText, query);
}
