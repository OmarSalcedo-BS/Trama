import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../providers/auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Introduce un email válido.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage =
          'La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);
    final success = _isSignUp
        ? await controller.signUp(
            email: email,
            password: password,
            displayName: displayName.isEmpty ? null : displayName,
          )
        : await controller.signIn(email: email, password: password);

    if (!mounted) return;

    if (success) {
      context.go('/dashboard');
    } else {
      final state = ref.read(authControllerProvider);
      state.whenOrNull(
        error: (e, _) {
          setState(() => _errorMessage = e.toString());
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppRadii.allLg,
                border: Border.all(
                  color: AppColors.outlineVariant,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppRadii.allSm,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'T',
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Trama', style: AppTypography.headlineMd),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    _isSignUp
                        ? 'Crea tu cuenta para empezar'
                        : 'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSm,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _isSignUp
                        ? 'Gratis, sin tarjeta. Tus textos son tuyos.'
                        : 'Tu manuscrito te espera donde lo dejaste.',
                    textAlign: TextAlign.center,
                    style: AppTypography.uiBodySm,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: AppRadii.allMd,
                    ),
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Registro',
                          active: _isSignUp,
                          onTap: () => setState(() => _isSignUp = true),
                        ),
                        _TabButton(
                          label: 'Iniciar sesión',
                          active: !_isSignUp,
                          onTap: () => setState(() => _isSignUp = false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Formulario
                  if (_isSignUp) ...[
                    _TextField(
                      controller: _displayNameController,
                      label: 'Nombre (opcional)',
                      hint: 'Cómo quieres que te llamemos',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _TextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'tu@email.com',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    hint: 'Mínimo 6 caracteres',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  // Mensaje de error
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

                  const SizedBox(height: AppSpacing.lg),

                  // Botón principal
                  isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        )
                      : PrimaryButton(
                          label: _isSignUp
                              ? 'Crear cuenta'
                              : 'Iniciar sesión',
                          icon: _isSignUp
                              ? Icons.person_add_outlined
                              : Icons.login_outlined,
                          onPressed: _submit,
                          fullWidth: true,
                        ),

                  const SizedBox(height: AppSpacing.md),

                  // Volver a la landing
                  SecondaryButton(
                    label: 'Volver al inicio',
                    icon: Icons.arrow_back_outlined,
                    onPressed: () => context.go('/'),
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: active
            ? AppColors.surfaceContainerLowest
            : Colors.transparent,
        borderRadius: AppRadii.allSm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.allSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.uiBodySm.copyWith(
                color: active
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
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
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTypography.uiBodyMd,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18),
          ),
        ),
      ],
    );
  }
}