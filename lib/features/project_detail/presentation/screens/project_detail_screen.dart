import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../providers/project_section_provider.dart';
import '../widgets/project_sidebar.dart';
import '../../../characters/presentation/screens/characters_list_screen.dart';
import '../../../world_entries/presentation/screens/world_screen.dart';
import '../../../story_tools/presentation/screens/story_tools_screens.dart';
import '../../../chapters/presentation/screens/chapter_editor_screen.dart';
import '../../../chapters/presentation/providers/chapter_providers.dart';
import '../../../characters/presentation/providers/character_providers.dart';
import '../../../import_export/presentation/screens/import_export_screen.dart';
import 'about_legal_screen.dart';

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
          child: CircularProgressIndicator(color: AppColors.primaryContainer),
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

class _ProjectLayout extends ConsumerStatefulWidget {
  final String projectId;
  final String projectTitle;

  const _ProjectLayout({required this.projectId, required this.projectTitle});

  @override
  ConsumerState<_ProjectLayout> createState() => _ProjectLayoutState();
}

class _ProjectLayoutState extends ConsumerState<_ProjectLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarVisible = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  void _openMobileDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(activeSectionProvider(widget.projectId));
    final isNarrow = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isNarrow
          ? Drawer(
              backgroundColor: AppColors.surfaceContainerLowest,
              child: SafeArea(
                child: ProjectSidebar(
                  projectId: widget.projectId,
                  projectTitle: widget.projectTitle,
                  width: null,
                  onBackToDashboard: () {
                    Navigator.of(context).pop();
                    context.go('/dashboard');
                  },
                  onSectionSelected: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar (solo en pantallas de escritorio/anchas y cuando no esté colapsado)
          if (!isNarrow && _isSidebarVisible)
            ProjectSidebar(
              projectId: widget.projectId,
              projectTitle: widget.projectTitle,
              onBackToDashboard: () => context.go('/dashboard'),
              onCollapse: _toggleSidebar,
            ),

          // Área de contenido principal
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  projectTitle: widget.projectTitle,
                  sectionLabel: section.label,
                  isNarrow: isNarrow,
                  isSidebarVisible: _isSidebarVisible,
                  onMenuPressed: isNarrow ? _openMobileDrawer : _toggleSidebar,
                  onBack: () => context.go('/dashboard'),
                ),
                Expanded(
                  child: _SectionContent(
                    projectId: widget.projectId,
                    section: section,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String projectTitle;
  final String sectionLabel;
  final bool isNarrow;
  final bool isSidebarVisible;
  final VoidCallback onMenuPressed;
  final VoidCallback onBack;

  const _TopBar({
    required this.projectTitle,
    required this.sectionLabel,
    required this.isNarrow,
    required this.isSidebarVisible,
    required this.onMenuPressed,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? AppSpacing.sm : AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: isNarrow
                ? 'Abrir menú de navegación'
                : (isSidebarVisible
                    ? 'Ocultar menú lateral (Modo concentración)'
                    : 'Mostrar menú lateral'),
            icon: Icon(
              isNarrow
                  ? Icons.menu
                  : (isSidebarVisible ? Icons.menu_open : Icons.menu),
              size: 20,
              color: AppColors.onSurface,
            ),
            onPressed: onMenuPressed,
          ),
          const SizedBox(width: AppSpacing.xs),
          if (isNarrow) ...[
            IconButton(
              tooltip: 'Volver a proyectos',
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              projectTitle,
              style: AppTypography.uiBodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text('/', style: TextStyle(color: AppColors.outline)),
          ),
          Flexible(
            child: Text(
              sectionLabel,
              style: AppTypography.uiBodySm.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenido por sección.
class _SectionContent extends StatelessWidget {
  final String projectId;
  final ProjectSection section;

  const _SectionContent({required this.projectId, required this.section});

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      ProjectSection.overview => _OverviewPlaceholder(projectId: projectId),
      ProjectSection.chapters => ChapterEditorScreen(projectId: projectId),
      ProjectSection.characters => CharactersListScreen(projectId: projectId),
      ProjectSection.worldEntries => WorldScreen(projectId: projectId),
      ProjectSection.bestiary => BestiaryScreen(projectId: projectId),
      ProjectSection.timeline => TimelineScreen(projectId: projectId),
      ProjectSection.glossary => GlossaryScreen(projectId: projectId),
      ProjectSection.relationships => RelationshipsScreen(projectId: projectId),
      ProjectSection.export => ImportExportScreen(projectId: projectId),
      ProjectSection.about => AboutLegalScreen(projectId: projectId),
    };
  }
}

class _OverviewPlaceholder extends ConsumerWidget {
  final String projectId;

  const _OverviewPlaceholder({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));
    final chaptersAsync = ref.watch(chaptersProvider(projectId));
    final charactersAsync = ref.watch(charactersListProvider(projectId));

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
                  Text(
                    project.synopsis?.trim().isNotEmpty == true
                        ? project.synopsis!
                        : 'Tu espacio de trabajo para escribir, organizar y conectar cada parte de tu historia.',
                    style: AppTypography.manuscriptMd,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Estadísticas', style: AppTypography.headlineSm),
                  const SizedBox(height: AppSpacing.md),
                  _OverviewStats(
                    chapterCount:
                        chaptersAsync.valueOrNull?.length ??
                        project.chapterCount,
                    characterCount:
                        charactersAsync.valueOrNull?.length ??
                        project.characterCount,
                    wordCount:
                        chaptersAsync.valueOrNull?.fold<int>(
                          0,
                          (total, chapter) =>
                              total + _wordCount(chapter.content),
                        ) ??
                        project.wordCount,
                    genre: project.genre ?? '—',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _OverviewGuidance(
                    chapterCount:
                        chaptersAsync.valueOrNull?.length ??
                        project.chapterCount,
                    characterCount:
                        charactersAsync.valueOrNull?.length ??
                        project.characterCount,
                    wordCount:
                        chaptersAsync.valueOrNull?.fold<int>(
                          0,
                          (total, chapter) =>
                              total + _wordCount(chapter.content),
                        ) ??
                        project.wordCount,
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

int _wordCount(String text) =>
    RegExp(r'[^\s]+', unicode: true).allMatches(text).length;

class _OverviewGuidance extends StatelessWidget {
  final int chapterCount;
  final int characterCount;
  final int wordCount;

  const _OverviewGuidance({
    required this.chapterCount,
    required this.characterCount,
    required this.wordCount,
  });

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.surfaceContainerLow,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado del proyecto', style: AppTypography.headlineSm),
          const SizedBox(height: AppSpacing.sm),
          Text(
            wordCount == 0
                ? 'Empieza creando un capítulo para que el editor pueda contar tus palabras y mostrar tu progreso.'
                : 'Tu manuscrito ya tiene $wordCount palabras distribuidas en $chapterCount capítulos.',
            style: AppTypography.uiBodyMd,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _OverviewPill(
                icon: Icons.edit_note_outlined,
                text: chapterCount == 0
                    ? 'Crea tu primer capítulo'
                    : '$chapterCount capítulos listos',
              ),
              _OverviewPill(
                icon: Icons.people_outline,
                text: characterCount == 0
                    ? 'Añade personajes'
                    : '$characterCount personajes conectados',
              ),
              _OverviewPill(
                icon: Icons.menu_book_outlined,
                text: 'Explora tus herramientas de mundo',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _OverviewPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OverviewPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 16),
    label: Text(text),
    visualDensity: VisualDensity.compact,
  );
}

class _OverviewStats extends StatelessWidget {
  final int chapterCount;
  final int characterCount;
  final int wordCount;
  final String genre;

  const _OverviewStats({
    required this.chapterCount,
    required this.characterCount,
    required this.wordCount,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      (label: 'Capítulos', value: '$chapterCount'),
      (label: 'Personajes', value: '$characterCount'),
      (label: 'Palabras', value: '$wordCount'),
      (label: 'Género', value: genre),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        if (isCompact) {
          return Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: stats.map((stat) {
              final itemWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
              return SizedBox(
                width: itemWidth > 120 ? itemWidth : double.infinity,
                child: _StatCard(label: stat.label, value: stat.value),
              );
            }).toList(),
          );
        }

        return Row(
          children: stats.map((stat) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: _StatCard(label: stat.label, value: stat.value),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
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
