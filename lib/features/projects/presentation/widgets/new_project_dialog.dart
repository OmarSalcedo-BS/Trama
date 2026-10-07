import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/constants/project_genres.dart';
import '../providers/project_providers.dart';

class NewProjectDialog extends ConsumerStatefulWidget {
  const NewProjectDialog({super.key});

  /// Helper para abrir el diálogo desde cualquier parte.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NewProjectDialog(),
    );
  }

  @override
  ConsumerState<NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends ConsumerState<NewProjectDialog> {
  final _titleController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _customGenreController = TextEditingController();

  String? _selectedGenre;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    _customGenreController.dispose();
    super.dispose();
  }

  bool get _isCreating =>
      ref.watch(projectsControllerProvider).isLoading;

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'El título es obligatorio.');
      return;
    }
    if (title.length > 120) {
      setState(() =>
          _errorMessage = 'El título no puede superar 120 caracteres.');
      return;
    }

    // Género: si es "Otro" y hay texto, usamos ese texto.
    String? genre = _selectedGenre;
    if (_selectedGenre == ProjectGenres.other) {
      final custom = _customGenreController.text.trim();
      genre = custom.isEmpty ? ProjectGenres.other : custom;
    }

    final synopsis = _synopsisController.text.trim();

    final success = await ref
        .read(projectsControllerProvider.notifier)
        .create(
          title: title,
          synopsis: synopsis.isEmpty ? null : synopsis,
          genre: genre,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final state = ref.read(projectsControllerProvider);
      state.whenOrNull(
        error: (e, _) => setState(() => _errorMessage = e.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.allLg),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isNarrow ? AppSpacing.lg : AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nuevo proyecto',
                      style: AppTypography.headlineMd,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isCreating
                        ? null
                        : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Puedes cambiar estos datos más adelante.',
                style: AppTypography.uiBodySm,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Título
              _Label('Título'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _titleController,
                autofocus: true,
                style: AppTypography.uiBodyMd,
                decoration: const InputDecoration(
                  hintText: 'La casa del cenagal',
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),

              // Sinopsis
              _Label('Sinopsis (opcional)'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _synopsisController,
                maxLines: 4,
                style: AppTypography.uiBodyMd,
                decoration: const InputDecoration(
                  hintText:
                      'Un barquero debe entregar un estuche lacado antes '
                      'del deshielo...',
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Género
              _Label('Género (opcional)'),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.allMd,
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGenre,
                    isExpanded: true,
                    hint: Text(
                      'Selecciona un género',
                      style: AppTypography.uiBodySm,
                    ),
                    style: AppTypography.uiBodyMd,
                    icon: const Icon(Icons.expand_more, size: 18),
                    items: ProjectGenres.all
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g),
                            ))
                        .toList(),
                    onChanged: _isCreating
                        ? null
                        : (value) =>
                            setState(() => _selectedGenre = value),
                  ),
                ),
              ),

              // Campo extra si eligen "Otro"
              if (_selectedGenre == ProjectGenres.other) ...[
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _customGenreController,
                  style: AppTypography.uiBodyMd,
                  decoration: const InputDecoration(
                    hintText: 'Especifica el género',
                  ),
                ),
              ],

              // Error
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: AppRadii.allMd,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.uiBodySm.copyWith(
                            color: AppColors.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Acciones
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancelar',
                      onPressed: _isCreating
                          ? null
                          : () => Navigator.of(context).pop(false),
                      fullWidth: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _isCreating
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          )
                        : PrimaryButton(
                            label: 'Crear proyecto',
                            icon: Icons.add,
                            onPressed: _submit,
                            fullWidth: true,
                          ),
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.labelMd);
  }
}