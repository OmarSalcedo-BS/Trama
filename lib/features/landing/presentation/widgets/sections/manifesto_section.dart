import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/section_label.dart';
import '../cards/principle_card.dart';

class ManifestoSection extends StatelessWidget {
  const ManifestoSection({super.key});

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
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadii.allLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Principios irrenunciables'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Un pacto honesto con quien escribe.',
                  style: AppTypography.headlineLg,
                ),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Text(
                    'Trama no es un producto para extraer datos ni una '
                    'herramienta que se sostiene a costa de sus usuarios. '
                    'Es un proyecto pequeño que respeta su oficio.',
                    style: AppTypography.manuscriptMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 800;
                    final cards = const [
                      PrincipleCard(
                        icon: Icons.money_off_outlined,
                        title: 'Núcleo siempre gratis',
                        description:
                            'Escribir, organizar y exportar tu novela no '
                            'tendrá coste. Sin muros de pago para leer tu '
                            'propio manuscrito.',
                      ),
                      PrincipleCard(
                        icon: Icons.block_outlined,
                        title: 'Cero inteligencia artificial',
                        description:
                            'No hay asistentes de reescritura, ni '
                            'autocompletado artificial, ni rastreadores. '
                            'Tu prosa jamás entrenará modelos de lenguaje.',
                      ),
                      PrincipleCard(
                        icon: Icons.storage_outlined,
                        title: 'Soberanía de datos',
                        description:
                            'Tus borradores son tuyos y exportables en '
                            'formatos abiertos. Si te marchas, te llevas '
                            'todo contigo con un clic.',
                      ),
                    ];

                    if (isNarrow) {
                      return Column(
                        children: cards
                            .map((c) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  child: c,
                                ))
                            .toList(),
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cards
                          .map((c) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.md,
                                  ),
                                  child: c,
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}