import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class MockupInspector extends StatelessWidget {
  const MockupInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FICHA ACTIVA: PERSONAJE', style: AppTypography.labelXs),
          const SizedBox(height: AppSpacing.md),

          // Avatar + nombre
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text('A', style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onPrimary,
                  )),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alden Vane', style: AppTypography.headlineSm),
                    Text('Coprotagonista · Barquero',
                        style: AppTypography.labelXs),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Motivación
          Text('MOTIVACIÓN', style: AppTypography.labelXs),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Saldar su deuda fluvial antes del deshielo. '
              'Desconfía del tribunal.',
              style: AppTypography.labelXs.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Vínculos
          Text('VÍNCULOS EN ESCENA', style: AppTypography.labelXs),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 4, runSpacing: 4,
            children: const [
              _Tag('Mateo'),
              _Tag('Dique Norte'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: AppTypography.labelXs.copyWith(
        color: AppColors.onSurface,
      )),
    );
  }
}