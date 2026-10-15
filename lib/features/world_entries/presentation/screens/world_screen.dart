import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../constants/world_colors.dart';
import '../../constants/world_icons.dart';
import '../../domain/models/world_category.dart';
import '../../domain/models/world_entry.dart';
import '../../../characters/domain/models/character.dart';
import '../../../characters/presentation/providers/character_providers.dart';
import '../../../story_tools/domain/models/story_tool_models.dart';
import '../../../story_tools/presentation/providers/story_tools_providers.dart';
import '../providers/world_category_providers.dart';
import '../providers/world_entry_providers.dart';
import '../widgets/world_category_sidebar.dart';
import '../widgets/world_entry_card.dart';

class WorldScreen extends ConsumerStatefulWidget {
  final String projectId;

  const WorldScreen({super.key, required this.projectId});

  @override
  ConsumerState<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends ConsumerState<WorldScreen> {
  String? _activeCategoryId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(
      worldCategoriesListProvider(widget.projectId),
    );

    return categoriesAsync.when(
      data: (categories) => _buildContent(categories),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(List<WorldCategory> categories) {
    // Si no hay categorías, mostramos el estado vacío
    if (categories.isEmpty) {
      return _EmptyWorldView(onCreateCategory: _openCategoryForm);
    }

    return Row(
      children: [
        WorldCategorySidebar(
          categories: categories,
          activeCategoryId: _activeCategoryId,
          onCategorySelected: (id) => setState(() => _activeCategoryId = id),
          onCreateCategory: _openCategoryForm,
          onEditCategory: (c) => _openCategoryForm(categoryId: c.id),
          onDeleteCategory: (c) => _confirmDeleteCategory(c),
        ),
        Expanded(
          child: _EntriesArea(
            projectId: widget.projectId,
            categoryId: _activeCategoryId,
            categories: categories,
            searchQuery: _searchQuery,
            onSearchChange: (v) => setState(() => _searchQuery = v),
            onNewEntry: _openEntryForm,
            onEditEntry: (id) => _openEntryForm(entryId: id),
          ),
        ),
      ],
    );
  }

  void _openCategoryForm({String? categoryId}) {
    if (categoryId == null) {
      context.push('/project/${widget.projectId}/world/categories/new');
    } else {
      context.push('/project/${widget.projectId}/world/categories/$categoryId');
    }
  }

  void _openEntryForm({String? entryId}) {
    if (entryId == null) {
      context.push(
        '/project/${widget.projectId}/world/entries/new',
        extra: _activeCategoryId,
      );
    } else {
      context.push('/project/${widget.projectId}/world/entries/$entryId');
    }
  }

  Future<void> _confirmDeleteCategory(WorldCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Eliminar "${category.name}"? Se eliminarán también '
          'todas las fichas que contiene (${category.entryCount}). '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(worldCategoriesControllerProvider.notifier)
          .delete(category.id, widget.projectId);

      // Si la categoría eliminada era la activa, volvemos a "Todas"
      if (_activeCategoryId == category.id) {
        setState(() => _activeCategoryId = null);
      }
    }
  }
}

// ============================================
// ESTADO VACÍO GENERAL
// ============================================
class _EmptyWorldView extends StatelessWidget {
  final VoidCallback onCreateCategory;

  const _EmptyWorldView({required this.onCreateCategory});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.allLg,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.public_outlined,
                  size: 28,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Construye tu mundo',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Crea categorías para organizar cualquier aspecto de tu '
                'universo: lugares, facciones, tecnología, magia, culturas, '
                'objetos... Tú decides qué necesita tu historia.',
                textAlign: TextAlign.center,
                style: AppTypography.manuscriptMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Crear primera categoría',
                icon: Icons.add,
                onPressed: onCreateCategory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// ÁREA DE FICHAS
// ============================================
class _EntriesArea extends ConsumerStatefulWidget {
  final String projectId;
  final String? categoryId;
  final List<WorldCategory> categories;
  final String searchQuery;
  final ValueChanged<String> onSearchChange;
  final VoidCallback onNewEntry;
  final void Function(String id) onEditEntry;

  const _EntriesArea({
    required this.projectId,
    required this.categoryId,
    required this.categories,
    required this.searchQuery,
    required this.onSearchChange,
    required this.onNewEntry,
    required this.onEditEntry,
  });

  @override
  ConsumerState<_EntriesArea> createState() => _EntriesAreaState();
}

class _EntriesAreaState extends ConsumerState<_EntriesArea> {
  String? _selectedEntryId;

