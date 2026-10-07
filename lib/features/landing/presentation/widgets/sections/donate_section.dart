import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class DonateSection extends StatelessWidget {
  const DonateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.xxl,
      ),
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.coffee_outlined,
                  size: 24,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Un proyecto sostenido por quien lo usa',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Trama no tiene inversores ni planes de crecer a costa de '
                'sus usuarios. Se sostiene con donaciones voluntarias de '
                'quienes lo encuentran útil y quieren que siga existiendo. '
                'Si no puedes o no quieres aportar, la herramienta sigue '
                'siendo completamente funcional para ti.',
                textAlign: TextAlign.center,
                style: AppTypography.manuscriptMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  _DonationButton(
                    icon: Icons.favorite_outline,
                    label: 'Invitar a un café',
                    onPressed: () {},
                  ),
                  _DonationButton(
                    icon: Icons.code_outlined,
                    label: 'Patrocinar en GitHub',
                    onPressed: () {},
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

class _DonationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _DonationButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: AppRadii.allMd,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.allMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.tertiaryContainer),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.uiBodySm.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}