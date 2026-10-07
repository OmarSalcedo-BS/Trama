import 'package:flutter/material.dart';

/// Paleta oficial de Trama.
/// Extraída del diseño editorial aprobado (Stitch).
class AppColors {
  AppColors._();

  // === Superficies ===
  static const Color background = Color(0xFFFBF8FC);
  static const Color surface = Color(0xFFFBF8FC);
  static const Color surfaceBright = Color(0xFFFBF8FC);
  static const Color surfaceDim = Color(0xFFDCD9DD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F2F7);
  static const Color surfaceContainer = Color(0xFFF0EDF1);
  static const Color surfaceContainerHigh = Color(0xFFEAE7EB);
  static const Color surfaceContainerHighest = Color(0xFFE4E1E6);
  static const Color surfaceVariant = Color(0xFFE4E1E6);

  // === Texto ===
  static const Color onSurface = Color(0xFF1B1B1E);
  static const Color onSurfaceVariant = Color(0xFF464555);
  static const Color onBackground = Color(0xFF1B1B1E);
  static const Color outline = Color(0xFF777587);
  static const Color outlineVariant = Color(0xFFC7C4D8);

  // === Acento principal (índigo editorial) ===
  static const Color primary = Color(0xFF3525CD);
  static const Color primaryContainer = Color(0xFF4F46E5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFDAD7FF);
  static const Color primaryFixed = Color(0xFFE2DFFF);
  static const Color primaryFixedDim = Color(0xFFC3C0FF);
  static const Color onPrimaryFixed = Color(0xFF0F0069);
  static const Color onPrimaryFixedVariant = Color(0xFF3323CC);
  static const Color inversePrimary = Color(0xFFC3C0FF);

  // === Acento terciario ===
  static const Color tertiary = Color(0xFF7E3000);
  static const Color tertiaryContainer = Color(0xFFA44100);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFFFD2BE);

  // === Superficies oscuras ===
  static const Color inverseSurface = Color(0xFF303033);
  static const Color inverseOnSurface = Color(0xFFF3F0F4);

  // === Estados / errores ===
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // === Secondary ===
  static const Color secondary = Color(0xFF5A5E69);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDEE2EF);
  static const Color onSecondaryContainer = Color(0xFF60646F);
}