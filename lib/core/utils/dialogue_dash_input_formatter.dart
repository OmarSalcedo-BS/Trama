import 'package:flutter/services.dart';

/// Formateador que convierte automáticamente el guión corto en guión largo
/// (raya em-dash '—' \u2014) para el estilo de diálogos literarios en español.
class DialogueDashInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si se está borrando texto, no intervenir para permitir retroceso libre
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final text = newValue.text;
    final selection = newValue.selection;
    if (!selection.isCollapsed || selection.baseOffset <= 0) {
      return newValue;
    }

    final cursor = selection.baseOffset;

    // 1. Doble guión corto "--" en cualquier parte -> raya em-dash "—"
    if (cursor >= 2 && text.substring(cursor - 2, cursor) == '--') {
      final replaced =
          '${text.substring(0, cursor - 2)}—${text.substring(cursor)}';
      final newOffset = cursor - 1; // "--" son 2 caracteres, "—" es 1
      return TextEditingValue(
        text: replaced,
        selection: TextSelection.collapsed(offset: newOffset),
      );
    }

    // 2. Guión corto al inicio de párrafo o línea ("-" -> "— "):
    if (cursor >= 1 && text[cursor - 1] == '-') {
      final isStartOfLine =
          (cursor == 1) || (cursor >= 2 && text[cursor - 2] == '\n');
      if (isStartOfLine) {
        final replaced =
            '${text.substring(0, cursor - 1)}— ${text.substring(cursor)}';
        return TextEditingValue(
          text: replaced,
          selection: TextSelection.collapsed(offset: cursor + 1),
        );
      }
    }

    // 3. Si se tecleó un guión corto seguido de espacio ("- ") al inicio de línea
    if (cursor >= 2 && text.substring(cursor - 2, cursor) == '- ') {
      final isStartOfLine =
          (cursor == 2) || (cursor >= 3 && text[cursor - 3] == '\n');
      if (isStartOfLine) {
        final replaced =
            '${text.substring(0, cursor - 2)}— ${text.substring(cursor)}';
        return TextEditingValue(
          text: replaced,
          selection: TextSelection.collapsed(offset: cursor),
        );
      }
    }

    return newValue;
  }
}
