import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class ImportedChapter {
  final String title;
  final String content;

  const ImportedChapter({required this.title, required this.content});
}

class DocxManuscriptImporter {
  const DocxManuscriptImporter();

  List<ImportedChapter> parse(Uint8List bytes, {required String fileName}) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final documentFile = archive.findFile('word/document.xml');
    if (documentFile == null) {
      throw const FormatException(
        'El archivo no contiene un documento DOCX válido.',
      );
    }

    final documentBytes = documentFile.content as List<int>;
    final documentXml = utf8.decode(documentBytes);
    final xml = XmlDocument.parse(documentXml);
    final paragraphs = xml.findAllElements('w:p');
    final chapters = <ImportedChapter>[];
    var currentTitle = '';
    final currentParagraphs = <String>[];

    void flush() {
      final content = currentParagraphs
          .map((paragraph) => paragraph.trim())
          .where((paragraph) => paragraph.isNotEmpty)
          .join('\n\n')
          .trim();
      if (currentTitle.isNotEmpty || content.isNotEmpty) {
        chapters.add(
          ImportedChapter(
            title: currentTitle.isEmpty
                ? 'Capítulo ${chapters.length + 1}'
                : currentTitle,
            content: content,
          ),
        );
      }
      currentTitle = '';
      currentParagraphs.clear();
    }

    for (final paragraph in paragraphs) {
      final text = _paragraphText(paragraph);
      if (text.trim().isEmpty) continue;

      final style = paragraph
          .findAllElements('w:pStyle')
          .map((node) => node.getAttribute('w:val') ?? '')
          .firstWhere((value) => value.isNotEmpty, orElse: () => '');
      if (_isChapterHeading(style)) {
        flush();
        currentTitle = text.trim();
      } else {
        currentParagraphs.add(text);
      }
    }
    flush();

    if (chapters.isEmpty) {
      throw FormatException('No se encontró texto utilizable en "$fileName".');
    }
    return chapters;
  }

  bool _isChapterHeading(String style) {
    final normalized = style.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    return normalized.contains('heading1') ||
        normalized.contains('título1') ||
        normalized.contains('titulo1') ||
        normalized == 'title' ||
        normalized == 'chapter';
  }

  String _paragraphText(XmlElement paragraph) {
    final buffer = StringBuffer();
    for (final node in paragraph.descendants.whereType<XmlElement>()) {
      switch (node.localName) {
        case 't':
          buffer.write(node.innerText);
        case 'tab':
          buffer.write('\t');
        case 'br':
        case 'cr':
          buffer.write('\n');
      }
    }
    return buffer.toString();
  }
}