  @override
  Widget build(BuildContext context) {
    // Cargamos por categoría o todas las del proyecto
    final entriesAsync = widget.categoryId != null
        ? ref.watch(worldEntriesByCategoryProvider(widget.categoryId!))
        : ref.watch(worldEntriesByProjectProvider(widget.projectId));

    // Color de la categoría activa (o gris si estamos en "Todas")
    final activeCategory = widget.categoryId != null
        ? widget.categories.firstWhere(
            (c) => c.id == widget.categoryId,
            orElse: () => widget.categories.first,
          )
        : null;
    final colorCode = activeCategory?.color ?? 'slate';

    return entriesAsync.when(
      data: (entries) {
        final filtered = widget.searchQuery.isEmpty
            ? entries
            : entries
                  .where(
                    (e) => '${e.title} ${e.summary ?? ''} ${e.tags.join(' ')}'
                        .toLowerCase()
                        .contains(widget.searchQuery.toLowerCase()),
                  )
                  .toList();
        final selected = filtered.cast<WorldEntry?>().firstWhere(
          (entry) => entry?.id == _selectedEntryId,
          orElse: () => null,
        );

        return Column(
          children: [
            _EntriesHeader(
              title: activeCategory?.name ?? 'Todas las fichas',
              count: filtered.length,
              iconCode: activeCategory?.icon ?? 'category',
              colorCode: colorCode,
              searchQuery: widget.searchQuery,
              onSearchChange: widget.onSearchChange,
              onNewEntry: widget.onNewEntry,
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyEntries(
                      categoryName: activeCategory?.name,
                      onNewEntry: widget.onNewEntry,
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final grid = _EntriesGrid(
                          projectId: widget.projectId,
                          entries: filtered,
                          colorCode: colorCode,
                          onSelect: (entry) =>
                              setState(() => _selectedEntryId = entry.id),
                          onEdit: widget.onEditEntry,
                        );
                        if (selected == null || constraints.maxWidth < 980) {
                          return Column(
                            children: [
                              Expanded(child: grid),
                              if (selected != null)
                                _WorldEntryInspector(
                                  projectId: widget.projectId,
                                  entry: selected,
                                  category: activeCategory,
                                  onEdit: () => widget.onEditEntry(selected.id),
                                  onClose: () =>
                                      setState(() => _selectedEntryId = null),
                                ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: grid),
                            SizedBox(
                              width: 360,
                              child: _WorldEntryInspector(
                                projectId: widget.projectId,
                                entry: selected,
                                category: activeCategory,
                                onEdit: () => widget.onEditEntry(selected.id),
                                onClose: () =>
                                    setState(() => _selectedEntryId = null),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _WorldEntryInspector extends ConsumerStatefulWidget {
  final String projectId;
  final WorldEntry entry;
  final WorldCategory? category;
  final VoidCallback onEdit;
  final VoidCallback onClose;

  const _WorldEntryInspector({
    required this.projectId,
    required this.entry,
    required this.category,
    required this.onEdit,
    required this.onClose,
  });

  @override
  ConsumerState<_WorldEntryInspector> createState() =>
      _WorldEntryInspectorState();
}

class _WorldEntryInspectorState extends ConsumerState<_WorldEntryInspector> {
  int _tab = 0;
  List<String> _characterIds = const [];

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final ids = await ref
        .read(worldEntryRepositoryProvider)
        .getCharacterIds(widget.entry.id);
    if (mounted) setState(() => _characterIds = ids);
  }

  @override
  Widget build(BuildContext context) {
    final characters = ref.watch(charactersListProvider(widget.projectId));
    final bestiary = ref.watch(bestiaryProvider(widget.projectId));
    final linkedCharacters =
        characters.valueOrNull
            ?.where((character) => _characterIds.contains(character.id))
            .toList() ??
        const <Character>[];
    final relatedCreatures =
        bestiary.valueOrNull
            ?.where(
              (entry) => _containsLoreReference(entry, widget.entry.title),
            )
            .toList() ??
        const <BestiaryEntry>[];

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: WorldColors.getColor(
                    widget.category?.color ?? 'slate',
                  ),
                  child: Icon(
                    WorldIcons.getIcon(widget.category?.icon ?? 'category'),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.entry.title,
                    style: AppTypography.headlineMd,
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  tooltip: 'Cerrar inspector',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _InspectorBadge(
                  icon: Icons.category_outlined,
                  label: widget.category?.name ?? 'Worldbuilding',
                ),
                _InspectorBadge(
                  icon: Icons.public_outlined,
                  label: widget.entry.tags.isEmpty
                      ? 'Ficha de lore'
                      : widget.entry.tags.first,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.entry.summary?.isNotEmpty == true ? widget.entry.summary! : 'Sin resumen. Añade una descripción para definir su función en el mundo.',
              style: AppTypography.manuscriptMd,
            ),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Ficha')),
                ButtonSegment(value: 1, label: Text('Integrantes')),
                ButtonSegment(value: 2, label: Text('Conexiones')),
              ],
              selected: {_tab},
              onSelectionChanged: (value) => setState(() => _tab = value.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_tab == 0)
              _InspectorSection(
                title: 'Contexto de la ficha',
                icon: Icons.auto_stories_outlined,
                child: Text(
                  widget.entry.content?.isNotEmpty == true
                      ? widget.entry.content!
                      : 'Esta ficha todavía no tiene contenido desarrollado.',
                  style: AppTypography.uiBodyMd,
                ),
              )
            else if (_tab == 1)
              _InspectorSection(
                title: 'Personajes vinculados',
                icon: Icons.people_outline,
                action: TextButton.icon(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Asignar personaje'),
                ),
                child: linkedCharacters.isEmpty
                    ? const Text('Aún no hay integrantes asignados.')
                    : Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: linkedCharacters
                            .map(
                              (character) => Chip(
                                avatar: CircleAvatar(
                                  child: Text(character.initial),
                                ),
                                label: Text(character.fullName),
                              ),
                            )
                            .toList(),
                      ),
              )
            else
              _InspectorSection(
                title: 'Recursos y conexiones',
                icon: Icons.hub_outlined,
                action: TextButton.icon(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.link),
                  label: const Text('Vincular recursos'),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Criaturas relacionadas',
                      style: AppTypography.labelMd,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (relatedCreatures.isEmpty)
                      const Text('No hay criaturas mencionadas en esta ficha.')
                    else
                      ...relatedCreatures.map(
                        (creature) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.pets_outlined),
                          title: Text(creature.name),
                          subtitle: Text(creature.category ?? 'Criatura'),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Territorios, diplomacia y divisiones internas pueden documentarse con tags y fichas enlazadas.',
                      style: AppTypography.uiBodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar ficha y conexiones'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _containsLoreReference(BestiaryEntry entry, String title) {
    final needle = normalizeSearchText(title);
    final haystack = normalizeSearchText(
      '${entry.name} ${entry.storyContext ?? ''} ${entry.habitat ?? ''}',
    );
    return needle.isNotEmpty && haystack.contains(needle);
  }
}

class _InspectorSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? action;

  const _InspectorSection({
    required this.title,
    required this.icon,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.md),
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
            Expanded(child: Text(title, style: AppTypography.labelMd)),
            ?action,
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    ),
  );
}

class _InspectorBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InspectorBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 16),
    label: Text(label),
    visualDensity: VisualDensity.compact,
  );
}

class _EntriesHeader extends StatelessWidget {
  final String title;
  final int count;
  final String iconCode;
  final String colorCode;
  final String searchQuery;
  final ValueChanged<String> onSearchChange;
  final VoidCallback onNewEntry;

  const _EntriesHeader({
    required this.title,
    required this.count,
    required this.iconCode,
    required this.colorCode,
    required this.searchQuery,
    required this.onSearchChange,
    required this.onNewEntry,
  });

  @override
  Widget build(BuildContext context) {
    final accent = WorldColors.getColor(colorCode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppRadii.allMd,
            ),
            alignment: Alignment.center,
            child: Icon(WorldIcons.getIcon(iconCode), size: 18, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTypography.headlineSm),
              Text(
                count == 1 ? '1 ficha' : '$count fichas',
                style: AppTypography.labelXs,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextField(
                onChanged: onSearchChange,
                style: AppTypography.uiBodySm,
                decoration: const InputDecoration(
                  hintText: 'Buscar por título...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Material(
            color: AppColors.primaryContainer,
            borderRadius: AppRadii.allMd,
            child: InkWell(
              onTap: onNewEntry,
              borderRadius: AppRadii.allMd,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 18, color: AppColors.onPrimary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Nueva ficha',
                      style: AppTypography.uiBodySm.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyEntries extends StatelessWidget {
  final String? categoryName;
  final VoidCallback onNewEntry;

  const _EmptyEntries({this.categoryName, required this.onNewEntry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                categoryName != null
                    ? 'Aún no hay fichas en "$categoryName"'
                    : 'Aún no hay fichas',
                textAlign: TextAlign.center,
                style: AppTypography.headlineSm,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Crea la primera ficha para empezar a documentar tu mundo.',
                textAlign: TextAlign.center,
                style: AppTypography.uiBodySm,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Crear ficha',
                icon: Icons.add,
                onPressed: onNewEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntriesGrid extends ConsumerWidget {
  final String projectId;
  final List entries;
  final String colorCode;
  final void Function(String id) onEdit;
  final ValueChanged<WorldEntry> onSelect;

  const _EntriesGrid({
    required this.projectId,
    required this.entries,
    required this.colorCode,
    required this.onEdit,
    required this.onSelect,
  });

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    dynamic entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar ficha'),
        content: Text(
          '¿Eliminar "${entry.title}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(worldEntriesControllerProvider.notifier)
          .delete(entry.id, entry.categoryId, projectId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 700
                  ? 1
                  : constraints.maxWidth < 1100
                  ? 2
                  : 3;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.5,
                ),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return WorldEntryCard(
                    entry: entry,
                    categoryColorCode: colorCode,
                    onTap: () => onSelect(entry),
                    onDelete: () => _confirmDelete(context, ref, entry),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
