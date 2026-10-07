import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: AppRadii.allLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.allLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadii.allLg,
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: género + menú
              Row(
                children: [
                  if (project.genre != null && project.genre!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadii.allSm,
                      ),
                      child: Text(
                        project.genre!,
                        style: AppTypography.labelXs.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (onDelete != null)
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: PopupMenuButton<String>(
                        tooltip: 'Opciones',
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon: const Icon(
                          Icons.more_horiz,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onSelected: (value) {
                          if (value == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar proyecto'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Título
              Text(
                project.title,
                style: AppTypography.headlineMd,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Sinopsis
              Expanded(
                child: Text(
                  project.synopsis?.isNotEmpty == true
                      ? project.synopsis!
                      : 'Sin sinopsis todavía.',
                  style: AppTypography.uiBodySm.copyWith(
                    color: project.synopsis?.isNotEmpty == true
                        ? AppColors.onSurfaceVariant
                        : AppColors.outline,
                    fontStyle: project.synopsis?.isNotEmpty == true
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Métricas
              Row(
                children: [
                  _Metric(
                    icon: Icons.menu_book_outlined,
                    label: '${project.chapterCount}',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _Metric(
                    icon: Icons.people_outline,
                    label: '${project.characterCount}',
                  ),
                  const Spacer(),
                  Text(
                    _relativeDate(project.updatedAt),
                    style: AppTypography.labelXs,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inHours < 1) return 'hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'hace ${diff.inHours} h';
    if (diff.inDays < 30) return 'hace ${diff.inDays} d';
    if (diff.inDays < 365) return 'hace ${(diff.inDays / 30).floor()} mes';
    return 'hace ${(diff.inDays / 365).floor()} año';
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Metric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.outline),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelXs.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}