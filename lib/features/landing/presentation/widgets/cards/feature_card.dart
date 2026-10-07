import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String tag;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.allMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadii.allMd,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: AppColors.primaryContainer),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.headlineSm),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Text(
              description,
              style: AppTypography.uiBodySm.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            tag,
            style: AppTypography.labelXs.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}