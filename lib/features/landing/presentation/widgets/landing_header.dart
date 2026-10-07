import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class LandingHeader extends StatelessWidget {
  final VoidCallback? onStartPressed;
  final VoidCallback? onFeaturesPressed;
  final VoidCallback? onGenresPressed;
  final VoidCallback? onManifestoPressed;
  final VoidCallback? onDonatePressed;

  const LandingHeader({
    super.key,
    this.onStartPressed,
    this.onFeaturesPressed,
    this.onGenresPressed,
    this.onManifestoPressed,
    this.onDonatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadii.allSm,
                ),
                alignment: Alignment.center,
                child: Text(
                  'T',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppConstants.appName,
                style: AppTypography.headlineSm.copyWith(
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(width: AppSpacing.xxl),

          // Navegación (solo escritorio)
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              child: Row(
                children: [
                  _NavLink(
                    label: 'Funcionalidades',
                    onTap: onFeaturesPressed,
                  ),
                  _NavLink(label: 'Géneros', onTap: onGenresPressed),
                  _NavLink(label: 'Manifiesto', onTap: onManifestoPressed),
                  _NavLink(label: 'Apoyar', onTap: onDonatePressed),
                ],
              ),
            )
          else
            const Spacer(),

          // Acciones
          Text(
            AppConstants.version,
            style: AppTypography.labelXs,
          ),
          const SizedBox(width: AppSpacing.md),
          _StartButton(onPressed: onStartPressed),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _NavLink({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: AppTypography.uiBodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _StartButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryContainer,
      borderRadius: AppRadii.allMd,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.allMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            'Empezar gratis',
            style: AppTypography.uiBodySm.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}