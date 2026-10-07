import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/section_label.dart';
import '../cards/feature_card.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  static const _features = [
    (
      icon: Icons.menu_book_outlined,
      title: 'Editor de prosa',
      description:
          'Modo enfoque, tipografía literaria refinada, ancho de línea ergonómico y conteo de palabras sin latencia.',
      tag: '01 // Manuscrito',
    ),
    (
      icon: Icons.badge_outlined,
      title: 'Fichas de personajes',
      description:
          'Dossiers psicológicos, arcos dramáticos, evolución a lo largo de los capítulos y seguimiento de apariciones.',
      tag: '02 // Dramatis Personae',
    ),
    (
      icon: Icons.explore_outlined,
      title: 'Fichas de mundo',
      description:
          'Worldbuilding estructurado: atlas, facciones, cosmogonías y sistemas de reglas sin incongruencias.',
      tag: '03 // Lore & Atlas',
    ),
    (
      icon: Icons.timeline_outlined,
      title: 'Cronología',
      description:
          'Líneas de tiempo maestras paralelas. Visualiza qué ocurre en cada frente sin romper la coherencia.',
      tag: '04 // Cronograma',
    ),
    (
      icon: Icons.hub_outlined,
      title: 'Mapa de relaciones',
      description:
          'Grafo sobrio de tensiones, alianzas y lazos familiares. Detecta personajes aislados o tramas desconectadas.',
      tag: '05 // Grafo',
    ),
    (
      icon: Icons.spellcheck_outlined,
      title: 'Enciclopedia interna',
      description:
          'Glosario terminológico con consulta rápida. Definiciones de términos inventados sin perder el foco.',
      tag: '06 // Léxico',
    ),
    (
      icon: Icons.inventory_2_outlined,
      title: 'Cajón de descartes',
      description:
          'Un archivo seguro para párrafos suprimidos e ideas descartadas. Nada se pierde permanentemente.',
      tag: '07 // Archivo',
    ),
    (
      icon: Icons.ios_share_outlined,
      title: 'Exportación completa',
      description:
          'Genera EPUB listo para publicación, PDF con maqueta editorial, DOCX para agentes y Markdown plano.',
      tag: '08 // Imprenta',
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
      color: AppColors.surfaceContainerLowest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Herramientas rigurosas'),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'Todo lo que necesitas para concluir tu manuscrito.',
                  style: AppTypography.headlineLg,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'Diseñado específicamente para literatura de largo aliento. '
                  'Sin distracciones innecesarias, sin gamificación infantil '
                  'y con absoluta precisión técnica.',
                  style: AppTypography.uiBodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Grid de 8 features
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
                    childAspectRatio: 0.82,
                    children: _features
                        .map((f) => FeatureCard(
                              icon: f.icon,
                              title: f.title,
                              description: f.description,
                              tag: f.tag,
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