import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'spanish_dictionary_data.dart';
import 'text_utils.dart';

/// Servicio de corrección ortográfica local en español compatible con Flutter Web y Desktop.
/// Permite omitir dinámicamente nombres de personajes y términos del Glosario.
class TramaSpellCheckService extends SpellCheckService {
  final Set<String> ignoredWords;

  TramaSpellCheckService({Set<String>? ignoredWords})
      : ignoredWords = ignoredWords?.map(normalizeSearchText).toSet() ?? {};

  @override
  Future<List<SuggestionSpan>?> fetchSpellCheckSuggestions(
    Locale locale,
    String text,
  ) async {
    if (text.trim().isEmpty) return const [];

    final spans = <SuggestionSpan>[];
    // Regex para encontrar palabras en el texto con sus posiciones
    final wordRegex = RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+(?:['’-][a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+)*");
    final matches = wordRegex.allMatches(text);

    for (final match in matches) {
      final rawWord = match.group(0);
      if (rawWord == null || rawWord.length < 2) continue;

      final normalized = normalizeSearchText(rawWord);
      // Si la palabra es un nombre de personaje o término del glosario, ignorar
      if (ignoredWords.contains(normalized)) continue;

      final lowerWord = rawWord.toLowerCase();
      // Palabras perfectamente válidas sin acento (que, como, donde, cuando, etc.)
      if (validWithoutAccentExceptions.contains(lowerWord)) continue;

      String? correction = commonSpanishCorrections[lowerWord];
      correction ??= checkCommonSuffixRule(lowerWord);

      if (correction != null && correction.toLowerCase() != lowerWord) {
        // Preservar mayúscula inicial si la palabra original la tenía
        if (rawWord[0].toUpperCase() == rawWord[0] &&
            rawWord[0].toLowerCase() != rawWord[0]) {
          correction = correction[0].toUpperCase() + correction.substring(1);
        }

        spans.add(
          SuggestionSpan(
            TextRange(start: match.start, end: match.end),
            [correction],
          ),
        );
      }
    }

    return spans;
  }
}
