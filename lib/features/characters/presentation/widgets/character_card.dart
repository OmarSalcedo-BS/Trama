import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/character.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CharacterCard({
    super.key,
    required this.character,
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
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.allLg,
            border: Border.all(color: AppColors.outlineVariant, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + menú
              Row(
                children: [
                  _Avatar(character: character),
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
                        onSelected: (v) {
                          if (v == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar personaje'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Nombre
              Text(
                character.fullName,
                style: AppTypography.headlineSm.copyWith(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Rol
              Text(
                character.roleLabel,
                style: AppTypography.labelXs.copyWith(
                  color: AppColors.primaryContainer,
                ),
              ),
              if (character.familyName != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Familia ${character.familyName}',
                  style: AppTypography.labelXs,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),

              // Motivación o personalidad (lo primero que haya)
              Expanded(
                child: Text(
                  character.motivations ??
                      character.personality ??
                      character.backstory ??
                      'Sin descripción todavía.',
                  style: AppTypography.uiBodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Character character;

  const _Avatar({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadii.allMd,
      ),
      alignment: Alignment.center,
      child: Text(
        character.initial,
        style: AppTypography.headlineMd.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
