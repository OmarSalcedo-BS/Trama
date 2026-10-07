import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/section_label.dart';
import '../cards/genre_card.dart';

class GenresSection extends StatelessWidget {
  const GenresSection({super.key});

  static const _genres = [
    (
      badge: 'Worldbuilding',
      title: 'Fantasía épica & Sci-Fi',
      description:
          'Domina enciclopedias complejas, genealogías dinásticas, múltiples sistemas de magia y coordenadas geográficas sin desbordar tu manuscrito.',
      example: 'Ej: Atlas, facciones, lenguajes',
      icon: Icons.auto_stories_outlined,
    ),
    (
      badge: 'Pistas & tiempos',
      title: 'Thriller & Novela negra',
      description:
          'Alinea pistas falsas, testimonios cruzados y coartadas minutadas al segundo con la cronología paralela libre de agujeros.',
      example: 'Ej: Coartadas, líneas temporales',
      icon: Icons.fingerprint_outlined,
    ),
    (
      badge: 'Documentación',
      title: 'Ficción histórica',
      description:
          'Sincroniza eventos verídicos con tu trama ficticia. Mantén notas al pie y fechas históricas vinculadas en un panel lateral.',
      example: 'Ej: Acontecimientos reales',
      icon: Icons.account_balance_outlined,
    ),
    (
      badge: 'Psicología',
      title: 'Intimista & Contemporánea',
      description:
          'Profundiza en la voz, los silencios y los arcos de transformación interior. El modo enfoque te da la intimidad necesaria.',
      example: 'Ej: Evolución emocional, voz',
      icon: Icons.favorite_outline,
    ),
  ];

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
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Flexibilidad temática'),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'Diseñado para la exigencia de cada género.',
                  style: AppTypography.headlineLg,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'Ya sea que manejes dinastías milenarias o la intimidad '
                  'asfixiante de una sola habitación.',
                  style: AppTypography.uiBodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 700
                      ? 1
                      : constraints.maxWidth < 1000
                          ? 2
                          : 4;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.75,
                    children: _genres
                        .map((g) => GenreCard(
                              badge: g.badge,
                              title: g.title,
                              description: g.description,
                              example: g.example,
                              icon: g.icon,
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}