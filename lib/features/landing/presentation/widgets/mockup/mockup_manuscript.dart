import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class MockupManuscript extends StatelessWidget {
  const MockupManuscript({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CAPÍTULO CUARTO', style: AppTypography.labelXs),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'El Refugio Fluvial',
              style: AppTypography.headlineLg,
            ),
            const SizedBox(height: AppSpacing.lg),
            _paragraph(
              'El fango del estuario olía a salmuera y helecho macerado. '
              'Mateo detuvo la barcaza con la pértiga de sauce justo bajo '
              'la sombra del viejo dique. El agua apenas se movía, densa '
              'como pez fría, reflejando el cielo plomizo de las cuatro '
              'de la tarde.',
            ),
            _paragraph(
              '—Si dejamos la carga aquí —dijo Alden, frotándose los '
              'nudillos marcados por la humedad—, la marea la habrá '
              'tapado antes de la medianoche. Nadie cruza el canal con '
              'este viento del este.',
            ),
            _paragraph(
              'Mateo no respondió de inmediato. Pasó los dedos sobre el '
              'estuche lacado que descansaba en la sentina. Aquel sello '
              'de cera negra no debía romperse; era la única moneda de '
              'cambio que le quedaba frente al tribunal de la comarca.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        text,
        style: AppTypography.manuscriptLg,
        textAlign: TextAlign.justify,
      ),
    );
  }
}