import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistema tipográfico de Trama.
/// Inter: interfaz general.
/// Fraunces: titulares editoriales.
/// Literata: cuerpo de manuscrito.
class AppTypography {
  AppTypography._();

  // === UI (Inter) ===
  static TextStyle get uiBodyMd => GoogleFonts.inter(
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get uiBodySm => GoogleFonts.inter(
        fontSize: 13,
        height: 1.38,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 12,
        height: 1.33,
        letterSpacing: 0.02,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      );

  static TextStyle get labelXs => GoogleFonts.inter(
        fontSize: 11,
        height: 1.27,
        letterSpacing: 0.04,
        fontWeight: FontWeight.w500,
        color: AppColors.outline,
      );

  // === Titulares (Fraunces) ===
  static TextStyle get headlineXl => GoogleFonts.fraunces(
        fontSize: 44,
        height: 1.18,
        letterSpacing: -0.02,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineXlMobile => GoogleFonts.fraunces(
        fontSize: 32,
        height: 1.25,
        letterSpacing: -0.015,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLg => GoogleFonts.fraunces(
        fontSize: 32,
        height: 1.25,
        letterSpacing: -0.015,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.fraunces(
        fontSize: 26,
        height: 1.31,
        letterSpacing: -0.01,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMd => GoogleFonts.fraunces(
        fontSize: 24,
        height: 1.33,
        letterSpacing: -0.01,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSm => GoogleFonts.fraunces(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      );

  // === Manuscrito (Literata) ===
  static TextStyle get manuscriptLg => GoogleFonts.literata(
        fontSize: 19,
        height: 1.68,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get manuscriptMd => GoogleFonts.literata(
        fontSize: 17,
        height: 1.65,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );
}