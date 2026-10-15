import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/models/world_category.dart';
import '../../domain/models/world_entry.dart';
import '../../../characters/presentation/providers/character_providers.dart';
import '../../../characters/domain/models/character.dart';
import '../../../story_tools/domain/models/story_tool_models.dart';
import '../../../story_tools/presentation/providers/story_tools_providers.dart';
import '../providers/world_category_providers.dart';
import '../providers/world_entry_providers.dart';

class WorldEntryFormScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String? entryId;
  final String? initialCategoryId;

  const WorldEntryFormScreen({
    super.key,
    required this.projectId,
    this.entryId,
    this.initialCategoryId,
  });

  bool get isEditing => entryId != null;

  @override
  ConsumerState<WorldEntryFormScreen> createState() =>
      _WorldEntryFormScreenState();
}

class _WorldEntryFormScreenState extends ConsumerState<WorldEntryFormScreen> {
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedCategoryId;
  String? _errorMessage;
  bool _initialized = false;
  final Set<String> _selectedCharacterIds = {};
  final Set<String> _selectedBestiaryIds = {};
  final Set<String> _selectedRelatedEntryIds = {};

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    if (widget.entryId != null) {
      _loadCharacterLinks();
    }
  }

  Future<void> _loadCharacterLinks() async {
    final ids = await ref
        .read(worldEntryRepositoryProvider)
        .getCharacterIds(widget.entryId!);
    if (mounted) setState(() => _selectedCharacterIds.addAll(ids));
    final bestiaryIds = await ref
        .read(worldEntryRepositoryProvider)
        .getBestiaryIds(widget.entryId!);
    final relatedIds = await ref
        .read(worldEntryRepositoryProvider)
        .getRelatedEntryIds(widget.entryId!);
    if (mounted) {
      setState(() {
        _selectedBestiaryIds.addAll(bestiaryIds);
        _selectedRelatedEntryIds.addAll(relatedIds);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _prefill(WorldEntry entry) {
    if (_initialized) return;
    _initialized = true;
    _titleController.text = entry.title;
    _summaryController.text = entry.summary ?? '';
    _contentController.text = entry.content ?? '';
    _tagsController.text = entry.tags.join(', ');
    _selectedCategoryId = entry.categoryId;
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'El título es obligatorio.');
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _errorMessage = 'Selecciona una categoría.');
      return;
    }

    final controller = ref.read(worldEntriesControllerProvider.notifier);

    bool success;
    if (widget.isEditing) {
      final existing = await ref.read(
        worldEntryByIdProvider(widget.entryId!).future,
      );
      if (existing == null) {
        setState(() => _errorMessage = 'No se encontró la ficha.');
        return;
      }
      success = await controller.update(
        existing.copyWith(
          categoryId: _selectedCategoryId!,
          title: title,
          summary: _summaryController.text.trim(),
          content: _contentController.text.trim(),
          tags: _parseTags(),
        ),
      );
      if (success) {
        await ref
            .read(worldEntryRepositoryProvider)
            .setCharacterIds(widget.entryId!, _selectedCharacterIds.toList());
        await ref
            .read(worldEntryRepositoryProvider)
            .setBestiaryIds(widget.entryId!, _selectedBestiaryIds.toList());
        await ref
            .read(worldEntryRepositoryProvider)
            .setRelatedEntryIds(
              widget.entryId!,
              _selectedRelatedEntryIds.toList(),
            );
      }
    } else {
      success = await controller.create(
        projectId: widget.projectId,
        categoryId: _selectedCategoryId!,
        title: title,
        summary: _summaryController.text.trim(),
        content: _contentController.text.trim(),
        tags: _parseTags(),
      );
      if (success) {
        final created = await ref.read(
          worldEntriesByProjectProvider(widget.projectId).future,
        );
        final newEntry = created.firstWhere(
          (entry) =>
              entry.categoryId == _selectedCategoryId && entry.title == title,
        );
        await ref
            .read(worldEntryRepositoryProvider)
            .setCharacterIds(newEntry.id, _selectedCharacterIds.toList());
        await ref
            .read(worldEntryRepositoryProvider)
            .setBestiaryIds(newEntry.id, _selectedBestiaryIds.toList());
        await ref
            .read(worldEntryRepositoryProvider)
            .setRelatedEntryIds(newEntry.id, _selectedRelatedEntryIds.toList());
      }
    }

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      final state = ref.read(worldEntriesControllerProvider);
      state.whenOrNull(
        error: (e, _) => setState(() => _errorMessage = e.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    if (isEditing) {
      final async = ref.watch(worldEntryByIdProvider(widget.entryId!));
      async.whenData((e) {
        if (e != null) _prefill(e);
      });
    }

    final categoriesAsync = ref.watch(
      worldCategoriesListProvider(widget.projectId),
    );
    final charactersAsync = ref.watch(charactersListProvider(widget.projectId));
    final bestiaryAsync = ref.watch(bestiaryProvider(widget.projectId));
    final entriesAsync = ref.watch(
      worldEntriesByProjectProvider(widget.projectId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _TopBar(
            title: isEditing ? 'Editar ficha' : 'Nueva ficha',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return _NoCategories(onCreate: () => context.pop());
                }
                return charactersAsync.when(
                  data: (characters) => bestiaryAsync.when(
                    data: (bestiary) => entriesAsync.when(
                      data: (entries) =>
                          _buildForm(categories, characters, bestiary, entries),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Center(child: Text('Error al cargar fichas: $e')),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Error al cargar criaturas: $e')),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  error: (e, _) =>
                      Center(child: Text('Error al cargar personajes: $e')),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryContainer,
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          _BottomBar(
            isEditing: isEditing,
            onSubmit: _submit,
            onCancel: () => context.pop(),
            errorMessage: _errorMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    List<WorldCategory> categories,
    List<Character> characters,
    List<BestiaryEntry> bestiary,
    List<WorldEntry> entries,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Label('Categoría'),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.allMd,
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    hint: Text(
                      'Selecciona una categoría',
                      style: AppTypography.uiBodySm,
                    ),
                    style: AppTypography.uiBodyMd,
                    icon: const Icon(Icons.expand_more, size: 18),
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              _Label('Conexiones y recursos'),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Vincula criaturas y otras fichas sin crear copias.',
                style: AppTypography.uiBodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _LinkSelector(
                title: 'Criaturas relacionadas',
                icon: Icons.pets_outlined,
                items: bestiary.map((item) => (item.id, item.name)).toList(),
                selectedIds: _selectedBestiaryIds,
                onChanged: (id, selected) => setState(() {
                  selected
                      ? _selectedBestiaryIds.add(id)
                      : _selectedBestiaryIds.remove(id);
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              _LinkSelector(
                title: 'Fichas relacionadas',
                icon: Icons.hub_outlined,
                items: entries
                    .where((item) => item.id != widget.entryId)
                    .map((item) => (item.id, item.title))
                    .toList(),
                selectedIds: _selectedRelatedEntryIds,
                onChanged: (id, selected) => setState(() {
                  selected
                      ? _selectedRelatedEntryIds.add(id)
                      : _selectedRelatedEntryIds.remove(id);
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Label('Personajes vinculados'),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Añade personajes ya existentes que pertenezcan, sirvan o estén relacionados con esta ficha.',
                style: AppTypography.uiBodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (characters.isEmpty)
                const Text('Todavía no hay personajes creados.')
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: characters
                      .map(
                        (character) => FilterChip(
                          label: Text(character.fullName),
                          selected: _selectedCharacterIds.contains(
                            character.id,
                          ),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _selectedCharacterIds.add(character.id);
                            } else {
                              _selectedCharacterIds.remove(character.id);
                            }
                          }),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: AppSpacing.lg),

              _Label('Título'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _titleController,
                autofocus: true,
                style: AppTypography.uiBodyMd,
                decoration: const InputDecoration(
                  hintText: 'Nombre de la ficha',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              _Label('Resumen (opcional)'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _summaryController,
                maxLines: 2,
                style: AppTypography.uiBodyMd,
                decoration: const InputDecoration(
                  hintText: 'Una línea que resuma la ficha.',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              _Label('Contenido'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _contentController,
                maxLines: 12,
                style: AppTypography.manuscriptMd,
                decoration: const InputDecoration(
                  hintText: 'Desarrolla aquí todos los detalles.',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              _Label('Etiquetas (opcional)'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _tagsController,
                style: AppTypography.uiBodyMd,
                decoration: const InputDecoration(
                  hintText: 'Separa por comas: magia, ritual, prohibido',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// SUB-WIDGETS
// ============================================
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: AppTypography.headlineSm),
        ],
      ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  final bool isEditing;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final String? errorMessage;

  const _BottomBar({
    required this.isEditing,
    required this.onSubmit,
    required this.onCancel,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(worldEntriesControllerProvider).isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: AppRadii.allMd,
                  ),
                  child: Text(
                    errorMessage!,
                    style: AppTypography.uiBodySm.copyWith(
                      color: AppColors.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    label: 'Cancelar',
                    onPressed: isLoading ? null : onCancel,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    )
                  else
                    PrimaryButton(
                      label: isEditing ? 'Guardar' : 'Crear ficha',
                      icon: isEditing ? Icons.check : Icons.add,
                      onPressed: onSubmit,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.labelMd);
  }
}

class _LinkSelector extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<(String, String)> items;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onChanged;

  const _LinkSelector({
    required this.title,
    required this.icon,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text('$title: todavía no hay registros disponibles.');
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.allMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryContainer),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTypography.labelMd),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: items
                .map(
                  (item) => FilterChip(
                    label: Text(item.$2),
                    selected: selectedIds.contains(item.$1),
                    onSelected: (selected) => onChanged(item.$1, selected),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _NoCategories extends StatelessWidget {
  final VoidCallback onCreate;

  const _NoCategories({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Crea primero una categoría', style: AppTypography.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Necesitas al menos una categoría de mundo para '
              'poder guardar fichas en ella.',
              textAlign: TextAlign.center,
              style: AppTypography.uiBodySm,
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Volver',
              icon: Icons.arrow_back,
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}
