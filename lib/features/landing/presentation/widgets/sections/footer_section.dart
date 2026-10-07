import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  static int getYear() {
    final now = DateTime.now();
    return now.year;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.xxl,
      ),
      color: AppColors.surfaceContainerLow,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppRadii.allSm,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'T',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(AppConstants.appName, style: AppTypography.headlineSm),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '· El estudio personal del novelista',
                    style: AppTypography.labelXs,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 0.5, color: AppColors.outlineVariant),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Trama no recopila tus manuscritos para alimentar ninguna IA. '
                      'Es una herramienta para escritores. Hecho por y para autores.',
                      style: AppTypography.labelXs,
                    ),
                  ),
                  Text(
                    'Versión ${AppConstants.version} · ${FooterSection.getYear()} © Trama',
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
}