import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../providers/auth_providers.dart';

/// Pantalla de acceso exclusivo para la versión Alpha limitada.
/// En lugar de registro abierto o login con contraseña, requiere un correo
/// y su correspondiente código de prueba asignado por el administrador.
class AlphaAccessScreen extends ConsumerStatefulWidget {
  const AlphaAccessScreen({super.key});

  @override
  ConsumerState<AlphaAccessScreen> createState() => _AlphaAccessScreenState();
}

class _AlphaAccessScreenState extends ConsumerState<AlphaAccessScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).isLoading) return;
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim().toLowerCase();
    final code = _codeController.text.trim().toUpperCase();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Introduce un email válido.');
      return;
    }
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Introduce tu código de prueba.');
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);
    final supabase = ref.read(supabaseClientProvider);

    // 1. Intentar inicio de sesión directo (para usuarios ya registrados con su código)
    var success = await controller.signIn(email: email, password: code);

    // 2. Si falla el login, verificar si el código existe en 'alpha_invitations' para primer acceso
    if (!success) {
      try {
        final invite = await supabase
            .from('alpha_invitations')
            .select()
            .eq('code', code)
            .maybeSingle();

        if (invite != null) {
          final isClaimed = invite['is_claimed'] as bool? ?? false;
          final assignedEmail = (invite['email'] as String?)?.trim().toLowerCase();

          // Si el código ya fue reclamado
          if (isClaimed) {
            if (!mounted) return;
            setState(() => _errorMessage =
                'Este código ya fue utilizado. Solicita un código nuevo.');
            return;
          }

          // Si el código fue preasignado a otro correo específico
          if (assignedEmail != null && assignedEmail.isNotEmpty && assignedEmail != email) {
            if (!mounted) return;
            setState(() => _errorMessage =
                'Este código no corresponde a este correo. Contacta al administrador.');
            return;
          }

          // Registrar por primera vez al usuario con su código como contraseña
          final defaultName = email.split('@').first;
          final signUpSuccess = await controller.signUp(
            email: email,
            password: code,
            displayName: defaultName,
          );

          if (signUpSuccess) {
            await supabase
                .from('alpha_invitations')
                .update({
                  'email': email,
                  'is_claimed': true,
                  'claimed_at': DateTime.now().toIso8601String(),
                })
                .eq('id', invite['id']);
            success = true;
          }
        }
      } catch (_) {
        // Si la tabla no existe o hay error de consulta, se mantiene el flujo estándar
      }
    }

    if (!mounted) return;

    if (success) {
      context.go('/dashboard');
    } else {
      final state = ref.read(authControllerProvider);
      state.whenOrNull(
        error: (e, _) {
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('invalid login') ||
              errorStr.contains('incorrectos') ||
              errorStr.contains('credenciales')) {
            setState(() => _errorMessage =
                'Código de prueba no válido para este correo. Verifica que el correo y el código coincidan.');
          } else {
            setState(() => _errorMessage = e.toString());
          }
        },
      );
      if (_errorMessage == null) {
        setState(() => _errorMessage =
            'Código de prueba no válido para este correo. Verifica que el correo y el código coincidan.');
      }
    }
  }

  void _showRequestCodeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.allLg),
        title: Row(
          children: [
            const Icon(Icons.mark_email_read_outlined,
                color: AppColors.primaryContainer),
            const SizedBox(width: AppSpacing.sm),
            Text('Solicitar acceso Alpha', style: AppTypography.headlineSm),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La versión Alpha de Trama está restringida a escritores y lectores de prueba.',
              style: AppTypography.uiBodyMd,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Para solicitar tu código personalizado, escribe a:',
              style: AppTypography.uiBodySm,
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadii.allSm,
                border: Border.all(color: AppColors.outlineVariant, width: 0.5),
              ),
              child: SelectableText(
                AppConfig.alphaContactEmail,
                style: AppTypography.uiBodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryContainer,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Indica tu nombre y el tipo de historia o manuscrito que deseas trabajar. Te responderemos con tu código único.',
              style: AppTypography.uiBodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
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
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppRadii.allLg,
                border: Border.all(
                  color: AppColors.outlineVariant,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo + Badge de Alpha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
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
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: AppRadii.allSm,
                        ),
                        child: Text(
                          'ALPHA LIMITADA',
                          style: AppTypography.uiBodySm.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.onPrimaryFixed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Acceso con código de prueba',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSm,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Introduce el correo con el que solicitaste tu acceso y el código que te hemos proporcionado.',
                    textAlign: TextAlign.center,
                    style: AppTypography.uiBodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Caja explicativa
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: AppRadii.allMd,
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 20,
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Cada código es personal y está vinculado a tu correo. Tu perfil y proyectos estarán protegidos y aislados.',
                            style: AppTypography.uiBodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Campo Correo
                  _AlphaTextField(
                    controller: _emailController,
                    label: 'Correo electrónico autorizado',
                    hint: 'ejemplo@correo.com',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Campo Código
                  _AlphaTextField(
                    controller: _codeController,
                    label: 'Código de prueba',
                    hint: 'TRAMA-XXXX-XXXX',
                    icon: Icons.key_outlined,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    textCapitalization: TextCapitalization.characters,
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
                          label: 'Entrar a la versión Alpha',
                          icon: Icons.arrow_forward_outlined,
                          onPressed: _submit,
                          fullWidth: true,
                        ),

                  const SizedBox(height: AppSpacing.md),

                  // Solicitar código
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.allMd,
                      ),
                      side: const BorderSide(
                        color: AppColors.outlineVariant,
                        width: 0.8,
                      ),
                    ),
                    onPressed: _showRequestCodeDialog,
                    icon: const Icon(
                      Icons.help_outline,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    label: Text(
                      '¿No tienes un código? Solicítalo aquí',
                      style: AppTypography.uiBodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Volver a la landing
                  SecondaryButton(
                    label: 'Volver a la portada',
                    icon: Icons.home_outlined,
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

class _AlphaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;

  const _AlphaTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
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
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onSubmitted: onSubmitted,
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
