import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class MockupSidebar extends StatelessWidget {
  const MockupSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ESTRUCTURA DE LA OBRA', style: AppTypography.labelXs),
          const SizedBox(height: AppSpacing.md),
          _chapter('Acto I: Las nieblas bajas', '8,410', false),
          _chapter('Cap. IV: El Refugio Fluvial', '3,120', true),
          _chapter('Cap. V: Juramento de Cera', '4,200', false),
          _chapter('Acto II: La marea negra', '19,090', false),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Text('Objetivo diario', style: AppTypography.labelXs),
                const Spacer(),
                Text('82%', style: AppTypography.labelXs.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chapter(String title, String words, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          if (active) ...[
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.uiBodySm.copyWith(
                color: active
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
                fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(words, style: AppTypography.labelXs.copyWith(
            color: AppColors.outline,
            fontFamily: 'monospace',
          )),
        ],
      ),
    );
  }
}