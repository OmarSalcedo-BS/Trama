import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';

class EmptyCharactersView extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyCharactersView({super.key, required this.onCreate});

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
                  Icons.people_outline,
                  size: 28,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Aún no hay personajes',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Crea fichas para tus personajes con su rol, motivaciones, '
                'personalidad y arco narrativo.',
                textAlign: TextAlign.center,
                style: AppTypography.manuscriptMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Crear primer personaje',
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