import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class FinalCtaSection extends StatelessWidget {
  final VoidCallback? onStartPressed;

  const FinalCtaSection({super.key, this.onStartPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.xxl,
      ),
      color: AppColors.surfaceContainerLowest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.inverseSurface,
              borderRadius: AppRadii.allLg,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;
                final textBlock = Column(
                  crossAxisAlignment: isNarrow
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu primer capítulo te está esperando.',
                      textAlign: isNarrow ? TextAlign.center : TextAlign.left,
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Abre Trama ahora mismo en tu navegador. '
                      'Sin tarjetas, sin descargas, sin compromisos.',
                      textAlign: isNarrow ? TextAlign.center : TextAlign.left,
                      style: AppTypography.uiBodyMd.copyWith(
                        color: AppColors.inverseOnSurface,
                      ),
                    ),
                  ],
                );

                final buttonBlock = _CtaButton(onPressed: onStartPressed);

                if (isNarrow) {
                  return Column(
                    children: [
                      textBlock,
                      const SizedBox(height: AppSpacing.lg),
                      buttonBlock,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: textBlock),
                    const SizedBox(width: AppSpacing.lg),
                    buttonBlock,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _CtaButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryContainer,
      borderRadius: AppRadii.allMd,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.allMd,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          child: Text(
            'Empezar a escribir gratis',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}