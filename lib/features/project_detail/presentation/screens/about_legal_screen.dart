import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Pantalla completa de información legal, propiedad intelectual,
/// tratamiento de datos (RGPD), uso de cookies, caché y permisos.
class AboutLegalScreen extends StatelessWidget {
  final String projectId;

  const AboutLegalScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabecera institucional
                const _AboutHeader(),
                const SizedBox(height: AppSpacing.xl),

                // Resumen rápido de principios
                const _HighlightsRow(),
                const SizedBox(height: AppSpacing.xl),

                // 1. Propiedad Intelectual de la App y de los Autores
                const _LegalCard(
                  icon: Icons.shield_outlined,
                  title: '1. Propiedad Intelectual y Autoría',
                  badge: 'Garantía 100% de Autor',
                  badgeColor: AppColors.primaryContainer,
                  children: [
                    _Paragraph(
                      title: 'Propiedad de la Plataforma:',
                      content:
                          'Trama, su código fuente, arquitectura, diseño visual, '
                          'logotipos, marcas, algoritmos e interfaz de usuario son '
                          'propiedad intelectual exclusiva de su autor y desarrollador original. '
                          'Queda estrictamente prohibida su copia, distribución no autorizada, '
                          'ingeniería inversa o explotación comercial sin consentimiento previo y por escrito.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _Paragraph(
                      title: 'Derechos Inalienables del Escritor / Usuario:',
                      content:
                          'Tú eres y serás siempre el único y absoluto propietario de todo lo que escribas. '
                          'Todas las novelas, capítulos, sinopsis, personajes, mapas de relaciones, fichas '
                          'de mundo, bestiarios y notas creadas o almacenadas en Trama son propiedad '
                          'intelectual exclusiva e inalienable del usuario creador.\n\n'
                          'Trama no reclama ningún tipo de derecho de autor, titularidad, cesión ni licencia '
                          'de explotación comercial sobre tu obra. Tu literatura te pertenece por completo.',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Tratamiento y Protección de Datos Personales
                const _LegalCard(
                  icon: Icons.privacy_tip_outlined,
                  title: '2. Tratamiento y Protección de Datos (RGPD / Privacy)',
                  badge: 'Privacidad y Seguridad',
                  badgeColor: AppColors.secondaryContainer,
                  children: [
                    _Paragraph(
                      title: 'Principio de Minimización de Datos:',
                      content:
                          'Únicamente se recopilan los datos estrictamente necesarios para el funcionamiento '
                          'del servicio: dirección de correo electrónico para autenticación segura, nombre o '
                          'seudónimo de usuario y los textos literarios que decidas sincronizar.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _Paragraph(
                      title: 'Almacenamiento Cifrado y Confidencialidad:',
                      content:
                          'Los proyectos se almacenan en infraestructura en la nube gestionada con '
                          'Supabase, respaldada por protocolos de seguridad de nivel industrial con cifrado '
                          'en reposo y en tránsito mediante TLS/HTTPS con certificados de alta seguridad. '
                          'Tu información no es accesible para otros usuarios a menos que decidas compartirla explícitamente.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _Paragraph(
                      title: 'Cero Comercialización y Cero Venta de Datos:',
                      content:
                          'Trama jamás venderá, alquilará, comercializará ni transferirá tu información '
                          'personal ni tus manuscritos a anunciantes, agregadores de datos ni terceros.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _Paragraph(
                      title: 'Derechos del Usuario (ARCO y Supresión):',
                      content:
                          'Tienes derecho en cualquier momento a acceder, rectificar, exportar en formatos estándar '
                          'y solicitar la eliminación total y definitiva de tu cuenta y todos tus datos del sistema.',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Uso de Caché, Almacenamiento Local y Cookies
                const _LegalCard(
                  icon: Icons.cookie_outlined,
                  title: '3. Uso de Cookies, Caché y Almacenamiento Local',
                  badge: 'Transparencia Técnica',
                  badgeColor: AppColors.tertiaryContainer,
                  children: [
                    _Paragraph(
                      title: 'Cookies y Tokens de Sesión Técnicos:',
                      content:
                          'Trama NO utiliza cookies publicitarias ni trackers de rastreo de navegación de terceros. '
                          'Únicamente se utilizan tokens de autenticación técnica segura (Session Storage / Local Storage '
                          'mediante Supabase Auth) indispensables para mantener tu sesión iniciada de manera cifrada.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _Paragraph(
                      title: 'Almacenamiento Local en tu Navegador / Dispositivo:',
                      content:
                          'Utilizamos el almacenamiento local del dispositivo (SharedPreferences / Web LocalStorage) para:\n'
                          '• Guardar tus preferencias visuales (modo de concentración, temas, paneles colapsables).\n'
                          '• Guardar la disposición y coordenadas personalizadas de los nodos en el mapa de relaciones.\n'
                          '• Optimizar la fluidez de trabajo y reducir la latencia de respuesta sin enviar peticiones innecesarias.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _Paragraph(
                      title: 'Caché de Navegación y Fuentes Tipográficas:',
                      content:
                          'Para garantizar que la aplicación funcione a máxima velocidad y con un bajo consumo de datos móviles, '
                          'tu navegador almacena en caché las fuentes tipográficas editoriales (como Google Fonts) y los módulos de código '
                          'estáticos de la aplicación.',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 4. Permisos de la Aplicación y del Dispositivo
                const _LegalCard(
                  icon: Icons.folder_shared_outlined,
                  title: '4. Permisos del Dispositivo y Acceso a Archivos',
                  badge: 'Control Total',
                  badgeColor: AppColors.primaryContainer,
                  children: [
                    _Paragraph(
                      title: 'Acceso a Archivos para Importación y Exportación:',
                      content:
                          'Trama únicamente interactúa con tu sistema de archivos en dos circunstancias explícitamente iniciadas por ti:\n'
                          '1. Al importar un archivo (.docx) mediante el selector del sistema.\n'
                          '2. Al descargar o exportar tu libro (PDF, DOCX, TXT o copia JSON).\n'
                          'Trama NO escanea, lee ni recopila ningún archivo fuera del seleccionado por ti.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _Paragraph(
                      title: 'Acceso a Red / Internet:',
                      content:
                          'Se requiere conexión a red para sincronizar tus capítulos y herramientas con el servidor, '
                          'verificar tu sesión y realizar consultas opcionales de corrección ortográfica profunda '
                          'a través de servicios lingüísticos seguros (LanguageTool).',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 5. Términos de Servicio y Copias de Seguridad
                const _LegalCard(
                  icon: Icons.gavel_outlined,
                  title: '5. Términos de Servicio y Recomendaciones',
                  badge: 'Buenas Prácticas',
                  badgeColor: AppColors.secondaryContainer,
                  children: [
                    _Paragraph(
                      title: 'Copia de Seguridad Recomendada:',
                      content:
                          'Aunque Trama incorpora mecanismos de autoguardado y respaldo continuo en la nube, se aconseja '
                          'a todo escritor realizar periódicamente copias de seguridad locales de sus obras utilizando '
                          'la sección de «Exportar» integrada en la barra lateral.',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _Paragraph(
                      title: 'Disponibilidad del Servicio:',
                      content:
                          'Trama se esfuerza por brindar máxima disponibilidad y fiabilidad. Al encontrarse en continua evolución '
                          '(fase Alpha), pueden realizarse mejoras y actualizaciones que busquen optimizar la experiencia.',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 6. Contacto y Soporte
                const _ContactCard(),
                const SizedBox(height: AppSpacing.xxl),

                // Footer de copyright
                Center(
                  child: Text(
                    'Trama © ${DateTime.now().year}. Todos los derechos sobre la plataforma reservados. '
                    'Los derechos sobre las obras literarias pertenecen en su totalidad a sus respectivos autores. ©OmarSalcedo ',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelXs.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.allLg,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: AppRadii.allMd,
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  color: AppColors.primaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('TRAMA', style: AppTypography.headlineLg),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: AppRadii.allSm,
                            border: Border.all(
                              color: AppColors.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'v1.0.0 Alpha',
                            style: AppTypography.labelXs.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Herramienta colaborativa para Escritura, Estructura y Arquitectura Literaria',
                      style: AppTypography.uiBodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Información Legal, Privacidad, Permisos y Tratamiento de Datos',
            style: AppTypography.headlineSm.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Este documento establece de forma clara, transparente y vinculante las condiciones '
            'de uso del servicio, la estricta protección de la propiedad intelectual de tus manuscritos, '
            'la propiedad sobre la plataforma y el tratamiento ético de datos, cookies y caché.',
            style: AppTypography.uiBodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightsRow extends StatelessWidget {
  const _HighlightsRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final items = [
          _HighlightItem(
            icon: Icons.verified_user_outlined,
            title: 'Tus obras son 100% tuyas',
            desc: 'Conservas el derecho de autor exclusivo de todos tus textos.',
          ),
          _HighlightItem(
            icon: Icons.lock_outline,
            title: 'Sin venta de datos',
            desc: 'Tus proyectos e información jamás se comercializan.',
          ),
          _HighlightItem(
            icon: Icons.cookie_outlined,
            title: 'Sin cookies de rastreo',
            desc: 'Solo tokens técnicos imprescindibles para tu sesión.',
          ),
        ];

        if (isCompact) {
          return Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: item,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: items
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: item,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _HighlightItem({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.allMd,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.uiBodySm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.labelXs.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final Color badgeColor;
  final List<Widget> children;

  const _LegalCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.allLg,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.onSurface),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headlineSm.copyWith(fontSize: 17),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.allSm,
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  badge,
                  style: AppTypography.labelXs.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String title;
  final String content;

  const _Paragraph({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.uiBodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: AppTypography.uiBodySm.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado al portapapeles.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.allLg,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('6. Contacto y Soporte', style: AppTypography.headlineSm),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Si tienes inquietudes sobre este aviso legal, el tratamiento de tus datos personales, '
            'o deseas ejercer tus derechos sobre tus proyectos o cuenta, puedes comunicarte con el equipo de soporte.',
            style: AppTypography.uiBodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _copyToClipboard(
                  context,
                  'salcedosolarteomar@gmail.com',
                  'Correo de soporte',
                ),
                icon: const Icon(Icons.email_outlined, size: 16),
                label: const Text('salcedosolarteomar@gmail.com'),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyToClipboard(
                  context,
                  'salcedosolarteomar@gmail.com',
                  'Correo legal y de datos',
                ),
                icon: const Icon(Icons.security, size: 16),
                label: const Text('salcedosolarteomar@gmail.com'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
