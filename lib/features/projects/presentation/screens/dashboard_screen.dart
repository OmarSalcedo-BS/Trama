import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/project_providers.dart';
import '../widgets/empty_projects_view.dart';
import '../widgets/new_project_dialog.dart';
import '../widgets/project_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _DashboardHeader(userName: user?.displayName ?? user?.email),
          Expanded(
            child: projectsAsync.when(
              data: (projects) => _buildBody(context, projects),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryContainer,
                ),
              ),
              error: (e, _) => _buildError(context, e.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List projects) {
    if (projects.isEmpty) {
      return EmptyProjectsView(
        onCreate: () => NewProjectDialog.show(context),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                count: projects.length,
                onCreate: () => NewProjectDialog.show(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ProjectsGrid(projects: projects),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 32,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No se pudieron cargar tus proyectos',
              style: AppTypography.headlineSm,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.uiBodySm,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// HEADER
// ============================================
class _DashboardHeader extends ConsumerWidget {
  final String? userName;

  const _DashboardHeader({this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadii.allSm,
                ),
                alignment: Alignment.center,
                child: Text(
                  'T',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppConstants.appName,
                style: AppTypography.headlineSm.copyWith(
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          _UserMenu(userName: userName),
        ],
      ),
    );
  }
}

class _UserMenu extends ConsumerWidget {
  final String? userName;

  const _UserMenu({this.userName});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: 'Cuenta',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: AppRadii.allMd),
      color: AppColors.surfaceContainerLowest,
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName ?? 'Sin nombre',
                style: AppTypography.uiBodyMd.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text('Cuenta', style: AppTypography.labelXs),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16),
              SizedBox(width: 8),
              Text('Cerrar sesión'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'signout') _signOut(context, ref);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadii.allMd,
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                (userName?.isNotEmpty == true ? userName![0] : '?')
                    .toUpperCase(),
                style: AppTypography.labelXs.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              userName ?? 'Cuenta',
              style: AppTypography.uiBodySm.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// SECTION TITLE + GRID
// ============================================
class _SectionTitle extends StatelessWidget {
  final int count;
  final VoidCallback onCreate;

  const _SectionTitle({required this.count, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tus proyectos', style: AppTypography.headlineLg),
            const SizedBox(height: 2),
            Text(
              count == 1 ? '1 proyecto' : '$count proyectos',
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
                    'Nuevo proyecto',
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

class _ProjectsGrid extends ConsumerWidget {
  final List projects;

  const _ProjectsGrid({required this.projects});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: Text(
          '¿Eliminar "$title"? Se borrarán también sus capítulos, '
          'personajes y fichas de mundo. Esta acción no se puede deshacer.',
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
      await ref.read(projectsControllerProvider.notifier).delete(id);
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
            childAspectRatio: 1.4,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              project: project,
              onTap: () => context.go('/project/${project.id}'),
              onDelete: () => _confirmDelete(
                context,
                ref,
                project.id,
                project.title,
              ),
            );
          },
        );
      },
    );
  }
}