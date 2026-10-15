import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../constants/world_colors.dart';
import '../../constants/world_icons.dart';
import '../../domain/models/world_category.dart';
import '../providers/world_category_providers.dart';

class WorldCategoryFormScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String? categoryId;

  const WorldCategoryFormScreen({
    super.key,
    required this.projectId,
    this.categoryId,
  });

  bool get isEditing => categoryId != null;

  @override
  ConsumerState<WorldCategoryFormScreen> createState() =>
      _WorldCategoryFormScreenState();
}

class _WorldCategoryFormScreenState
    extends ConsumerState<WorldCategoryFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIcon = WorldIcons.defaultCode;
  String _selectedColor = WorldColors.defaultCode;
  String? _errorMessage;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _prefill(WorldCategory category) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = category.name;
    _descriptionController.text = category.description ?? '';
    _selectedIcon = category.icon;
    _selectedColor = category.color;
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'El nombre es obligatorio.');
      return;
    }
    if (name.length > 60) {
      setState(() => _errorMessage =
          'El nombre no puede superar 60 caracteres.');
      return;
    }

    final controller =
        ref.read(worldCategoriesControllerProvider.notifier);

    bool success;
    if (widget.isEditing) {
      final existing = await ref.read(
        worldCategoryByIdProvider(widget.categoryId!).future,
      );
      if (existing == null) {
        setState(() => _errorMessage = 'No se encontró la categoría.');
        return;
      }
      success = await controller.update(
        existing.copyWith(
          name: name,
          description: _descriptionController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
        ),
      );
    } else {
      success = await controller.create(
        projectId: widget.projectId,
        name: name,
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
      );
    }

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      final state = ref.read(worldCategoriesControllerProvider);
      state.whenOrNull(
        error: (e, _) => setState(() => _errorMessage = e.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final async = ref.watch(
        worldCategoryByIdProvider(widget.categoryId!),
      );
      async.whenData((c) {
        if (c != null) _prefill(c);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _TopBar(
            title: widget.isEditing
                ? 'Editar categoría'
                : 'Nueva categoría',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Label('Nombre'),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        style: AppTypography.uiBodyMd,
                        decoration: const InputDecoration(
                          hintText: 'Lugares, Facciones, Magia, Tecnología...',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _Label('Descripción (opcional)'),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: AppTypography.uiBodyMd,
                        decoration: const InputDecoration(
                          hintText: 'Qué tipo de fichas irán en esta categoría.',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _Label('Icono'),
                      const SizedBox(height: AppSpacing.sm),
                      _IconPicker(
                        selected: _selectedIcon,
                        accentColor: WorldColors.getColor(_selectedColor),
                        onSelected: (code) =>
                            setState(() => _selectedIcon = code),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _Label('Color'),
                      const SizedBox(height: AppSpacing.sm),
                      _ColorPicker(
                        selected: _selectedColor,
                        onSelected: (code) =>
                            setState(() => _selectedColor = code),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Vista previa
                      _Label('Vista previa'),
                      const SizedBox(height: AppSpacing.sm),
                      _Preview(
                        iconCode: _selectedIcon,
                        colorCode: _selectedColor,
                        name: _nameController.text.isEmpty
                            ? 'Nombre de la categoría'
                            : _nameController.text,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _BottomBar(
            isEditing: widget.isEditing,
            onSubmit: _submit,
            onCancel: () => context.pop(),
            errorMessage: _errorMessage,
          ),
        ],
      ),
    );
  }
}

// ============================================
// SUB-WIDGETS
// ============================================
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: AppTypography.headlineSm),
        ],
      ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  final bool isEditing;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final String? errorMessage;

  const _BottomBar({
    required this.isEditing,
    required this.onSubmit,
    required this.onCancel,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(worldCategoriesControllerProvider).isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: AppRadii.allMd,
                  ),
                  child: Text(
                    errorMessage!,
                    style: AppTypography.uiBodySm.copyWith(
                      color: AppColors.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    label: 'Cancelar',
                    onPressed: isLoading ? null : onCancel,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    )
                  else
                    PrimaryButton(
                      label: isEditing ? 'Guardar' : 'Crear categoría',
                      icon: isEditing ? Icons.check : Icons.add,
                      onPressed: onSubmit,
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

class _IconPicker extends StatelessWidget {
  final String selected;
  final Color accentColor;
  final ValueChanged<String> onSelected;

  const _IconPicker({
    required this.selected,
    required this.accentColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.allMd,
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 0.5,
        ),
      ),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: WorldIcons.allCodes.map((code) {
            final isSelected = code == selected;
            final icon = WorldIcons.getIcon(code);
            return InkWell(
              onTap: () => onSelected(code),
              borderRadius: AppRadii.allMd,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: AppRadii.allMd,
                  border: isSelected
                      ? Border.all(color: accentColor, width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? accentColor
                      : AppColors.onSurfaceVariant,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _ColorPicker({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: WorldColors.allCodes.map((code) {
        final color = WorldColors.getColor(code);
        final isSelected = code == selected;
        return Tooltip(
          message: WorldColors.getLabel(code),
          child: InkWell(
            onTap: () => onSelected(code),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: AppColors.onSurface,
                        width: 2,
                      )
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Preview extends StatelessWidget {
  final String iconCode;
  final String colorCode;
  final String name;

  const _Preview({
    required this.iconCode,
    required this.colorCode,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final accent = WorldColors.getColor(colorCode);
    final icon = WorldIcons.getIcon(iconCode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadii.allMd,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: AppRadii.allSm,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            name,
            style: AppTypography.uiBodyMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
          Text('0 fichas', style: AppTypography.labelXs),
        ],
      ),
    );
  }
}