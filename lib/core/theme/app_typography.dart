import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema tipográfico de Trama.
/// Inter para UI, Fraunces para títulos editoriales.
/// Literata para el editor de texto.
/// 
class AppTypography {
  AppTypography._();

  // UI general
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        height: 1.6,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        height: 1.4,
      );

  // Títulos editoriales
  static TextStyle get displayLarge => GoogleFonts.fraunces(
        fontSize: 56,
        height: 1.15,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displayMedium => GoogleFonts.fraunces(
        fontSize: 40,
        height: 1.2,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingLarge => GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingMedium => GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      );

  // Editor de texto
  static TextStyle get editorBody => GoogleFonts.literata(
        fontSize: 18,
        height: 1.7,
      );
}