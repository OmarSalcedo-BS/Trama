import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
  Timer? _saveTimer;
  bool _isSaving = false;
  bool _isDirty = false;
  String _search = '';

  @override
  void dispose() {
    _saveTimer?.cancel();
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
  }

  void _onTextChanged() {
    if (_selectedChapter == null) return;
    setState(() => _isDirty = true);
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

  void _onSearchChanged(String value) {
    setState(() => _search = value);
    final query = value.trim();
    if (query.isEmpty) return;
    final match = RegExp(
      r'(?<![\p{L}\p{N}])' +
          RegExp.escape(normalizeSearchText(query)) +
          r'(?![\p{L}\p{N}])',
      caseSensitive: false,
      unicode: true,
    ).firstMatch(normalizeSearchText(_contentController.text));
    if (match != null) {
      _contentController.selection = TextSelection(
        baseOffset: match.start,
        extentOffset: match.end,
      );
    }
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
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider(widget.projectId));
    final charactersAsync = ref.watch(charactersListProvider(widget.projectId));
    final relationshipsAsync = ref.watch(
      relationshipsStreamProvider(widget.projectId),
    );
    final bestiaryAsync = ref.watch(bestiaryProvider(widget.projectId));

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
        return Column(
          children: [
            _EditorToolbar(
              chapter: chapter,
              chaptersCount: chapters.length,
              wordCount: _wordCount(_contentController.text),
              matchCount: _countMatches(_contentController.text, _search),
              isSaving: _isSaving,
              search: _search,
              onSearchChanged: _onSearchChanged,
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
                            (sum, item) => sum + _wordCount(item.content),
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
                            search: _search,
                            onChanged: _onTextChanged,
                          ),
                        ),
                        if (MediaQuery.of(context).size.width >= 1100)
                          _ChapterInspector(
                            content: _contentController.text,
                            characters: charactersAsync.value ?? const [],
                            relationships: relationshipsAsync.value ?? const [],
                            bestiary: bestiaryAsync.value ?? const [],
                            search: _search,
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
  final int wordCount;
  final int matchCount;
  final bool isSaving;
  final String search;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFocus;
  final VoidCallback onSave;

  const _EditorToolbar({
    required this.chapter,
    required this.chaptersCount,
    required this.wordCount,
    required this.matchCount,
    required this.isSaving,
    required this.search,
    required this.onSearchChanged,
    required this.onFocus,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 58,
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
        Text(
          '$wordCount palabras',
          style: AppTypography.labelMd.copyWith(fontFamily: 'monospace'),
        ),
        if (search.trim().isNotEmpty) ...[
          const SizedBox(width: AppSpacing.md),
          Text(
            '$matchCount coincidencias',
            style: AppTypography.labelMd.copyWith(
              color: matchCount == 0
                  ? AppColors.error
                  : AppColors.primaryContainer,
            ),
          ),
        ],
        const Spacer(),
        _SearchField(value: search, onChanged: onSearchChanged),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          tooltip: 'Enfocar editor',
          onPressed: onFocus,
          icon: const Icon(Icons.center_focus_strong_outlined, size: 19),
        ),
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
                                  '${_wordCount(chapter.content)} palabras',
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
  final String search;
  final VoidCallback onChanged;

  const _ManuscriptEditor({
    required this.titleController,
    required this.contentController,
    required this.contentFocus,
    required this.hasChapter,
    required this.search,
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
                minLines: 22,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                spellCheckConfiguration: const SpellCheckConfiguration(),
                style: AppTypography.manuscriptLg,
                decoration: InputDecoration(
                  hintText: 'Empieza a escribir tu capítulo...',
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  suffixText: search.isEmpty ? null : 'Buscar: $search',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.value, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    child: TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        hintText: 'Buscar en el capítulo',
        prefixIcon: Icon(Icons.search, size: 17),
        isDense: true,
      ),
    ),
  );
}

class _ChapterInspector extends StatelessWidget {
  final String content;
  final List<Character> characters;
  final List<CharacterRelationship> relationships;
  final List<BestiaryEntry> bestiary;
  final String search;

  const _ChapterInspector({
    required this.content,
    required this.characters,
    required this.relationships,
    required this.bestiary,
    required this.search,
  });

  @override
  Widget build(BuildContext context) {
    final present = characters.where((character) {
      return character.searchableNames.any(
        (name) => containsSearchWord(content, name),
      );
    }).toList();
    final presentIds = present.map((character) => character.id).toSet();
    final sceneRelations = relationships.where((relation) {
      return presentIds.contains(relation.sourceCharacterId) &&
          presentIds.contains(relation.targetCharacterId);
    }).toList();
    final presentBeasts = bestiary.where((entry) {
      return containsSearchWord(content, entry.name);
    }).toList();
    final matchCount = _countMatches(content, search);
    final names = {
      for (final character in characters) character.id: character.fullName,
    };

    return Container(
      width: 255,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INSPECTOR DE ESCENA', style: AppTypography.labelXs),
          if (search.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              matchCount == 0
                  ? 'SIN COINCIDENCIAS'
                  : '$matchCount COINCIDENCIAS',
              style: AppTypography.labelXs.copyWith(
                color: matchCount == 0
                    ? AppColors.error
                    : AppColors.primaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              matchCount == 0
                  ? 'No se encontró esa palabra en el capítulo.'
                  : 'La búsqueda está activa en el manuscrito.',
              style: AppTypography.uiBodySm,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
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

int _wordCount(String text) {
  return RegExp(
    r"\b[\wÀ-ÿ]+(?:['’-][\wÀ-ÿ]+)*\b",
    unicode: true,
  ).allMatches(text).length;
}

int _countMatches(String content, String query) {
  final cleanQuery = normalizeSearchText(query);
  if (cleanQuery.isEmpty) return 0;
  return RegExp(
    r'(?<![\p{L}\p{N}])' + RegExp.escape(cleanQuery) + r'(?![\p{L}\p{N}])',
    caseSensitive: false,
    unicode: true,
  ).allMatches(normalizeSearchText(content)).length;
}
