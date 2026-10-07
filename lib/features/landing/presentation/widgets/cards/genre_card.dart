import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class GenreCard extends StatelessWidget {
  final String badge;
  final String title;
  final String description;
  final String example;
  final IconData icon;

  const GenreCard({
    super.key,
    required this.badge,
    required this.title,
    required this.description,
    required this.example,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.allMd,
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadii.allSm,
                ),
                child: Text(
                  badge,
                  style: AppTypography.labelXs.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, size: 18, color: AppColors.tertiaryContainer),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.headlineMd),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Text(
              description,
              style: AppTypography.uiBodySm.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(example, style: AppTypography.labelXs),
        ],
      ),
    );
  }
}