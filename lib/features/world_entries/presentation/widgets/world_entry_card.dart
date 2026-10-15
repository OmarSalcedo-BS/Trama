import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../constants/world_colors.dart';
import '../../domain/models/world_entry.dart';

class WorldEntryCard extends StatelessWidget {
  final WorldEntry entry;
  final String categoryColorCode;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const WorldEntryCard({
    super.key,
    required this.entry,
    required this.categoryColorCode,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent = WorldColors.getColor(categoryColorCode);

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: AppRadii.allLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.allLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
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
              // Barra de color superior + menú
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: AppRadii.allSm,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      entry.title,
                      style: AppTypography.headlineSm.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                        onSelected: (v) {
                          if (v == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar ficha'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Resumen
              Expanded(
                child: Text(
                  entry.summary?.isNotEmpty == true
                      ? entry.summary!
                      : 'Sin resumen todavía.',
                  style: AppTypography.uiBodySm.copyWith(
                    color: entry.summary?.isNotEmpty == true
                        ? AppColors.onSurfaceVariant
                        : AppColors.outline,
                    fontStyle: entry.summary?.isNotEmpty == true
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Tags
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: entry.tags
                      .take(3)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: AppRadii.allSm,
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.labelXs.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}