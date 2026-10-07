import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class MockupWindowBar extends StatelessWidget {
  const MockupWindowBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          _dot(), const SizedBox(width: 6),
          _dot(), const SizedBox(width: 6),
          _dot(),
          const SizedBox(width: AppSpacing.md),
          Text(
            'trama // la-casa-del-cenagal.trama',
            style: AppTypography.labelXs.copyWith(
              fontFamily: 'monospace',
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text('34,820 palabras', style: AppTypography.labelXs),
          const SizedBox(width: AppSpacing.md),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('Guardado automático', style: AppTypography.labelXs),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
    width: 10, height: 10,
    decoration: const BoxDecoration(
      color: AppColors.outlineVariant,
      shape: BoxShape.circle,
    ),
  );
}