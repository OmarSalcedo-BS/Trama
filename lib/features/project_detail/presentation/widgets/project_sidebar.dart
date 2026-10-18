import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/project_section_provider.dart';

class ProjectSidebar extends ConsumerWidget {
  final String projectId;
  final String projectTitle;
  final VoidCallback onBackToDashboard;
  final VoidCallback? onCollapse;
  final VoidCallback? onSectionSelected;
  final double? width;

  const ProjectSidebar({
    super.key,
    required this.projectId,
    required this.projectTitle,
    required this.onBackToDashboard,
    this.onCollapse,
    this.onSectionSelected,
    this.width = 260,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSectionProvider(projectId));

    return Container(
      width: width,
      color: AppColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera: título del proyecto + volver
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onBackToDashboard,
                        borderRadius: AppRadii.allSm,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_back,
                                size: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Proyectos',
                                style: AppTypography.labelXs.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (onCollapse != null)
                      IconButton(
                        tooltip: 'Ocultar barra lateral',
                        onPressed: onCollapse,
                        icon: const Icon(
                          Icons.keyboard_double_arrow_left,
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  projectTitle,
                  style: AppTypography.headlineSm.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Navegación
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.sm,
              ),
              children: [
                _SectionItem(
                  section: ProjectSection.overview,
                  icon: Icons.dashboard_outlined,
                  isActive: active == ProjectSection.overview,
                  onTap: () => _setSection(ref, ProjectSection.overview),
                ),
                _SectionItem(
                  section: ProjectSection.chapters,
                  icon: Icons.edit_note_outlined,
                  isActive: active == ProjectSection.chapters,
                  onTap: () => _setSection(ref, ProjectSection.chapters),
                ),
                const _GroupLabel('Estructura'),
                _SectionItem(
                  section: ProjectSection.characters,
                  icon: Icons.people_outline,
                  isActive: active == ProjectSection.characters,
                  onTap: () => _setSection(ref, ProjectSection.characters),
                ),
                _SectionItem(
                  section: ProjectSection.relationships,
                  icon: Icons.hub_outlined,
                  isActive: active == ProjectSection.relationships,
                  onTap: () => _setSection(ref, ProjectSection.relationships),
                ),
                const _GroupLabel('Mundo'),
                _SectionItem(
                  section: ProjectSection.worldEntries,
                  icon: Icons.public_outlined,
                  isActive: active == ProjectSection.worldEntries,
                  onTap: () => _setSection(ref, ProjectSection.worldEntries),
                ),
                _SectionItem(
                  section: ProjectSection.bestiary,
                  icon: Icons.pets_outlined,
                  isActive: active == ProjectSection.bestiary,
                  onTap: () => _setSection(ref, ProjectSection.bestiary),
                ),
                _SectionItem(
                  section: ProjectSection.timeline,
                  icon: Icons.timeline_outlined,
                  isActive: active == ProjectSection.timeline,
                  onTap: () => _setSection(ref, ProjectSection.timeline),
                ),
                _SectionItem(
                  section: ProjectSection.glossary,
                  icon: Icons.menu_book_outlined,
                  isActive: active == ProjectSection.glossary,
                  onTap: () => _setSection(ref, ProjectSection.glossary),
                ),
                const _GroupLabel('Publicación'),
                _SectionItem(
                  section: ProjectSection.export,
                  icon: Icons.ios_share_outlined,
                  isActive: active == ProjectSection.export,
                  onTap: () => _setSection(ref, ProjectSection.export),
                ),
                const _GroupLabel('Información'),
                _SectionItem(
                  section: ProjectSection.about,
                  icon: Icons.info_outline,
                  isActive: active == ProjectSection.about,
                  onTap: () => _setSection(ref, ProjectSection.about),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setSection(WidgetRef ref, ProjectSection section) {
    ref.read(activeSectionProvider(projectId).notifier).state = section;
    onSectionSelected?.call();
  }
}

class _SectionItem extends StatelessWidget {
  final ProjectSection section;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SectionItem({
    required this.section,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isActive
            ? AppColors.surfaceContainer
            : Colors.transparent,
        borderRadius: AppRadii.allMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.allMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive
                      ? AppColors.primaryContainer
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  section.label,
                  style: AppTypography.uiBodySm.copyWith(
                    color: isActive
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                    fontWeight:
                        isActive ? FontWeight.w500 : FontWeight.w400,
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

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        top: AppSpacing.md,
        bottom: AppSpacing.xs,
      ),
      child: Text(text.toUpperCase(), style: AppTypography.labelXs),
    );
  }
}