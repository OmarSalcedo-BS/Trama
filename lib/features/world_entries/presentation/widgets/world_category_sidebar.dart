import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../constants/world_colors.dart';
import '../../constants/world_icons.dart';
import '../../domain/models/world_category.dart';

class WorldCategorySidebar extends StatelessWidget {
  final List<WorldCategory> categories;
  final String? activeCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final VoidCallback onCreateCategory;
  final void Function(WorldCategory category) onEditCategory;
  final void Function(WorldCategory category) onDeleteCategory;

  const WorldCategorySidebar({
    super.key,
    required this.categories,
    required this.activeCategoryId,
    required this.onCategorySelected,
    required this.onCreateCategory,
    required this.onEditCategory,
    required this.onDeleteCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
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
            child: Row(
              children: [
                Text(
                  'Categorías',
                  style: AppTypography.labelXs.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message: 'Nueva categoría',
                  child: InkWell(
                    onTap: onCreateCategory,
                    borderRadius: AppRadii.allSm,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadii.allSm,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add,
                        size: 14,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.sm,
              ),
              children: [
                // Item "Todas"
                _CategoryItem(
                  label: 'Todas las fichas',
                  iconCode: 'category',
                  colorCode: 'slate',
                  count: categories.fold(
                    0,
                    (sum, cat) => sum + cat.entryCount,
                  ),
                  isActive: activeCategoryId == null,
                  onTap: () => onCategorySelected(null),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Divider(height: 0.5, color: AppColors.outlineVariant),
                const SizedBox(height: AppSpacing.xs),

                // Categorías
                ...categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _CategoryItem(
                        label: cat.name,
                        iconCode: cat.icon,
                        colorCode: cat.color,
                        count: cat.entryCount,
                        isActive: activeCategoryId == cat.id,
                        onTap: () => onCategorySelected(cat.id),
                        onEdit: () => onEditCategory(cat),
                        onDelete: () => onDeleteCategory(cat),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final String iconCode;
  final String colorCode;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryItem({
    required this.label,
    required this.iconCode,
    required this.colorCode,
    required this.count,
    required this.isActive,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent = WorldColors.getColor(colorCode);
    final icon = WorldIcons.getIcon(iconCode);

    return Material(
      color: isActive ? AppColors.surfaceContainer : Colors.transparent,
      borderRadius: AppRadii.allMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.allMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadii.allSm,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 14, color: accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.uiBodySm.copyWith(
                    color: isActive
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                    fontWeight:
                        isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onEdit != null || onDelete != null)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: PopupMenuButton<String>(
                    tooltip: '',
                    padding: EdgeInsets.zero,
                    iconSize: 14,
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onSelected: (v) {
                      if (v == 'edit') onEdit?.call();
                      if (v == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar'),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar'),
                        ),
                    ],
                  ),
                )
              else
                Text(
                  '$count',
                  style: AppTypography.labelXs.copyWith(
                    color: AppColors.outline,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}