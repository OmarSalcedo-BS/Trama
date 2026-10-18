import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/language_tool_service.dart';

class SpellCheckResultDialog extends StatefulWidget {
  final String initialText;
  final List<LanguageToolIssue> issues;

  const SpellCheckResultDialog({
    super.key,
    required this.initialText,
    required this.issues,
  });

  @override
  State<SpellCheckResultDialog> createState() => _SpellCheckResultDialogState();
}

class _SpellCheckResultDialogState extends State<SpellCheckResultDialog> {
  late String _currentText;
  late List<LanguageToolIssue> _remainingIssues;

  @override
  void initState() {
    super.initState();
    _currentText = widget.initialText;
    _remainingIssues = List.from(widget.issues);
  }

  void _applyCorrection(LanguageToolIssue issue, String replacement) {
    setState(() {
      _currentText = _currentText.replaceRange(
        issue.offset,
        issue.offset + issue.length,
        replacement,
      );
      _remainingIssues.remove(issue);

      // Ajustar offsets de los issues subsiguientes debido al cambio de longitud
      final diff = replacement.length - issue.length;
      if (diff != 0) {
        _remainingIssues = _remainingIssues.map((item) {
          if (item.offset > issue.offset) {
            return LanguageToolIssue(
              message: item.message,
              shortMessage: item.shortMessage,
              offset: item.offset + diff,
              length: item.length,
              badWord: item.badWord,
              suggestions: item.suggestions,
              category: item.category,
            );
          }
          return item;
        }).toList();
      }
    });
  }

  void _applyAllFirstSuggestions() {
    var text = _currentText;
    // Ordenar de atrás hacia adelante para no desfasar los offsets
    final sorted = List<LanguageToolIssue>.from(_remainingIssues)
      ..sort((a, b) => b.offset.compareTo(a.offset));

    for (final issue in sorted) {
      if (issue.suggestions.isNotEmpty) {
        text = text.replaceRange(
          issue.offset,
          issue.offset + issue.length,
          issue.suggestions.first,
        );
      }
    }

    setState(() {
      _currentText = text;
      _remainingIssues.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.fact_check_outlined,
            color: AppColors.primaryContainer,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('Revisión profunda del manuscrito'),
          const Spacer(),
          if (_remainingIssues.isNotEmpty)
            Text(
              '${_remainingIssues.length} sugerencias',
              style: AppTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant),
            ),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 420,
        child: _remainingIssues.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primaryContainer,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '¡Excelente redacción!',
                      style: AppTypography.headlineSm,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'No se encontraron faltas ortográficas ni gramaticales pendientes.',
                      style: AppTypography.uiBodySm,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: _remainingIssues.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final issue = _remainingIssues[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: AppRadii.allSm,
                              ),
                              child: Text(
                                issue.badWord,
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                issue.message,
                                style: AppTypography.uiBodySm,
                              ),
                            ),
                          ],
                        ),
                        if (issue.suggestions.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Sugerencias:',
                                style: AppTypography.labelXs.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              ...issue.suggestions.map(
                                (sug) => ActionChip(
                                  label: Text(sug),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _applyCorrection(issue, sug),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        if (_remainingIssues.isNotEmpty &&
            _remainingIssues.any((i) => i.suggestions.isNotEmpty))
          TextButton.icon(
            icon: const Icon(Icons.auto_fix_high, size: 16),
            label: const Text('Corregir todo automáticamente'),
            onPressed: _applyAllFirstSuggestions,
          ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _currentText),
          child: const Text('Aplicar cambios'),
        ),
      ],
    );
  }
}
