import 'dart:convert';
import 'package:http/http.dart' as http;

import 'text_utils.dart';

class LanguageToolIssue {
  final String message;
  final String? shortMessage;
  final int offset;
  final int length;
  final String badWord;
  final List<String> suggestions;
  final String category;

  const LanguageToolIssue({
    required this.message,
    this.shortMessage,
    required this.offset,
    required this.length,
    required this.badWord,
    required this.suggestions,
    required this.category,
  });
}

class LanguageToolService {
  static const String _apiUrl = 'https://api.languagetool.org/v2/check';

  /// Revisa el texto enviado contra el motor de LanguageTool en español.
  /// Omite automáticamente términos que pertenezcan a [ignoredWords].
  static Future<List<LanguageToolIssue>> checkText(
    String text, {
    Set<String>? ignoredWords,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return const [];

    final normalizedIgnored =
        ignoredWords?.map(normalizeSearchText).toSet() ?? {};

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'text': text,
          'language': 'es',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        return const [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final matches = (data['matches'] as List<dynamic>?) ?? [];
      final issues = <LanguageToolIssue>[];

      for (final item in matches) {
        final match = item as Map<String, dynamic>;
        final offset = (match['offset'] as num?)?.toInt() ?? 0;
        final length = (match['length'] as num?)?.toInt() ?? 0;

        if (offset + length > text.length) continue;
        final badWord = text.substring(offset, offset + length);

        // Si la palabra está en personajes o glosario, no reportar como error
        if (normalizedIgnored.contains(normalizeSearchText(badWord))) {
          continue;
        }

        final replacements = (match['replacements'] as List<dynamic>?)
                ?.map((r) => (r as Map<String, dynamic>)['value'] as String)
                .take(4)
                .toList() ??
            [];

        final rule = (match['rule'] as Map<String, dynamic>?) ?? {};
        final categoryMap = (rule['category'] as Map<String, dynamic>?) ?? {};
        final categoryName =
            (categoryMap['name'] as String?) ?? 'Ortografía y Gramática';

        issues.add(
          LanguageToolIssue(
            message: (match['message'] as String?) ?? 'Posible falla.',
            shortMessage: match['shortMessage'] as String?,
            offset: offset,
            length: length,
            badWord: badWord,
            suggestions: replacements,
            category: categoryName,
          ),
        );
      }

      return issues;
    } catch (_) {
      return const [];
    }
  }
}
