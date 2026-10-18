import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/dialogue_dash_input_formatter.dart';
import '../../../../core/utils/language_tool_service.dart';
import '../../../../core/utils/text_utils.dart';
import '../../../../core/utils/trama_spell_check_service.dart';
import '../../../../core/widgets/spell_check_dialog.dart';
import '../../../characters/domain/models/character.dart';
import '../../../characters/presentation/providers/character_providers.dart';
import '../../../story_tools/domain/models/story_tool_models.dart';
import '../../../story_tools/presentation/providers/story_tools_providers.dart';
import '../../domain/models/chapter.dart';
import '../providers/chapter_providers.dart';

class ChapterEditorScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ChapterEditorScreen({super.key, required this.projectId});

  @override
  ConsumerState<ChapterEditorScreen> createState() =>
      _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends ConsumerState<ChapterEditorScreen> {
  String? _selectedId;
  Chapter? _selectedChapter;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contentFocus = FocusNode();

  // Optimización de rendimiento:
  // Notifiers desacoplados para evitar reconstruir el TextField en cada pulsación
  late final ValueNotifier<int> _wordCountNotifier;
  late final ValueNotifier<String> _analysisContentNotifier;

  Timer? _saveTimer;
  Timer? _analysisDebounceTimer;
  bool _isSaving = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _wordCountNotifier = ValueNotifier<int>(0);
    _analysisContentNotifier = ValueNotifier<String>('');
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _analysisDebounceTimer?.cancel();
    _wordCountNotifier.dispose();
    _analysisContentNotifier.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _selectChapter(Chapter chapter) {
    if (_selectedId == chapter.id) return;
    _saveNow();
    setState(() {
      _selectedId = chapter.id;
      _selectedChapter = chapter;
      _titleController.text = chapter.title;
      _contentController.text = chapter.content;
      _isDirty = false;
    });
    _wordCountNotifier.value = countWords(chapter.content);
    _analysisContentNotifier.value = chapter.content;
  }

  void _onTextChanged() {
    if (_selectedChapter == null) return;
    _isDirty = true;

    // Debounce del análisis para mantener el editor ultra fluido a 60 FPS
    _analysisDebounceTimer?.cancel();
    _analysisDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _wordCountNotifier.value = countWords(_contentController.text);
      _analysisContentNotifier.value = _contentController.text;
    });

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 900), _saveNow);
  }

  Future<void> _saveNow() async {
    final chapter = _selectedChapter;
    if (chapter == null || !_isDirty || _isSaving) return;
    _saveTimer?.cancel();
    setState(() => _isSaving = true);
    final updated = chapter.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Sin título'
          : _titleController.text.trim(),
      content: _contentController.text,
    );
    final saved = await ref
        .read(chapterControllerProvider.notifier)
        .update(updated);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (saved) {
        _selectedChapter = updated;
        _isDirty = false;
      }
    });
  }

  Future<void> _createChapter(List<Chapter> chapters) async {
    final title = await _chapterTitleDialog(context);
    if (title == null) return;
    final chapter = await ref
        .read(chapterControllerProvider.notifier)
        .create(
          widget.projectId,
          title,
          chapters.isEmpty
              ? 0
              : chapters
                        .map((chapter) => chapter.orderIndex)
                        .reduce((a, b) => a > b ? a : b) +
                    1,
        );
    if (!mounted || chapter == null) return;
    _selectChapter(chapter);
  }

  Future<void> _deleteChapter(Chapter chapter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar capítulo'),
        content: Text(
          '¿Eliminar "${chapter.title}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _saveNow();
    await ref.read(chapterControllerProvider.notifier).delete(chapter);
    if (!mounted) return;
    setState(() {
      _selectedId = null;
      _selectedChapter = null;
      _titleController.clear();
      _contentController.clear();
    });
    _wordCountNotifier.value = 0;
    _analysisContentNotifier.value = '';
  }

  Future<void> _runDeepSpellCheck(Set<String> ignoredWords) async {
    final currentText = _contentController.text;
    if (currentText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El capítulo está vacío para revisar.')),
      );
      return;
    }

    // Mostrar diálogo de carga breve
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: AppSpacing.md),
                Text('Analizando ortografía y gramática...'),
              ],
            ),
          ),
        ),
      ),
    );

    final issues = await LanguageToolService.checkText(
      currentText,
      ignoredWords: ignoredWords,
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Cerrar diálogo de carga

    final correctedText = await showDialog<String>(
      context: context,
      builder: (ctx) => SpellCheckResultDialog(
        initialText: currentText,
        issues: issues,
      ),
    );

    if (!mounted || correctedText == null) return;
    if (correctedText != _contentController.text) {
      _contentController.text = correctedText;
      _onTextChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider(widget.projectId));
    final charactersAsync = ref.watch(charactersListProvider(widget.projectId));
    final relationshipsAsync = ref.watch(
      relationshipsStreamProvider(widget.projectId),
    );
    final bestiaryAsync = ref.watch(bestiaryProvider(widget.projectId));
    final glossaryAsync = ref.watch(glossaryProvider(widget.projectId));

    return chaptersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('No se pudieron cargar los capítulos: $error')),
      data: (chapters) {
        if (_selectedId == null && chapters.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _selectChapter(chapters.first);
          });
        }
        final chapter = _selectedChapter;

        final characters = charactersAsync.value ?? const <Character>[];
        final glossary = glossaryAsync.value ?? const <GlossaryTerm>[];
        final bestiary = bestiaryAsync.value ?? const <BestiaryEntry>[];

        final ignoredWords = <String>{
          for (final c in characters) ...c.searchableNames,
          for (final g in glossary) g.term,
          for (final b in bestiary) b.name,
        };

        final spellCheckService =
            TramaSpellCheckService(ignoredWords: ignoredWords);

        return Column(
          children: [
            _EditorToolbar(
              chapter: chapter,
              chaptersCount: chapters.length,
              wordCountNotifier: _wordCountNotifier,
              isSaving: _isSaving,
              onDeepSpellCheck: () => _runDeepSpellCheck(ignoredWords),
              onFocus: () => _contentFocus.requestFocus(),
              onSave: _saveNow,
            ),
            Expanded(
              child: chapters.isEmpty
                  ? _EmptyChapters(onCreate: () => _createChapter(chapters))
                  : Row(
                      children: [
                        _ChapterRail(
                          chapters: chapters,
                          selectedId: _selectedId,
                          totalWords: chapters.fold<int>(
                            0,
                            (sum, item) => sum + countWords(item.content),
                          ),
                          onSelect: _selectChapter,
                          onCreate: () => _createChapter(chapters),
                          onDelete: _deleteChapter,
                        ),
                        Expanded(
                          child: _ManuscriptEditor(
                            titleController: _titleController,
                            contentController: _contentController,
                            contentFocus: _contentFocus,
                            hasChapter: chapter != null,
                            spellCheckService: spellCheckService,
                            onChanged: _onTextChanged,
                          ),
                        ),
                        if (MediaQuery.of(context).size.width >= 1100)
                          ValueListenableBuilder<String>(
                            valueListenable: _analysisContentNotifier,
                            builder: (context, content, _) {
                              return _ChapterInspector(
                                content: content,
                                characters: characters,
                                relationships:
                                    relationshipsAsync.value ?? const [],
                                bestiary: bestiary,
                                glossary: glossary,
                              );
                            },
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  final Chapter? chapter;
  final int chaptersCount;
  final ValueNotifier<int> wordCountNotifier;
  final bool isSaving;
  final VoidCallback onDeepSpellCheck;
  final VoidCallback onFocus;
  final VoidCallback onSave;

  const _EditorToolbar({
    required this.chapter,
    required this.chaptersCount,
    required this.wordCountNotifier,
    required this.isSaving,
    required this.onDeepSpellCheck,
    required this.onFocus,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    decoration: const BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      border: Border(
        bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
      ),
    ),
    child: Row(
      children: [
        Text(
          '$chaptersCount capítulos',
          style: AppTypography.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ValueListenableBuilder<int>(
          valueListenable: wordCountNotifier,
          builder: (context, count, _) => Text(
            '$count palabras',
            style: AppTypography.labelMd.copyWith(fontFamily: 'monospace'),
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Revisión ortográfica y gramatical profunda',
          onPressed: onDeepSpellCheck,
          icon: const Icon(Icons.spellcheck, size: 20),
        ),
        const SizedBox(width: AppSpacing.xs),
        IconButton(
          tooltip: 'Enfocar editor',
          onPressed: onFocus,
          icon: const Icon(Icons.center_focus_strong_outlined, size: 19),
        ),
        const SizedBox(width: AppSpacing.xs),
        IconButton(
          tooltip: 'Guardar ahora',
          onPressed: onSave,
          icon: Icon(
            isSaving ? Icons.sync : Icons.cloud_done_outlined,
            size: 19,
          ),
        ),
      ],
    ),
  );
}

class _ChapterRail extends StatelessWidget {
  final List<Chapter> chapters;
  final String? selectedId;
  final int totalWords;
  final ValueChanged<Chapter> onSelect;
  final VoidCallback onCreate;
  final ValueChanged<Chapter> onDelete;

  const _ChapterRail({
    required this.chapters,
    required this.selectedId,
    required this.totalWords,
    required this.onSelect,
    required this.onCreate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 245,
    color: AppColors.surfaceContainerLowest,
    padding: const EdgeInsets.all(AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('ESTRUCTURA', style: AppTypography.labelXs),
            const Spacer(),
            IconButton(
              tooltip: 'Nuevo capítulo',
              onPressed: onCreate,
              icon: const Icon(Icons.add, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              final active = chapter.id == selectedId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Material(
                  color: active
                      ? AppColors.surfaceContainer
                      : Colors.transparent,
                  borderRadius: AppRadii.allSm,
                  child: InkWell(
                    borderRadius: AppRadii.allSm,
                    onTap: () => onSelect(chapter),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 9,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}'.padLeft(2, '0'),
                            style: AppTypography.labelXs,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chapter.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.uiBodySm.copyWith(
                                    fontWeight: active
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: active
                                        ? AppColors.onSurface
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${countWords(chapter.content)} palabras',
                                  style: AppTypography.labelXs,
                                ),
                              ],
                            ),
                          ),
                          if (active)
                            IconButton(
                              tooltip: 'Eliminar',
                              onPressed: () => onDelete(chapter),
                              icon: const Icon(Icons.more_horiz, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppRadii.allSm,
          ),
          child: Row(
            children: [
              Text('Total obra', style: AppTypography.labelXs),
              const Spacer(),
              Text(
                '$totalWords',
                style: AppTypography.labelMd.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ManuscriptEditor extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final FocusNode contentFocus;
  final bool hasChapter;
  final SpellCheckService spellCheckService;
  final VoidCallback onChanged;

  const _ManuscriptEditor({
    required this.titleController,
    required this.contentController,
    required this.contentFocus,
    required this.hasChapter,
    required this.spellCheckService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 790),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MANUSCRITO', style: AppTypography.labelXs),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: titleController,
                enabled: hasChapter,
                onChanged: (_) => onChanged(),
                style: AppTypography.headlineLg,
                decoration: const InputDecoration(
                  hintText: 'Título del capítulo',
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: contentController,
                focusNode: contentFocus,
                enabled: hasChapter,
                onChanged: (_) => onChanged(),
                inputFormatters: [
                  DialogueDashInputFormatter(),
                ],
                minLines: 24,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                spellCheckConfiguration: SpellCheckConfiguration(
                  spellCheckService: spellCheckService,
                  misspelledTextStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.error,
                    decorationStyle: TextDecorationStyle.wavy,
                    decorationThickness: 1.5,
                  ),
                ),
                style: AppTypography.manuscriptLg,
                cursorColor: AppColors.primaryContainer,
                decoration: const InputDecoration(
                  hintText: 'Empieza a escribir tu capítulo...',
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ChapterInspector extends StatelessWidget {
  final String content;
  final List<Character> characters;
  final List<CharacterRelationship> relationships;
  final List<BestiaryEntry> bestiary;
  final List<GlossaryTerm> glossary;

  const _ChapterInspector({
    required this.content,
    required this.characters,
    required this.relationships,
    required this.bestiary,
    required this.glossary,
  });

  @override
  Widget build(BuildContext context) {
    // Normalizar el texto completo una sola vez para que la búsqueda sea ultra rápida
    final normalizedContent = normalizeSearchText(content);

    final present = characters.where((character) {
      return character.searchableNames.any(
        (name) => fastContainsNormalized(normalizedContent, name),
      );
    }).toList();

    final presentIds = present.map((character) => character.id).toSet();
    final sceneRelations = relationships.where((relation) {
      return presentIds.contains(relation.sourceCharacterId) &&
          presentIds.contains(relation.targetCharacterId);
    }).toList();

    final presentBeasts = bestiary.where((entry) {
      return fastContainsNormalized(normalizedContent, entry.name);
    }).toList();

    final presentGlossary = glossary.where((entry) {
      return fastContainsNormalized(normalizedContent, entry.term);
    }).toList();

    final names = {
      for (final character in characters) character.id: character.fullName,
    };

    return Container(
      width: 255,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surfaceContainerLowest,
      child: ListView(
        children: [
          Text('INSPECTOR DE ESCENA', style: AppTypography.labelXs),
          const SizedBox(height: AppSpacing.lg),

          // 1. Personajes
          Text('PERSONAJES EN EL CAPÍTULO', style: AppTypography.labelXs),
          const SizedBox(height: AppSpacing.sm),
          if (present.isEmpty)
            Text(
              'Aún no se detectan personajes.',
              style: AppTypography.uiBodySm,
            )
          else
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: present
                  .map(
                    (character) => Chip(
                      label: Text(character.fullName),
                      avatar: CircleAvatar(child: Text(character.initial)),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Glosario
          Text('GLOSARIO EN EL CAPÍTULO', style: AppTypography.labelXs),
          const SizedBox(height: AppSpacing.sm),
          if (presentGlossary.isEmpty)
            Text(
              'Aún no se detectan términos del glosario.',
              style: AppTypography.uiBodySm,
            )
          else
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: presentGlossary
                  .map(
                    (item) => Tooltip(
                      message: item.definition.isNotEmpty
                          ? item.definition
                          : 'Sin definición registrada',
                      child: Chip(
                        label: Text(item.term),
                        avatar: const CircleAvatar(
                          child: Icon(Icons.menu_book_outlined, size: 13),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: AppSpacing.lg),

          // 3. Criaturas / Bestiario
          Text('CRIATURAS EN EL CAPÍTULO', style: AppTypography.labelXs),
          const SizedBox(height: AppSpacing.sm),
          if (presentBeasts.isEmpty)
            Text(
              'Aún no se detectan criaturas.',
              style: AppTypography.uiBodySm,
            )
          else
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: presentBeasts
                  .map(
                    (entry) => Chip(
                      label: Text(entry.name),
                      avatar: const CircleAvatar(
                        child: Icon(Icons.pets_outlined, size: 14),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: AppSpacing.lg),

          // 4. Relaciones
          Text('RELACIONES ACTIVAS', style: AppTypography.labelXs),
          const SizedBox(height: AppSpacing.sm),
          if (sceneRelations.isEmpty)
            Text(
              'Las relaciones aparecerán cuando coincidan dos personajes.',
              style: AppTypography.uiBodySm,
            )
          else
            ...sceneRelations.map(
              (relation) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  '${names[relation.sourceCharacterId]} · ${relation.relationType} · '
                  '${names[relation.targetCharacterId]}',
                  style: AppTypography.uiBodySm,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyChapters extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyChapters({required this.onCreate});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.auto_stories_outlined,
          size: 42,
          color: AppColors.primaryContainer,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Tu manuscrito empieza aquí', style: AppTypography.headlineMd),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Crea el primer capítulo y escribe sin distracciones.',
          style: AppTypography.uiBodySm,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo capítulo'),
        ),
      ],
    ),
  );
}

Future<String?> _chapterTitleDialog(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nuevo capítulo'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 120,
        decoration: const InputDecoration(
          labelText: 'Título',
          hintText: 'Capítulo primero',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: const Text('Crear'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
