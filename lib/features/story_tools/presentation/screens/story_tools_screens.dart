import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../characters/domain/models/character.dart';
import '../../../characters/presentation/providers/character_providers.dart';
import '../../domain/models/story_tool_models.dart';
import '../providers/story_tools_providers.dart';

class DraftNotesScreen extends ConsumerWidget {
  final String projectId;
  const DraftNotesScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ToolList<DraftNote>(
      title: 'Notas de borrador',
      subtitle: 'Ideas y escenas que todavía están tomando forma.',
      icon: Icons.edit_note_outlined,
      items: ref.watch(notesProvider(projectId)),
      label: (note) => note.title,
      detail: (note) => note.content,
      onAdd: () async {
        final value = await _textDialog(context, 'Nueva nota', true);
        if (value == null) return;
        final ok = await ref
            .read(storyToolsControllerProvider.notifier)
            .run(
              () async => ref
                  .read(storyToolsRepositoryProvider)
                  .createNote(projectId, value.$1, value.$2),
            );
        if (ok) ref.invalidate(notesProvider(projectId));
      },
      onDelete: (note) async {
        await ref
            .read(storyToolsControllerProvider.notifier)
            .run(
              () => ref.read(storyToolsRepositoryProvider).deleteNote(note.id),
            );
        ref.invalidate(notesProvider(projectId));
      },
    );
  }
}

class GlossaryScreen extends ConsumerWidget {
  final String projectId;
  const GlossaryScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GlossaryEditorialScreen(projectId: projectId);
  }
}

class _GlossaryEditorialScreen extends ConsumerStatefulWidget {
  final String projectId;
  const _GlossaryEditorialScreen({required this.projectId});

  @override
  ConsumerState<_GlossaryEditorialScreen> createState() =>
      _GlossaryEditorialScreenState();
}

