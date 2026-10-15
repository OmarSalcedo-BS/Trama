import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/constants/character_roles.dart';
import '../../domain/models/character.dart';
import '../providers/character_providers.dart';

class CharacterFormScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String? characterId; // null = crear, no null = editar

  const CharacterFormScreen({
    super.key,
    required this.projectId,
    this.characterId,
  });

  bool get isEditing => characterId != null;

  @override
  ConsumerState<CharacterFormScreen> createState() =>
      _CharacterFormScreenState();
}

class _CharacterFormScreenState extends ConsumerState<CharacterFormScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _familyController = TextEditingController();
  final _lineageController = TextEditingController();
  final _ageController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _personalityController = TextEditingController();
  final _motivationsController = TextEditingController();
  final _backstoryController = TextEditingController();
  final _arcController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedRole;
  String? _errorMessage;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _familyController.dispose();
    _lineageController.dispose();
    _ageController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _motivationsController.dispose();
    _backstoryController.dispose();
    _arcController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Rellena los controllers cuando carga el personaje en modo edición.
  void _prefill(Character character) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = character.name;
    _surnameController.text = character.surname ?? '';
    _familyController.text = character.familyName ?? '';
    _lineageController.text = character.lineageNotes ?? '';
    _ageController.text = character.age ?? '';
    _appearanceController.text = character.appearance ?? '';
    _personalityController.text = character.personality ?? '';
    _motivationsController.text = character.motivations ?? '';
    _backstoryController.text = character.backstory ?? '';
    _arcController.text = character.arc ?? '';
    _notesController.text = character.notes ?? '';
    _selectedRole = CharacterRoles.fromDbCode(character.role);
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'El nombre es obligatorio.');
      return;
    }
    if (_surnameController.text.trim().length > 80 ||
        _familyController.text.trim().length > 120) {
      setState(() => _errorMessage =
          'El apellido y la familia no pueden superar el límite permitido.');
      return;
    }
    if (name.length > 80) {
      setState(() => _errorMessage =
          'El nombre no puede superar 80 caracteres.');
      return;
    }

    final controller = ref.read(charactersControllerProvider.notifier);
    final roleCode = CharacterRoles.toDbCode(_selectedRole);

    bool success;
    if (widget.isEditing) {
      final existing = await ref.read(
        characterByIdProvider(widget.characterId!).future,
      );
      if (existing == null) {
        setState(() => _errorMessage = 'No se encontró el personaje.');
        return;
      }
      success = await controller.update(
        existing.copyWith(
          name: name,
          surname: _surnameController.text.trim(),
          familyName: _familyController.text.trim(),
          lineageNotes: _lineageController.text.trim(),
          role: roleCode,
          age: _ageController.text.trim(),
          appearance: _appearanceController.text.trim(),
          personality: _personalityController.text.trim(),
          motivations: _motivationsController.text.trim(),
          backstory: _backstoryController.text.trim(),
          arc: _arcController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );
    } else {
      success = await controller.create(
        projectId: widget.projectId,
        name: name,
        surname: _surnameController.text.trim(),
        familyName: _familyController.text.trim(),
        lineageNotes: _lineageController.text.trim(),
        role: roleCode,
        age: _ageController.text.trim(),
        appearance: _appearanceController.text.trim(),
        personality: _personalityController.text.trim(),
        motivations: _motivationsController.text.trim(),
        backstory: _backstoryController.text.trim(),
        arc: _arcController.text.trim(),
        notes: _notesController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      final state = ref.read(charactersControllerProvider);
      state.whenOrNull(
        error: (e, _) => setState(() => _errorMessage = e.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    final isWide = MediaQuery.of(context).size.width > 900;

    // En modo edición, precargar datos del personaje
    if (isEditing) {
      final async = ref.watch(characterByIdProvider(widget.characterId!));
      async.whenData((c) {
        if (c != null) _prefill(c);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _FormTopBar(
            title: isEditing ? 'Editar personaje' : 'Nuevo personaje',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: isWide
                      ? _buildWideLayout()
                      : _buildNarrowLayout(),
                ),
              ),
            ),
          ),
          _FormBottomBar(
            isEditing: isEditing,
            onSubmit: _submit,
            onCancel: () => context.pop(),
            errorMessage: _errorMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Field(label: 'Nombre', controller: _nameController, autofocus: true),
              const SizedBox(height: AppSpacing.md),
              _Field(label: 'Apellido(s)', controller: _surnameController),
              const SizedBox(height: AppSpacing.md),
              _Field(label: 'Familia o linaje', controller: _familyController),
              const SizedBox(height: AppSpacing.md),
              _Field(label: 'Edad', controller: _ageController),
              const SizedBox(height: AppSpacing.md),
              _RoleSelector(
                value: _selectedRole,
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Field(
                label: 'Apariencia',
                controller: _appearanceController,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                label: 'Personalidad',
                controller: _personalityController,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                label: 'Motivaciones',
                controller: _motivationsController,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                label: 'Trasfondo',
                controller: _backstoryController,
                maxLines: 6,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                label: 'Arco narrativo',
                controller: _arcController,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                label: 'Historia familiar y linaje',
                controller: _lineageController,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                label: 'Notas',
                controller: _notesController,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(label: 'Nombre', controller: _nameController, autofocus: true),
        const SizedBox(height: AppSpacing.md),
        _Field(label: 'Apellido(s)', controller: _surnameController),
        const SizedBox(height: AppSpacing.md),
        _Field(label: 'Familia o linaje', controller: _familyController),
        const SizedBox(height: AppSpacing.md),
        _Field(label: 'Edad', controller: _ageController),
        const SizedBox(height: AppSpacing.md),
        _RoleSelector(
          value: _selectedRole,
          onChanged: (v) => setState(() => _selectedRole = v),
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(label: 'Apariencia', controller: _appearanceController, maxLines: 4),
        const SizedBox(height: AppSpacing.md),
        _Field(label: 'Personalidad', controller: _personalityController, maxLines: 4),
        const SizedBox(height: AppSpacing.md),
        _Field(label: 'Motivaciones', controller: _motivationsController, maxLines: 4),
        const SizedBox(height: AppSpacing.md),
        _Field(label: 'Trasfondo', controller: _backstoryController, maxLines: 6),
        const SizedBox(height: AppSpacing.md),
        _Field(label: 'Arco narrativo', controller: _arcController, maxLines: 4),
        const SizedBox(height: AppSpacing.md),
        _Field(
          label: 'Historia familiar y linaje',
          controller: _lineageController,
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(label: 'Notas', controller: _notesController, maxLines: 4),
      ],
    );
  }
}

// ============================================
// SUB-WIDGETS
// ============================================
class _FormTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _FormTopBar({required this.title, required this.onBack});

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

class _FormBottomBar extends ConsumerWidget {
  final bool isEditing;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final String? errorMessage;

  const _FormBottomBar({
    required this.isEditing,
    required this.onSubmit,
    required this.onCancel,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(charactersControllerProvider).isLoading;

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
          constraints: const BoxConstraints(maxWidth: 900),
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
                          errorMessage!,
                          style: AppTypography.uiBodySm.copyWith(
                            color: AppColors.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
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
                      label: isEditing ? 'Guardar cambios' : 'Crear personaje',
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool autofocus;

  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          maxLines: maxLines,
          autofocus: autofocus,
          style: AppTypography.uiBodyMd,
          decoration: InputDecoration(
            isDense: maxLines == 1,
          ),
        ),
      ],
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _RoleSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rol', style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
              value: value,
              isExpanded: true,
              hint: Text(
                'Selecciona un rol',
                style: AppTypography.uiBodySm,
              ),
              style: AppTypography.uiBodyMd,
              icon: const Icon(Icons.expand_more, size: 18),
              items: CharacterRoles.all
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}