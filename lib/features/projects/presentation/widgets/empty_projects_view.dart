import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';

class EmptyProjectsView extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyProjectsView({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.allLg,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.menu_book_outlined,
                  size: 28,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Aún no tienes proyectos',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Crea tu primer proyecto para empezar a escribir, '
                'organizar personajes y construir tu mundo.',
                textAlign: TextAlign.center,
                style: AppTypography.manuscriptMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Crear mi primer proyecto',
                icon: Icons.add,
                onPressed: onCreate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}