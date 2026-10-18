import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/character_providers.dart';
import '../widgets/character_card.dart';
import '../widgets/empty_characters_view.dart';

class CharactersListScreen extends ConsumerStatefulWidget {
  final String projectId;

  const CharactersListScreen({super.key, required this.projectId});

  @override
  ConsumerState<CharactersListScreen> createState() =>
      _CharactersListScreenState();
}

class _CharactersListScreenState extends ConsumerState<CharactersListScreen> {
  String _searchQuery = '';
  String? _roleFilter;

  @override
  Widget build(BuildContext context) {
    final charactersAsync =
        ref.watch(charactersListProvider(widget.projectId));

    return charactersAsync.when(
      data: (characters) => _buildContent(characters),
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryContainer,
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Error: $e',
            textAlign: TextAlign.center,
            style: AppTypography.uiBodySm,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List characters) {
    if (characters.isEmpty) {
      return EmptyCharactersView(
        onCreate: () => _openForm(),
      );
    }

    // Filtrado local
    final filtered = characters.where((c) {
      final matchesQuery = _searchQuery.isEmpty ||
          c.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (c.familyName?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false);
      final matchesRole = _roleFilter == null || c.role == _roleFilter;
      return matchesQuery && matchesRole;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                count: characters.length,
                onCreate: () => _openForm(),
              ),
              const SizedBox(height: AppSpacing.md),
              _FilterBar(
                query: _searchQuery,
                roleFilter: _roleFilter,
                onQueryChange: (v) => setState(() => _searchQuery = v),
                onRoleChange: (v) => setState(() => _roleFilter = v),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (filtered.isEmpty)
                _NoResults(
                  onClear: () => setState(() {
                    _searchQuery = '';
                    _roleFilter = null;
                  }),
                )
              else
                _Grid(
                  projectId: widget.projectId,
                  characters: filtered,
                  onEdit: (id) => _openForm(id: id),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openForm({String? id}) async {
    if (id == null) {
      await context.push(
        '/project/${widget.projectId}/characters/new',
      );
    } else {
      await context.push(
        '/project/${widget.projectId}/characters/$id',
      );
    }
    // Al volver, invalidamos la lista
    ref.invalidate(charactersListProvider(widget.projectId));
  }
}

// ============================================
// SUB-WIDGETS
// ============================================
class _Header extends StatelessWidget {
  final int count;
  final VoidCallback onCreate;

  const _Header({required this.count, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personajes', style: AppTypography.headlineLg),
            const SizedBox(height: 2),
            Text(
              count == 1 ? '1 personaje' : '$count personajes',
              style: AppTypography.uiBodySm,
            ),
          ],
        ),
        const Spacer(),
        Material(
          color: AppColors.primaryContainer,
          borderRadius: AppRadii.allMd,
          child: InkWell(
            onTap: onCreate,
            borderRadius: AppRadii.allMd,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add,
                    size: 18,
                    color: AppColors.onPrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Nuevo personaje',
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
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String query;
  final String? roleFilter;
  final ValueChanged<String> onQueryChange;
  final ValueChanged<String?> onRoleChange;

  const _FilterBar({
    required this.query,
    required this.roleFilter,
    required this.onQueryChange,
    required this.onRoleChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onQueryChange,
            style: AppTypography.uiBodySm,
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre...',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Simplificamos: solo un selector de rol "Todos" + roles
        DropdownButton<String?>(
          value: roleFilter,
          hint: Text('Todos los roles', style: AppTypography.uiBodySm),
          style: AppTypography.uiBodySm,
          underline: const SizedBox.shrink(),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos')),
            ..._roleOptions(),
          ],
          onChanged: onRoleChange,
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _roleOptions() {
    // Importar CharacterRoles si lo quieres completo
    return const [
      DropdownMenuItem(value: 'protagonist', child: Text('Protagonista')),
      DropdownMenuItem(value: 'antagonist', child: Text('Antagonista')),
      DropdownMenuItem(value: 'secondary', child: Text('Secundario')),
      DropdownMenuItem(value: 'tertiary', child: Text('Terciario')),
      DropdownMenuItem(value: 'mentioned', child: Text('Mencionado')),
    ];
  }
}

class _NoResults extends StatelessWidget {
  final VoidCallback onClear;

  const _NoResults({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Text(
              'No hay resultados',
              style: AppTypography.headlineSm,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Prueba con otro criterio de búsqueda.',
              style: AppTypography.uiBodySm,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onClear,
              child: const Text('Limpiar filtros'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends ConsumerWidget {
  final String projectId;
  final List characters;
  final void Function(String id) onEdit;

  const _Grid({
    required this.projectId,
    required this.characters,
    required this.onEdit,
  });

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar personaje'),
        content: Text('¿Eliminar "$name"? Esta acción no se puede deshacer.'),
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
          .read(charactersControllerProvider.notifier)
          .delete(id, projectId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
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
            childAspectRatio: 1.6,
          ),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final c = characters[index];
            return CharacterCard(
              character: c,
              onTap: () => onEdit(c.id),
              onDelete: () => _confirmDelete(
                context,
                ref,
                c.id,
                c.name,
              ),
            );
          },
        );
      },
    );
  }
}