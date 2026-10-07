import 'package:flutter/widgets.dart';

/// Radios de borde oficiales.
/// Del diseño: 0.125rem, 0.25rem, 0.5rem, 0.75rem.
class AppRadii {
  AppRadii._();

  static const Radius sm = Radius.circular(2);
  static const Radius md = Radius.circular(4);
  static const Radius lg = Radius.circular(8);
  static const Radius pill = Radius.circular(12);

  static const BorderRadius allSm = BorderRadius.all(sm);
  static const BorderRadius allMd = BorderRadius.all(md);
  static const BorderRadius allLg = BorderRadius.all(lg);
  static const BorderRadius allPill = BorderRadius.all(pill);
}