class _GlossaryEditorialScreenState
    extends ConsumerState<_GlossaryEditorialScreen> {
  String _query = '';
  String _category = 'Todas';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(glossaryProvider(widget.projectId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Error al cargar el diccionario: $error')),
      data: (terms) {
        final categories = {
          'Todas',
          ...terms
              .map((term) => term.category?.trim())
              .whereType<String>()
              .where((value) => value.isNotEmpty),
        }.toList();
        final query = normalizeSearchText(_query);
        final filtered = terms.where((term) {
          final haystack = normalizeSearchText(
            '${term.term} ${term.definition} ${term.category ?? ''}',
          );
          return (_category == 'Todas' || term.category == _category) &&
              (query.isEmpty || haystack.contains(query));
        }).toList();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ToolHeader(
                title: 'Diccionario del universo',
                subtitle:
                    'Una enciclopedia viva de términos, nombres y conceptos.',
                icon: Icons.menu_book_outlined,
                onAdd: () => _addTerm(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar término, definición o categoría',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: categories
                    .map(
                      (value) => ChoiceChip(
                        label: Text(value),
                        selected: _category == value,
                        onSelected: (_) => setState(() => _category = value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (filtered.isEmpty)
                const _EmptyTool(
                  text: 'No hay términos que coincidan con la búsqueda.',
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1100
                        ? 3
                        : constraints.maxWidth >= 650
                        ? 2
                        : 1;
                    final gap = AppSpacing.md;
                    final width =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: filtered
                          .map(
                            (term) => SizedBox(
                              width: width,
                              child: _GlossaryCard(
                                term: term,
                                onDelete: () => _deleteTerm(term),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addTerm(BuildContext context) async {
    final categories =
        (await ref.read(glossaryProvider(widget.projectId).future))
            .map((term) => term.category?.trim())
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList();
    if (!context.mounted) return;
    final value = await _glossaryDialog(context, categories: categories);
    if (value == null) return;
    final ok = await ref
        .read(storyToolsControllerProvider.notifier)
        .run(
          () => ref
              .read(storyToolsRepositoryProvider)
              .createTerm(widget.projectId, value.$1, value.$2, value.$3),
        );
    if (ok) ref.invalidate(glossaryProvider(widget.projectId));
  }

  Future<void> _deleteTerm(GlossaryTerm term) async {
    await ref
        .read(storyToolsControllerProvider.notifier)
        .run(() => ref.read(storyToolsRepositoryProvider).deleteTerm(term.id));
    ref.invalidate(glossaryProvider(widget.projectId));
  }
}

class _GlossaryCard extends StatelessWidget {
  final GlossaryTerm term;
  final VoidCallback onDelete;
  const _GlossaryCard({required this.term, required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(term.term, style: AppTypography.headlineMd),
          content: Text(term.definition, style: AppTypography.manuscriptMd),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(term.term, style: AppTypography.headlineMd),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar término',
                ),
              ],
            ),
            if (term.category?.isNotEmpty == true)
              _MetaPill(icon: Icons.label_outline, text: term.category!),
            const SizedBox(height: AppSpacing.md),
            Text(
              term.definition,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.manuscriptMd,
            ),
          ],
        ),
      ),
    ),
  );
}

class TimelineScreen extends ConsumerWidget {
  final String projectId;
  const TimelineScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(timelineProvider(projectId));
    return events.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Error al cargar cronología: $error')),
      data: (items) => Column(
        children: [
          Expanded(
            child: _InteractiveTimelineChart(
              events: items,
              onAdd: () => _addTimelineEvent(context, ref),
            ),
          ),
          SizedBox(
            height: 245,
            child: _ToolList<TimelineEvent>(
              title: 'Eventos de la cronología',
              subtitle: 'Edita o elimina los acontecimientos guardados.',
              icon: Icons.event_note_outlined,
              items: AsyncValue.data(items),
              label: (event) => event.title,
              detail: (event) => event.description ?? 'Sin descripción',
              metadata: (event) => _date(event.eventDate),
              onAdd: () => _addTimelineEvent(context, ref),
              onDelete: (event) async {
                await ref
                    .read(storyToolsControllerProvider.notifier)
                    .run(
                      () => ref
                          .read(storyToolsRepositoryProvider)
                          .deleteEvent(event.id),
                    );
                ref.invalidate(timelineProvider(projectId));
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTimelineEvent(BuildContext context, WidgetRef ref) async {
    final value = await _timelineDialog(context);
    if (value == null) return;
    final ok = await ref
        .read(storyToolsControllerProvider.notifier)
        .run(
          () => ref
              .read(storyToolsRepositoryProvider)
              .createEvent(projectId, value.$1, value.$2, value.$3),
        );
    if (ok) ref.invalidate(timelineProvider(projectId));
  }
}

class BestiaryScreen extends ConsumerStatefulWidget {
  final String projectId;
  const BestiaryScreen({super.key, required this.projectId});

  @override
  ConsumerState<BestiaryScreen> createState() => _BestiaryScreenState();
}

class _BestiaryScreenState extends ConsumerState<BestiaryScreen> {
  String _query = '';
  String _species = 'Todas las especies';
  String _danger = 'Todos los niveles';

  List<BestiaryEntry> _filterEntries(List<BestiaryEntry> entries) {
    final query = normalizeSearchText(_query);
    return entries.where((entry) {
      final haystack = normalizeSearchText(
        '${entry.name} ${entry.category ?? ''} ${entry.abilities ?? ''}',
      );
      final matchesQuery = query.isEmpty || haystack.contains(query);
      final category = normalizeSearchText(entry.category ?? '');
      final matchesSpecies =
          _species == 'Todas las especies' ||
          category.contains(normalizeSearchText(_species));
      final entryDanger = normalizeSearchText(entry.dangerLevel ?? '');
      final matchesDanger =
          _danger == 'Todos los niveles' ||
          entryDanger.contains(normalizeSearchText(_danger));
      return matchesQuery && matchesSpecies && matchesDanger;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(bestiaryProvider(widget.projectId));
    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Error al cargar el bestiario: $error')),
      data: (entries) {
        final speciesOptions = {
          'Todas las especies',
          ...entries
              .map((entry) => entry.category?.trim())
              .whereType<String>()
              .where((value) => value.isNotEmpty),
        }.toList();
        final filtered = _filterEntries(entries);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BestiaryHeader(
                query: _query,
                species: _species,
                speciesOptions: speciesOptions,
                danger: _danger,
                count: entries.length,
                onQueryChanged: (value) => setState(() => _query = value),
                onSpeciesChanged: (value) => setState(() => _species = value),
                onDangerChanged: (value) => setState(() => _danger = value),
                onAdd: () => _createEntry(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (filtered.isEmpty)
                const _EmptyTool(
                  text: 'No hay criaturas que coincidan con los filtros actuales.',
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1300
                        ? 4
                        : constraints.maxWidth >= 850
                        ? 3
                        : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                    final spacing = AppSpacing.md;
                    final width =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final entry in filtered)
                          SizedBox(
                            width: width,
                            child: _BestiaryCard(
                              entry: entry,
                              onOpen: () => _openDetails(entry),
                              onEdit: () => _editEntry(entry),
                              onDuplicate: () =>
                                  _duplicateEntry(entry, entries),
                              onDelete: () => _deleteEntry(entry),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createEntry(BuildContext context) async {
    final entries = await ref.read(bestiaryProvider(widget.projectId).future);
    if (!context.mounted) return;
    final categories = entries
        .map((entry) => entry.category?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    final value = await _bestiaryDialog(context, categories: categories);
    if (value == null) return;
    final ok = await ref
        .read(storyToolsControllerProvider.notifier)
        .run(
          () => ref
              .read(storyToolsRepositoryProvider)
              .createBestiaryEntry(
                projectId: widget.projectId,
                name: value.$1,
                category: value.$2,
                mythology: value.$3,
                description: value.$4,
                weaknesses: value.$5,
                abilities: value.$6,
                habitat: value.$7,
                dangerLevel: value.$8,
                historicalReferences: value.$9,
                diet: value.$10,
                storyContext: value.$11,
              ),
        );
    if (ok) ref.invalidate(bestiaryProvider(widget.projectId));
  }

  Future<void> _deleteEntry(BestiaryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar criatura'),
        content: Text('¿Eliminar "${entry.name}" del compendio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(storyToolsControllerProvider.notifier)
        .run(
          () => ref
              .read(storyToolsRepositoryProvider)
              .deleteBestiaryEntry(entry.id),
        );
    ref.invalidate(bestiaryProvider(widget.projectId));
  }

  Future<void> _editEntry(BestiaryEntry entry) async {
    final entries = await ref.read(bestiaryProvider(widget.projectId).future);
    if (!mounted) return;
    final categories = entries
        .map((item) => item.category?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    final value = await _bestiaryDialog(
      context,
      initial: entry,
      categories: categories,
    );
    if (value == null) return;
    final ok = await ref
        .read(storyToolsControllerProvider.notifier)
        .run(
          () => ref
              .read(storyToolsRepositoryProvider)
              .updateBestiaryEntry(
                id: entry.id,
                name: value.$1,
                category: value.$2,
                mythology: value.$3,
                description: value.$4,
                weaknesses: value.$5,
                abilities: value.$6,
                habitat: value.$7,
                dangerLevel: value.$8,
                historicalReferences: value.$9,
                diet: value.$10,
                storyContext: value.$11,
              ),
        );
    if (ok) ref.invalidate(bestiaryProvider(widget.projectId));
  }

  Future<void> _duplicateEntry(
    BestiaryEntry entry,
    List<BestiaryEntry> entries,
  ) async {
    final baseName = '${entry.name} (copia)';
    var name = baseName;
    var suffix = 2;
    final existingNames = entries
        .map((item) => normalizeSearchText(item.name))
        .toSet();
    while (existingNames.contains(normalizeSearchText(name))) {
      name = '${entry.name} (copia $suffix)';
      suffix++;
    }
    final copy = await _bestiaryDialog(
      context,
      initial: entry,
      initialName: name,
      title: 'Duplicar criatura',
      categories: entries
          .map((item) => item.category?.trim())
          .whereType<String>()
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(),
    );
    if (copy == null) return;
    final ok = await ref
        .read(storyToolsControllerProvider.notifier)
        .run(
          () => ref
              .read(storyToolsRepositoryProvider)
              .createBestiaryEntry(
                projectId: widget.projectId,
                name: copy.$1,
                category: copy.$2,
                mythology: copy.$3,
                description: copy.$4,
                weaknesses: copy.$5,
                abilities: copy.$6,
                habitat: copy.$7,
                dangerLevel: copy.$8,
                historicalReferences: copy.$9,
                diet: copy.$10,
                storyContext: copy.$11,
              ),
        );
    if (ok) ref.invalidate(bestiaryProvider(widget.projectId));
  }

  void _openDetails(BestiaryEntry entry) {
    showDialog<void>(
      context: context,
      builder: (_) => _BestiaryDetailsDialog(entry: entry),
    );
  }
}

class _BestiaryHeader extends StatelessWidget {
  final String query;
  final String species;
  final List<String> speciesOptions;
  final String danger;
  final int count;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSpeciesChanged;
  final ValueChanged<String> onDangerChanged;
  final VoidCallback onAdd;

  const _BestiaryHeader({
    required this.query,
    required this.species,
    required this.speciesOptions,
    required this.danger,
    required this.count,
    required this.onQueryChanged,
    required this.onSpeciesChanged,
    required this.onDangerChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            color: AppColors.primaryContainer,
            size: 34,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bestiario Canónico', style: AppTypography.headlineXl),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Registro anatómico, hábitat y amenaza de las especies del universo.',
                  style: AppTypography.uiBodySm,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$count criaturas registradas',
                  style: AppTypography.labelXs,
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Registrar criatura'),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              onChanged: onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'Buscar criatura o habilidad',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          for (final option in speciesOptions)
            ChoiceChip(
              label: Text(option),
              selected: species == option,
              onSelected: (_) => onSpeciesChanged(option),
            ),
          DropdownButton<String>(
            value: danger,
            items:
                const [
                      'Todos los niveles',
                      'Bajo',
                      'Moderado',
                      'Crítico',
                      'Extremo',
                    ]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onDangerChanged(value);
            },
          ),
        ],
      ),
    ],
  );
}

class _BestiaryCard extends StatelessWidget {
  final BestiaryEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _BestiaryCard({
    required this.entry,
    required this.onOpen,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final abilities = (entry.abilities ?? '')
        .split(RegExp(r'[,;\n]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .take(3)
        .toList();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: AppColors.surfaceContainerLow,
              child: CustomPaint(
                painter: _BestiaryPlatePainter(),
                child: Center(
                  child: Icon(
                    Icons.pets_outlined,
                    size: 58,
                    color: AppColors.primaryContainer.withValues(alpha: .7),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.name,
                          style: AppTypography.headlineMd,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (action) {
                          if (action == 'edit') onEdit();
                          if (action == 'duplicate') onDuplicate();
                          if (action == 'delete') onDelete();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar ficha'),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Text('Duplicar ficha'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar ficha'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    (entry.category ?? 'Especie sin clasificar').toUpperCase(),
                    style: AppTypography.labelXs.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DangerBadge(level: entry.dangerLevel),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (entry.habitat != null)
                        _MetaPill(
                          icon: Icons.park_outlined,
                          text: entry.habitat!,
                        ),
                      for (final ability in abilities)
                        _MetaPill(icon: Icons.auto_awesome, text: ability),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    entry.description,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.uiBodySm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BestiaryPlatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: .35)
      ..strokeWidth = 1;
    for (var x = 12.0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height), paint);
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * .55,
        height: size.height * .72,
      ),
      paint..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _BestiaryPlatePainter oldDelegate) => false;
}

class _DangerBadge extends StatelessWidget {
  final String? level;
  const _DangerBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final value = level?.trim().isNotEmpty == true ? level! : 'No clasificado';
    final normalized = normalizeSearchText(value);
    final color = normalized.contains('critic') || normalized.contains('extrem')
        ? AppColors.error
        : normalized.contains('moder')
        ? Colors.orange.shade700
        : AppColors.primaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: AppRadii.allPill,
      ),
      child: Text(
        'Peligro: $value',
        style: AppTypography.labelXs.copyWith(color: color),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 14),
    label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
  );
}

class _BestiaryDetailsDialog extends StatelessWidget {
  final BestiaryEntry entry;
  const _BestiaryDetailsDialog({required this.entry});

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(entry.name, style: AppTypography.headlineXl),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              (entry.category ?? 'Especie sin clasificar').toUpperCase(),
              style: AppTypography.labelXs,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 290,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: AppRadii.allMd,
                    ),
                    child: CustomPaint(
                      painter: _BestiaryPlatePainter(),
                      child: const Center(
                        child: Icon(Icons.pets_outlined, size: 100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DangerBadge(level: entry.dangerLevel),
                      const SizedBox(height: AppSpacing.md),
                      _DetailBlock(
                        title: 'Anatomía y extracto',
                        value: entry.description,
                      ),
                      _DetailBlock(title: 'Mitología', value: entry.mythology),
                      _DetailBlock(
                        title: 'Hábitat y alimentación',
                        value: [
                          entry.habitat,
                          entry.diet,
                        ].whereType<String>().join(' · '),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xxl),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.lg,
              children: [
                _DetailBlock(title: 'Habilidades', value: entry.abilities),
                _DetailBlock(title: 'Puntos débiles', value: entry.weaknesses),
                _DetailBlock(
                  title: 'Referencias históricas',
                  value: entry.historicalReferences,
                ),
                _DetailBlock(
                  title: 'Contexto actual',
                  value: entry.storyContext,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailBlock extends StatelessWidget {
  final String title;
  final String? value;
  const _DetailBlock({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: AppTypography.labelXs),
            const SizedBox(height: AppSpacing.xs),
            Text(value!, style: AppTypography.uiBodySm),
          ],
        ),
      ),
    );
  }
}

class _InteractiveTimelineChart extends StatefulWidget {
  final List<TimelineEvent> events;
  final VoidCallback onAdd;

  const _InteractiveTimelineChart({required this.events, required this.onAdd});

  @override
  State<_InteractiveTimelineChart> createState() =>
      _InteractiveTimelineChartState();
}

class _InteractiveTimelineChartState extends State<_InteractiveTimelineChart> {
  late final TransformationController _transformController;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _scale(double amount) {
    final current = _transformController.value.getMaxScaleOnAxis();
    final next = (current * amount).clamp(.55, 2.8);
    final scale = next / current;
    _transformController.value = _transformController.value.multiplied(
      Matrix4.diagonal3Values(scale, scale, 1),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: AppRadii.allLg,
      border: Border.all(color: AppColors.outlineVariant),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                _scale(event.scrollDelta.dy < 0 ? 1.1 : .9);
              }
            },
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: .55,
              maxScale: 2.8,
              boundaryMargin: const EdgeInsets.all(240),
              constrained: false,
              panEnabled: true,
              scaleEnabled: true,
              child: SizedBox(
                width: math.max(900, widget.events.length * 190.0),
                height: 420,
                child: CustomPaint(painter: _TimelinePainter(widget.events)),
              ),
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          child: _TimelineHeader(
            count: widget.events.length,
            onAdd: widget.onAdd,
          ),
        ),
        Positioned(
          bottom: AppSpacing.md,
          left: AppSpacing.md,
          child: Card(
            margin: EdgeInsets.zero,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _scale(.85),
                  icon: const Icon(Icons.remove),
                  tooltip: 'Reducir zoom',
                ),
                IconButton(
                  onPressed: () => _scale(1.18),
                  icon: const Icon(Icons.add),
                  tooltip: 'Ampliar zoom',
                ),
                IconButton(
                  onPressed: () => setState(
                    () => _transformController.value = Matrix4.identity(),
                  ),
                  icon: const Icon(Icons.fit_screen_outlined),
                  tooltip: 'Reencuadrar',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text('Arrastra para explorar · rueda para zoom'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _TimelineHeader extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;

  const _TimelineHeader({required this.count, required this.onAdd});

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.timeline_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cronología', style: AppTypography.headlineMd),
              Text(
                '$count ${count == 1 ? 'evento' : 'eventos'}',
                style: AppTypography.labelXs,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          IconButton.filled(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo evento',
          ),
        ],
      ),
    ),
  );
}

class _TimelinePainter extends CustomPainter {
  final List<TimelineEvent> events;
  _TimelinePainter(this.events);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primaryContainer
      ..strokeWidth = 2;
    final nodePaint = Paint()..color = AppColors.primary;
    final sorted = [...events]
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    final step = sorted.length == 1
        ? 0.0
        : (size.width - 32) / (sorted.length - 1);
    final y = size.height / 2;
    canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), linePaint);
    for (var index = 0; index < sorted.length; index++) {
      final x = sorted.length == 1 ? size.width / 2 : 16 + step * index;
      canvas.drawCircle(Offset(x, y), 6, nodePaint);
      final text = TextPainter(
        text: TextSpan(
          text: sorted[index].title,
          style: AppTypography.labelXs.copyWith(color: AppColors.onSurface),
        ),
        maxLines: 2,
        ellipsis: '…',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 110);
      text.paint(
        canvas,
        Offset(x - text.width / 2, index.isEven ? y - 48 : y + 14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) =>
      oldDelegate.events != events;
}

class RelationshipsScreen extends ConsumerWidget {
  final String projectId;
  const RelationshipsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(charactersListProvider(projectId));
    final relationships = ref.watch(relationshipsStreamProvider(projectId));
    return characters.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar personajes: $e')),
      data: (people) => relationships.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar relaciones: $e')),
        data: (links) => _RelationshipsContent(
          projectId: projectId,
          characters: people,
          links: links,
        ),
      ),
    );
  }
}

class _RelationshipsContent extends ConsumerStatefulWidget {
  final String projectId;
  final List<Character> characters;
  final List<CharacterRelationship> links;

  const _RelationshipsContent({
    required this.projectId,
    required this.characters,
    required this.links,
  });

  @override
  ConsumerState<_RelationshipsContent> createState() =>
      _RelationshipsContentState();
}

class _RelationshipsContentState extends ConsumerState<_RelationshipsContent> {
  String _query = '';
  String _filter = 'Todos';
  String? _selectedCharacterId;
  String? _selectedLinkId;
  double _zoom = 1;
  bool _forceLayout = false;

  List<Character> get _visibleCharacters {
    final normalized = normalizeSearchText(_query);
    return widget.characters.where((character) {
      final matchesQuery =
          normalized.isEmpty ||
          character.searchableNames.any((name) => name.contains(normalized));
      return matchesQuery;
    }).toList();
  }

  List<CharacterRelationship> get _visibleLinks {
    final visibleIds = _visibleCharacters
        .map((character) => character.id)
        .toSet();
    return widget.links.where((link) {
      final matchesNodes =
          visibleIds.contains(link.sourceCharacterId) &&
          visibleIds.contains(link.targetCharacterId);
      return matchesNodes && _matchesFilter(link.relationType);
    }).toList();
  }

  bool _matchesFilter(String relation) {
    if (_filter == 'Todos') return true;
    final value = normalizeSearchText(relation);
    return switch (_filter) {
      'Familiar' =>
        value.contains('famil') ||
            value.contains('padre') ||
            value.contains('madre') ||
            value.contains('hijo') ||
            value.contains('herman'),
      'Romance' =>
        value.contains('pareja') ||
            value.contains('romance') ||
            value.contains('amor') ||
            value.contains('conyuge'),
      'Rivalidad' =>
        value.contains('rival') ||
            value.contains('enem') ||
            value.contains('odio'),
      'Aliados' =>
        value.contains('aliad') ||
            value.contains('negocio') ||
            value.contains('amig'),
      _ => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final characters = _visibleCharacters;
    final links = _visibleLinks;
    final selectedCharacter = _selectedCharacterId == null
        ? null
        : widget.characters.cast<Character?>().firstWhere(
            (character) => character?.id == _selectedCharacterId,
            orElse: () => null,
          );
    final selectedLink = _selectedLinkId == null
        ? null
        : widget.links.cast<CharacterRelationship?>().firstWhere(
            (link) => link?.id == _selectedLinkId,
            orElse: () => null,
          );
    return LayoutBuilder(
      builder: (context, constraints) {
        final inspectorVisible =
            constraints.maxWidth >= 880 &&
            (selectedCharacter != null || selectedLink != null);
        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _GraphToolbar(
                      charactersCount: widget.characters.length,
                      linksCount: widget.links.length,
                      query: _query,
                      filter: _filter,
                      onQueryChanged: (value) => setState(() => _query = value),
                      onFilterChanged: (value) =>
                          setState(() => _filter = value),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _RelationshipCanvas(
                              characters: characters,
                              links: links,
                              zoom: _zoom,
                              forceLayout: _forceLayout,
                              selectedCharacterId: _selectedCharacterId,
                              selectedLinkId: _selectedLinkId,
                              onTap: _selectAt,
                            ),
                          ),
                          if (characters.isEmpty)
                            const Center(
                              child: _EmptyTool(
                                text: 'No hay personajes que coincidan con el filtro.',
                              ),
                            ),
                          Positioned(
                            left: AppSpacing.md,
                            bottom: AppSpacing.md,
                            child: _GraphControls(
                              zoom: _zoom,
                              forceLayout: _forceLayout,
                              onZoomIn: () => setState(
                                () => _zoom = (_zoom + .15).clamp(.6, 2.2),
                              ),
                              onZoomOut: () => setState(
                                () => _zoom = (_zoom - .15).clamp(.6, 2.2),
                              ),
                              onFit: () => setState(() => _zoom = 1),
                              onToggleLayout: () =>
                                  setState(() => _forceLayout = !_forceLayout),
                            ),
                          ),
                          Positioned(
                            right: AppSpacing.md,
                            bottom: AppSpacing.md,
                            child: FloatingActionButton.extended(
                              onPressed: widget.characters.length < 2
                                  ? null
                                  : () => _addRelationship(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Nueva relación'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (inspectorVisible)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                width: 300,
                child: _RelationshipInspector(
                  character: selectedCharacter,
                  link: selectedLink,
                  characters: widget.characters,
                  onClose: () => setState(() {
                    _selectedCharacterId = null;
                    _selectedLinkId = null;
                  }),
                  onDelete: selectedLink == null
                      ? null
                      : () => _deleteRelationship(selectedLink),
                  onEdit: selectedLink == null
                      ? null
                      : () => _editRelationship(selectedLink),
                ),
              ),
          ],
        );
      },
    );
  }

  void _selectAt(Offset localPosition, Size size) {
    final positions = _graphPositions(
      _visibleCharacters,
      size,
      _forceLayout,
      _zoom,
    );
    String? characterId;
    for (final entry in positions.entries) {
      if ((entry.value - localPosition).distance <= 34) {
        characterId = entry.key;
        break;
      }
    }
    if (characterId != null) {
      setState(() {
        _selectedCharacterId = characterId;
        _selectedLinkId = null;
      });
      return;
    }
    for (final link in _visibleLinks) {
      final source = positions[link.sourceCharacterId];
      final target = positions[link.targetCharacterId];
      if (source != null &&
          target != null &&
          _distanceToSegment(localPosition, source, target) < 14) {
        setState(() {
          _selectedLinkId = link.id;
          _selectedCharacterId = null;
        });
        return;
      }
    }
    setState(() {
      _selectedCharacterId = null;
      _selectedLinkId = null;
    });
  }

  Future<void> _addRelationship(BuildContext context) async {
    final result = await showDialog<(String, String, String, String?)>(
      context: context,
      builder: (_) => _RelationshipDialog(characters: widget.characters),
    );
    if (result == null) return;
    final ok = await ref
        .read(storyToolsControllerProvider.notifier)
        .run(
          () => ref
              .read(storyToolsRepositoryProvider)
              .createRelationship(
                projectId: widget.projectId,
                sourceCharacterId: result.$1,
                targetCharacterId: result.$2,
                relationType: result.$3,
                description: result.$4,
              ),
        );
    if (ok) ref.invalidate(relationshipsProvider(widget.projectId));
  }

  Future<void> _deleteRelationship(CharacterRelationship link) async {
    await ref
        .read(storyToolsControllerProvider.notifier)
        .run(
          () => ref
              .read(storyToolsRepositoryProvider)
              .deleteRelationship(link.id),
        );
    if (!mounted) return;
    setState(() {
      _selectedLinkId = null;
    });
    ref.invalidate(relationshipsProvider(widget.projectId));
  }

  Future<void> _editRelationship(CharacterRelationship link) async {
    final result = await showDialog<(String, String, String, String?)>(
      context: context,
      builder: (_) =>
          _RelationshipDialog(characters: widget.characters, initial: link),
    );
    if (result == null) return;
    final ok = await ref
        .read(storyToolsControllerProvider.notifier)
        .run(
          () => ref
              .read(storyToolsRepositoryProvider)
              .updateRelationship(
                id: link.id,
                sourceCharacterId: result.$1,
                targetCharacterId: result.$2,
                relationType: result.$3,
                description: result.$4,
              ),
        );
    if (!mounted) return;
    if (ok) {
      setState(() => _selectedLinkId = null);
      ref.invalidate(relationshipsProvider(widget.projectId));
    }
  }
}

class _GraphToolbar extends StatelessWidget {
  final int charactersCount;
  final int linksCount;
  final String query;
  final String filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onFilterChanged;

  const _GraphToolbar({
    required this.charactersCount,
    required this.linksCount,
    required this.query,
    required this.filter,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mapa de relaciones', style: AppTypography.headlineMd),
            Text(
              '$charactersCount personajes · $linksCount vínculos',
              style: AppTypography.labelXs,
            ),
          ],
        ),
      ),
      SizedBox(
        width: 210,
        child: TextField(
          onChanged: onQueryChanged,
          decoration: const InputDecoration(
            hintText: 'Buscar personaje',
            prefixIcon: Icon(Icons.search, size: 18),
            isDense: true,
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      SizedBox(
        width: 130,
        child: DropdownButtonFormField<String>(
          initialValue: filter,
          isDense: true,
          decoration: const InputDecoration(
            labelText: 'Vínculo',
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          items: const ['Todos', 'Familiar', 'Romance', 'Rivalidad', 'Aliados']
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onFilterChanged(value);
          },
        ),
      ),
    ],
  );
}

class _GraphControls extends StatelessWidget {
  final double zoom;
  final bool forceLayout;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;
  final VoidCallback onToggleLayout;

  const _GraphControls({
    required this.zoom,
    required this.forceLayout,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
    required this.onToggleLayout,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Row(
      children: [
        IconButton(
          onPressed: onZoomOut,
          icon: const Icon(Icons.remove),
          tooltip: 'Alejar',
        ),
        Text('${(zoom * 100).round()}%', style: AppTypography.labelXs),
        IconButton(
          onPressed: onZoomIn,
          icon: const Icon(Icons.add),
          tooltip: 'Acercar',
        ),
        IconButton(
          onPressed: onFit,
          icon: const Icon(Icons.fit_screen_outlined),
          tooltip: 'Reencuadrar',
        ),
        const VerticalDivider(width: 1),
        IconButton(
          onPressed: onToggleLayout,
          icon: Icon(forceLayout ? Icons.hub : Icons.account_tree_outlined),
          tooltip: 'Alternar distribución',
        ),
      ],
    ),
  );
}

class _RelationshipCanvas extends StatelessWidget {
  final List<Character> characters;
  final List<CharacterRelationship> links;
  final double zoom;
  final bool forceLayout;
  final String? selectedCharacterId;
  final String? selectedLinkId;
  final void Function(Offset, Size) onTap;

  const _RelationshipCanvas({
    required this.characters,
    required this.links,
    required this.zoom,
    required this.forceLayout,
    required this.selectedCharacterId,
    required this.selectedLinkId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapUp: (details) => onTap(details.localPosition, context.size!),
    child: CustomPaint(
      painter: _RelationshipCanvasPainter(
        characters: characters,
        links: links,
        zoom: zoom,
        forceLayout: forceLayout,
        selectedCharacterId: selectedCharacterId,
        selectedLinkId: selectedLinkId,
      ),
      child: const SizedBox.expand(),
    ),
  );
}

class _RelationshipCanvasPainter extends CustomPainter {
  final List<Character> characters;
  final List<CharacterRelationship> links;
  final double zoom;
  final bool forceLayout;
  final String? selectedCharacterId;
  final String? selectedLinkId;

  _RelationshipCanvasPainter({
    required this.characters,
    required this.links,
    required this.zoom,
    required this.forceLayout,
    required this.selectedCharacterId,
    required this.selectedLinkId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = AppColors.background;
    canvas.drawRect(Offset.zero & size, background);
    final dotPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: .35)
      ..strokeWidth = 1;
    for (var x = 12.0; x < size.width; x += 24) {
      for (var y = 12.0; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1, dotPaint);
      }
    }
    final positions = _graphPositions(characters, size, forceLayout, zoom);
    final names = {
      for (final character in characters) character.id: character.fullName,
    };
    for (final link in links) {
      final from = positions[link.sourceCharacterId];
      final to = positions[link.targetCharacterId];
      if (from == null || to == null) continue;
      final paint = Paint()
        ..color = _relationColor(link.relationType)
        ..strokeWidth = link.id == selectedLinkId ? 3.5 : 2
        ..style = PaintingStyle.stroke;
      if (_isTense(link.relationType)) {
        _drawDashedLine(canvas, from, to, paint);
      } else {
        canvas.drawLine(from, to, paint);
      }
      final midpoint = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      final label = TextPainter(
        text: TextSpan(
          text: link.relationType,
          style: AppTypography.labelXs.copyWith(
            color: _relationColor(link.relationType),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 110);
      label.paint(canvas, midpoint + const Offset(5, -18));
    }
    for (final character in characters) {
      final center = positions[character.id]!;
      final selected = character.id == selectedCharacterId;
      final radius = selected ? 34.0 : 30.0;
      final fill = Paint()..color = AppColors.primaryContainer;
      final border = Paint()
        ..color = selected ? AppColors.primary : AppColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 3 : 1.5;
      canvas.drawCircle(center, radius, fill);
      canvas.drawCircle(center, radius, border);
      final initial = TextPainter(
        text: TextSpan(
          text: character.initial,
          style: AppTypography.headlineMd.copyWith(color: AppColors.onPrimary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      initial.paint(
        canvas,
        center - Offset(initial.width / 2, initial.height / 2),
      );
      final label = TextPainter(
        text: TextSpan(
          text: names[character.id],
          style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 160);
      label.paint(
        canvas,
        Offset(center.dx - label.width / 2, center.dy + radius + 7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RelationshipCanvasPainter oldDelegate) => true;
}

class _RelationshipInspector extends StatelessWidget {
  final Character? character;
  final CharacterRelationship? link;
  final List<Character> characters;
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _RelationshipInspector({
    required this.character,
    required this.link,
    required this.characters,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final names = {for (final item in characters) item.id: item.fullName};
    final title =
        character?.fullName ??
        (link == null ? 'Inspector' : 'Relación ${link!.relationType}');
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: AppTypography.headlineMd)),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            if (character != null) ...[
              Text('PERSONAJE', style: AppTypography.labelXs),
              const SizedBox(height: AppSpacing.sm),
              Text(character!.roleLabel, style: AppTypography.uiBodySm),
              if (character!.familyName != null)
                Text(
                  'Familia: ${character!.familyName}',
                  style: AppTypography.uiBodySm,
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Selecciona un vínculo para inspeccionar su descripción.',
                style: AppTypography.uiBodySm,
              ),
            ],
            if (link != null) ...[
              Text('VÍNCULO', style: AppTypography.labelXs),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${names[link!.sourceCharacterId]} · ${link!.relationType} · '
                '${names[link!.targetCharacterId]}',
                style: AppTypography.uiBodyMd,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                link!.description?.isNotEmpty == true ? link!.description! : 'Sin descripción. Añade una nota para dar contexto a este vínculo.',
                style: AppTypography.uiBodySm,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar datos'),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar relación'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Map<String, Offset> _graphPositions(
  List<Character> characters,
  Size size,
  bool forceLayout,
  double zoom,
) {
  final positions = <String, Offset>{};
  if (characters.isEmpty) return positions;
  final center = Offset(size.width / 2, size.height / 2);
  final radius =
      math.min(size.width, size.height) * (forceLayout ? .28 : .32) * zoom;
  for (var index = 0; index < characters.length; index++) {
    final angle = -math.pi / 2 + index * 2 * math.pi / characters.length;
    positions[characters[index].id] =
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }
  return positions;
}

double _distanceToSegment(Offset point, Offset start, Offset end) {
  final delta = end - start;
  final lengthSquared = delta.distanceSquared;
  if (lengthSquared == 0) return (point - start).distance;
  final projection =
      ((point - start).dx * delta.dx + (point - start).dy * delta.dy) /
      lengthSquared;
  final t = projection.clamp(0.0, 1.0);
  return (point - (start + delta * t)).distance;
}

Color _relationColor(String relation) {
  final value = normalizeSearchText(relation);
  if (value.contains('famil') ||
      value.contains('padre') ||
      value.contains('madre') ||
      value.contains('hijo')) {
    return Colors.cyan;
  }
  if (value.contains('pareja') ||
      value.contains('romance') ||
      value.contains('amor')) {
    return Colors.pinkAccent;
  }
  if (value.contains('rival') ||
      value.contains('enem') ||
      value.contains('odio')) {
    return Colors.deepOrange;
  }
  return Colors.green;
}

bool _isTense(String relation) {
  final value = normalizeSearchText(relation);
  return value.contains('rival') ||
      value.contains('enem') ||
      value.contains('tens');
}

void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
  final distance = (end - start).distance;
  final direction = (end - start) / distance;
  for (var offset = 0.0; offset < distance; offset += 12) {
    final from = start + direction * offset;
    final to = start + direction * math.min(offset + 6, distance);
    canvas.drawLine(from, to, paint);
  }
}

class _ToolList<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AsyncValue<List<T>> items;
  final String Function(T) label;
  final String Function(T) detail;
  final String? Function(T)? metadata;
  final VoidCallback onAdd;
  final Future<void> Function(T) onDelete;

  const _ToolList({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
    required this.label,
    required this.detail,
    this.metadata,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (values) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ToolHeader(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  onAdd: onAdd,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (values.isEmpty)
                  const _EmptyTool(text: 'Todavía no hay elementos guardados.')
                else
                  ...values.map(
                    (value) => Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        title: Text(
                          label(value),
                          style: AppTypography.uiBodyMd,
                        ),
                        subtitle: Text(
                          detail(value),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: metadata == null
                            ? null
                            : Text(
                                metadata!(value) ?? '',
                                style: AppTypography.labelXs,
                              ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onDelete(value),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAdd;

  const _ToolHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppColors.primaryContainer, size: 28),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headlineLg),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: AppTypography.uiBodySm),
          ],
        ),
      ),
      if (onAdd != null)
        IconButton.filled(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          tooltip: 'Añadir',
        ),
    ],
  );
}

class _EmptyTool extends StatelessWidget {
  final String text;
  const _EmptyTool({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.xl),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: AppRadii.allMd,
    ),
    child: Text(text, style: AppTypography.uiBodyMd),
  );
}

Future<(String, String)?> _textDialog(
  BuildContext context,
  String title,
  bool multiline,
) async {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final result = await showDialog<(String, String)>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: contentController,
              maxLines: multiline ? 6 : 1,
              decoration: const InputDecoration(labelText: 'Contenido'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (
            titleController.text,
            contentController.text,
          )),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  titleController.dispose();
  contentController.dispose();
  return result;
}

Future<(String, String, String?)?> _glossaryDialog(
  BuildContext context, {
  List<String> categories = const [],
}) async {
  final term = TextEditingController();
  final definition = TextEditingController();
  final category = TextEditingController();
  final result = await showDialog<(String, String, String?)>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Nuevo término'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: term,
            decoration: const InputDecoration(labelText: 'Término'),
          ),
          TextField(
            controller: definition,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Definición'),
          ),
          Autocomplete<String>(
            optionsBuilder: (value) {
              final query = normalizeSearchText(value.text);
              return categories.where(
                (item) => normalizeSearchText(item).contains(query),
              );
            },
            onSelected: (value) => category.text = value,
            fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
              controller.text = category.text;
              controller.addListener(() => category.text = controller.text);
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Categoría (opcional)',
                  hintText: 'Escribe una nueva o reutiliza una existente',
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (
            term.text,
            definition.text,
            category.text,
          )),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  term.dispose();
  definition.dispose();
  category.dispose();
  return result;
}

Future<(String, String?, DateTime)?> _timelineDialog(
  BuildContext context,
) async {
  final title = TextEditingController();
  final description = TextEditingController();
  DateTime date = DateTime.now();
  final result = await showDialog<(String, String?, DateTime)>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (_, setState) => AlertDialog(
        title: const Text('Nuevo evento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(_date(date)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: dialogContext,
                  firstDate: DateTime(1),
                  lastDate: DateTime(9999),
                  initialDate: date,
                );
                if (picked != null) setState(() => date = picked);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, (
              title.text,
              description.text,
              date,
            )),
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
  title.dispose();
  description.dispose();
  return result;
}

Future<
  (
    String,
    String?,
    String?,
    String,
    String?,
    String?,
    String?,
    String?,
    String?,
    String?,
    String?,
  )?
>
_bestiaryDialog(
  BuildContext context, {
  BestiaryEntry? initial,
  String? initialName,
  String title = 'Nueva criatura',
  List<String> categories = const [],
}) async {
  final name = TextEditingController(text: initialName ?? initial?.name);
  final category = TextEditingController(text: initial?.category);
  final mythology = TextEditingController(text: initial?.mythology);
  final description = TextEditingController(text: initial?.description);
  final weaknesses = TextEditingController(text: initial?.weaknesses);
  final abilities = TextEditingController(text: initial?.abilities);
  final habitat = TextEditingController(text: initial?.habitat);
  final danger = TextEditingController(text: initial?.dangerLevel);
  final historicalReferences = TextEditingController(
    text: initial?.historicalReferences,
  );
  final diet = TextEditingController(text: initial?.diet);
  final storyContext = TextEditingController(text: initial?.storyContext);
  final result =
      await showDialog<
        (
          String,
          String?,
          String?,
          String,
          String?,
          String?,
          String?,
          String?,
          String?,
          String?,
          String?,
        )
      >(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: category.text),
                  optionsBuilder: (value) {
                    final query = normalizeSearchText(value.text);
                    return categories.where(
                      (item) => normalizeSearchText(item).contains(query),
                    );
                  },
                  onSelected: (value) => category.text = value,
                  fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
                    controller.addListener(
                      () => category.text = controller.text,
                    );
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        hintText: 'Escribe una nueva o reutiliza una existente',
                      ),
                    );
                  },
                ),
                TextField(
                  controller: mythology,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mitología corta',
                    hintText: 'Origen legendario o explicación cultural.',
                  ),
                ),
                TextField(
                  controller: description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Aspecto, comportamiento y características.',
                  ),
                ),
                TextField(
                  controller: weaknesses,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Debilidades',
                    hintText: 'Qué la limita o cómo puede ser vencida.',
                  ),
                ),
                TextField(
                  controller: abilities,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Habilidades',
                    hintText:
                        'Poderes, capacidades o comportamientos especiales.',
                  ),
                ),
                TextField(
                  controller: habitat,
                  decoration: const InputDecoration(
                    labelText: 'Hábitat',
                    hintText: 'Dónde aparece o vive.',
                  ),
                ),
                TextField(
                  controller: danger,
                  decoration: const InputDecoration(
                    labelText: 'Nivel de peligro',
                    hintText: 'Bajo, medio, alto...',
                  ),
                ),
                TextField(
                  controller: historicalReferences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Referencias históricas',
                    hintText:
                        'Culturas, relatos o fuentes que inspiraron su origen.',
                  ),
                ),
                TextField(
                  controller: diet,
                  decoration: const InputDecoration(
                    labelText: 'Alimentación',
                    hintText: 'Qué come o de qué obtiene energía.',
                  ),
                ),
                TextField(
                  controller: storyContext,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Contexto actual en la historia',
                    hintText: 'Qué papel cumple actualmente en el manuscrito.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty ||
                    description.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(dialogContext, (
                  name.text,
                  category.text,
                  mythology.text,
                  description.text,
                  weaknesses.text,
                  abilities.text,
                  habitat.text,
                  danger.text,
                  historicalReferences.text,
                  diet.text,
                  storyContext.text,
                ));
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
  name.dispose();
  category.dispose();
  mythology.dispose();
  description.dispose();
  weaknesses.dispose();
  abilities.dispose();
  habitat.dispose();
  danger.dispose();
  historicalReferences.dispose();
  diet.dispose();
  storyContext.dispose();
  return result;
}

class _RelationshipDialog extends StatefulWidget {
  final List<Character> characters;
  final CharacterRelationship? initial;
  const _RelationshipDialog({required this.characters, this.initial});
  @override
  State<_RelationshipDialog> createState() => _RelationshipDialogState();
}

class _RelationshipDialogState extends State<_RelationshipDialog> {
  String? source;
  String? target;
  final relation = TextEditingController();
  final description = TextEditingController();

  @override
  void initState() {
    super.initState();
    source = widget.initial?.sourceCharacterId;
    target = widget.initial?.targetCharacterId;
    relation.text = widget.initial?.relationType ?? '';
    description.text = widget.initial?.description ?? '';
  }

  @override
  void dispose() {
    relation.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.initial == null ? 'Nueva relación' : 'Editar relación'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          initialValue: source,
          decoration: const InputDecoration(labelText: 'Personaje origen'),
          items: widget.characters
              .map(
                (c) => DropdownMenuItem(value: c.id, child: Text(c.fullName)),
              )
              .toList(),
          onChanged: (v) => setState(() => source = v),
        ),
        DropdownButtonFormField<String>(
          initialValue: target,
          decoration: const InputDecoration(labelText: 'Personaje destino'),
          items: widget.characters
              .map(
                (c) => DropdownMenuItem(value: c.id, child: Text(c.fullName)),
              )
              .toList(),
          onChanged: (v) => setState(() => target = v),
        ),
        TextField(
          controller: relation,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Tipo (aliados, rival...)',
          ),
        ),
        TextField(
          controller: description,
          decoration: const InputDecoration(labelText: 'Descripción opcional'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final type in const [
                'progenitor',
                'hijo',
                'hermano',
                'pareja',
                'aliado',
                'rival',
              ])
                ActionChip(
                  label: Text(type),
                  onPressed: () {
                    relation.text = type;
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed:
            source == null || target == null || relation.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, (
                source!,
                target!,
                relation.text,
                description.text,
              )),
        child: const Text('Guardar'),
      ),
    ],
  );
}

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
