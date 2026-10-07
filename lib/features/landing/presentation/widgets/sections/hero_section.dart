import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/secondary_button.dart';
import '../cards/stat_card.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback? onStartPressed;
  final VoidCallback? onSeeMorePressed;

  const HeroSection({
    super.key,
    this.onStartPressed,
    this.onSeeMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? AppSpacing.marginMobile : AppSpacing.margin,
        vertical: AppSpacing.huge,
      ),
      color: AppColors.surfaceContainerLowest,
      child: Column(
        children: [
          // Badge superior
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.outlineVariant, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'GRATIS Y SIN LÍMITES · TUS DATOS TE PERTENECEN',
                  style: AppTypography.labelXs.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Título
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Text(
              AppConstants.appTagline,
              textAlign: TextAlign.center,
              style: isNarrow
                  ? AppTypography.headlineXlMobile
                  : AppTypography.headlineXl,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Subtítulo
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              AppConstants.appDescription,
              textAlign: TextAlign.center,
              style: AppTypography.manuscriptMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // CTAs
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              PrimaryButton(
                label: 'Empezar gratis',
                icon: Icons.edit_outlined,
                onPressed: onStartPressed,
              ),
              SecondaryButton(
                label: 'Ver cómo funciona',
                icon: Icons.play_circle_outline,
                onPressed: onSeeMorePressed,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Fila de stats (4 tarjetas)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 700 ? 2 : 4;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.6,
                  children: const [
                    StatCard(
                      label: 'NÚCLEO',
                      value: 'Crea sin límites',
                      description: 'Por ahora el proyecto busca ser un núcleo de escritura, hecho para escritores. No debería ser un abuso de costes liberar tu creatividad.',
                    ),
                    StatCard(
                      label: 'SOSTENIBILIDAD',
                      value: 'Donaciones voluntarias',
                      description: 'El proyecto vive gracias a la comunidad, ideado para algunas ventajas estéticas o analíticas, pero no para monetizar tus datos',
                    ),
                    StatCard(
                      label: 'ÉTICA DE AUTOR',
                      value: 'Cero I.A.',
                      description: 'Tu prosa no entrena algoritmos, y tu historia no se comparte con nadie.',
                    ),
                    StatCard(
                      label: 'PORTABILIDAD',
                      value: 'Formatos abiertos',
                      description: 'Exportación en un clic',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}