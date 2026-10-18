import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../chapters/presentation/providers/chapter_providers.dart';
import '../../data/docx_manuscript_importer.dart';

class ImportExportScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ImportExportScreen({super.key, required this.projectId});

  @override
  ConsumerState<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends ConsumerState<ImportExportScreen> {
  List<ImportedChapter>? _preview;
  String? _fileName;
  bool _isImporting = false;

  Future<void> _selectDocx() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx'],
      );
      if (result.isEmpty) return;
      final file = result.single;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const FormatException(
          'No se pudo leer el contenido del archivo.',
        );
      }
      final chapters = const DocxManuscriptImporter().parse(
        bytes,
        fileName: file.name,
      );
      if (!mounted) return;
      setState(() {
        _fileName = file.name;
        _preview = chapters;
      });
    } on FormatException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('No se pudo analizar el DOCX: $error');
    }
  }

  Future<void> _importChapters() async {
    final chapters = _preview;
    if (chapters == null || chapters.isEmpty || _isImporting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Importar manuscrito'),
        content: Text(
          'Se crearán ${chapters.length} capítulos en este proyecto. '
          'No se crearán personajes, relaciones ni fichas del mundo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Crear capítulos'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isImporting = true);
    try {
      final current = await ref
          .read(chapterRepositoryProvider)
          .getByProject(widget.projectId);
      var nextOrder = current.isEmpty
          ? 0
          : current
                    .map((chapter) => chapter.orderIndex)
                    .reduce((a, b) => a > b ? a : b) +
                1;
      for (final chapter in chapters) {
        final created = await ref
            .read(chapterRepositoryProvider)
            .create(widget.projectId, chapter.title, nextOrder++);
        await ref
            .read(chapterRepositoryProvider)
            .update(created.copyWith(content: chapter.content));
      }
      ref.invalidate(chaptersProvider(widget.projectId));
      if (!mounted) return;
      setState(() {
        _preview = null;
        _fileName = null;
      });
      _showMessage('Manuscrito importado correctamente.');
    } catch (error) {
      _showMessage('La importación se detuvo: $error');
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Publicar e importar', style: AppTypography.headlineLg),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Organiza tu manuscrito sin crear personajes ni elementos del mundo.',
                style: AppTypography.uiBodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Importar desde Word',
                        style: AppTypography.headlineSm,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Usa estilos Título 1 / Heading 1 para marcar cada capítulo. '
                        'El texto se procesa localmente y solo se guardan capítulos y contenido.',
                        style: AppTypography.uiBodySm,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: _isImporting ? null : _selectDocx,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Seleccionar archivo .docx'),
                      ),
                      if (_fileName != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Archivo: $_fileName',
                          style: AppTypography.labelMd,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (preview != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _PreviewCard(chapters: preview),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: _isImporting ? null : _importChapters,
                  icon: _isImporting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _isImporting
                        ? 'Importando...'
                        : 'Importar ${preview.length} capítulos',
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Card(
                color: AppColors.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.picture_as_pdf_outlined),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'La exportación editorial a PDF y DOCX queda preparada como siguiente bloque. '
                          'La importación no modifica fichas, personajes ni relaciones existentes.',
                          style: AppTypography.uiBodySm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _FeedbackCard(projectId: widget.projectId),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final List<ImportedChapter> chapters;

  const _PreviewCard({required this.chapters});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vista previa', style: AppTypography.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            Text('${chapters.length} capítulos detectados'),
            const SizedBox(height: AppSpacing.md),
            ...chapters
                .take(8)
                .map(
                  (chapter) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: AppRadii.allSm,
                      ),
                      child: Text(
                        chapter.title,
                        style: AppTypography.uiBodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            if (chapters.length > 8)
              Text('+ ${chapters.length - 8} capítulos más'),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatefulWidget {
  final String projectId;

  const _FeedbackCard({required this.projectId});

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {
  final _textController = TextEditingController();
  String _selectedCategory = 'Error o fallo';
  bool _isSending = false;

  static const _targetEmail = 'salcedosolarteomar@gmail.com';

  final _categories = const [
    'Error o fallo',
    'Sugerencia de mejora',
    'Comentario general',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe tu comentario o reporte antes de enviar.'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    final projectShort = widget.projectId.length >= 8
        ? widget.projectId.substring(0, 8)
        : widget.projectId;

    final subject = '[Trama Alpha] $_selectedCategory - Proyecto $projectShort';
    final body = '''Hola Omar,

Te envío este reporte sobre Trama Alpha:

- Tipo: $_selectedCategory
- ID de Proyecto: ${widget.projectId}
- Fecha: ${DateTime.now().toLocal()}

Detalles:
$text

---
Enviado desde Trama Web Alpha''';

    final emailUri = Uri(
      scheme: 'mailto',
      path: _targetEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await _copyEmailFallback();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abriendo tu gestor de correo para enviar el reporte.'),
            ),
          );
        }
      }
    } catch (_) {
      await _copyEmailFallback();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _copyEmailFallback() async {
    await Clipboard.setData(const ClipboardData(text: _targetEmail));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se copió la dirección al portapapeles ($_targetEmail). Puedes enviar tu reporte manualmente.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.allMd,
        side: const BorderSide(color: AppColors.outlineVariant, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: AppRadii.allSm,
                  ),
                  child: const Icon(
                    Icons.rate_review_outlined,
                    color: AppColors.primaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reportar error o enviar retroalimentación',
                        style: AppTypography.headlineSm,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tu opinión es vital en esta Alpha. Los informes llegan directamente a $_targetEmail',
                        style: AppTypography.uiBodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Tipo de informe', style: AppTypography.labelMd),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Descripción del reporte', style: AppTypography.labelMd),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _textController,
              maxLines: 4,
              style: AppTypography.uiBodyMd,
              decoration: InputDecoration(
                hintText:
                    'Cuéntanos qué estabas haciendo, qué falló o qué función te gustaría que existiera...',
                border: OutlineInputBorder(
                  borderRadius: AppRadii.allSm,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                FilledButton.icon(
                  onPressed: _isSending ? null : _sendFeedback,
                  icon: _isSending
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined, size: 18),
                  label: const Text('Enviar reporte por correo'),
                ),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: _copyEmailFallback,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Copiar correo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

