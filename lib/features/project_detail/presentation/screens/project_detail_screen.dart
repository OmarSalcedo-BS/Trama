import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../providers/project_section_provider.dart';
import '../widgets/project_sidebar.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: projectAsync.when(
        data: (project) {
          if (project == null) {
            return const _ProjectNotFound();
          }
          return _ProjectLayout(
            projectId: project.id,
            projectTitle: project.title,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryContainer,
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 32,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No se pudo cargar el proyecto',
                  style: AppTypography.headlineSm,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: AppTypography.uiBodySm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectLayout extends ConsumerWidget {
  final String projectId;
  final String projectTitle;

  const _ProjectLayout({
    required this.projectId,
    required this.projectTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(activeSectionProvider(projectId));
    final isNarrow = MediaQuery.of(context).size.width < 900;

    return Row(
      children: [
        // Sidebar (solo en pantallas anchas por ahora)
        if (!isNarrow)
          ProjectSidebar(
            projectId: projectId,
            projectTitle: projectTitle,
            onBackToDashboard: () => context.go('/dashboard'),
          ),

        // Área de contenido
        Expanded(
          child: Column(
            children: [
              _TopBar(
                projectTitle: projectTitle,
                sectionLabel: section.label,
                showBackButton: isNarrow,
                onBack: () => context.go('/dashboard'),
              ),
              Expanded(
                child: _SectionContent(
                  projectId: projectId,
                  section: section,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final String projectTitle;
  final String sectionLabel;
  final bool showBackButton;
  final VoidCallback onBack;

  const _TopBar({
    required this.projectTitle,
    required this.sectionLabel,
    required this.showBackButton,
    required this.onBack,
  });

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
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              projectTitle,
              style: AppTypography.uiBodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              '/',
              style: TextStyle(color: AppColors.outline),
            ),
          ),
          Text(
            sectionLabel,
            style: AppTypography.uiBodySm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenido por sección.
/// Por ahora, placeholders. Se rellenan en sub-bloques siguientes.
class _SectionContent extends StatelessWidget {
  final String projectId;
  final ProjectSection section;

  const _SectionContent({
    required this.projectId,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      ProjectSection.overview => _OverviewPlaceholder(projectId: projectId),
      ProjectSection.chapters => _Placeholder('Capítulos / Editor'),
      ProjectSection.characters => _Placeholder('Personajes'),
      ProjectSection.worldEntries => _Placeholder('Fichas de mundo'),
      ProjectSection.bestiary => _Placeholder('Bestiario'),
      ProjectSection.timeline => _Placeholder('Cronología'),
      ProjectSection.glossary => _Placeholder('Glosario'),
      ProjectSection.relationships => _Placeholder('Relaciones'),
      ProjectSection.export => _Placeholder('Exportar'),
    };
  }
}

class _OverviewPlaceholder extends ConsumerWidget {
  final String projectId;

  const _OverviewPlaceholder({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));

    return projectAsync.when(
      data: (project) {
        if (project == null) return const SizedBox.shrink();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.title, style: AppTypography.headlineLg),
                  const SizedBox(height: AppSpacing.md),
                  if (project.synopsis != null)
                    Text(
                      project.synopsis!,
                      style: AppTypography.manuscriptMd,
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Estadísticas', style: AppTypography.headlineSm),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _Stat(
                        label: 'Capítulos',
                        value: '${project.chapterCount}',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _Stat(
                        label: 'Personajes',
                        value: '${project.characterCount}',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _Stat(
                        label: 'Género',
                        value: project.genre ?? '—',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: AppTypography.labelXs),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.headlineSm),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String label;

  const _Placeholder(this.label);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.headlineMd),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sección en construcción',
            style: AppTypography.uiBodySm,
          ),
        ],
      ),
    );
  }
}

class _ProjectNotFound extends StatelessWidget {
  const _ProjectNotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Proyecto no encontrado', style: AppTypography.headlineSm),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Volver al dashboard'),
          ),
        ],
      ),
    );
  }
}