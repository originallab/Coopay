import 'package:flutter/material.dart';

/// Tokens de marca CooPay — mismos valores que el prototipo en Figma/Artifact.
/// Nunca usar un color crudo fuera de aquí; si hace falta un tono nuevo,
/// se agrega como token con nombre, no como hex suelto en un widget.
class AppColors {
  AppColors._();

  static const navy = Color(0xFF000654);
  static const green = Color(0xFF719D68);
  static const greenDark = Color(0xFF3B5D33);
  static const greenLight = Color(0xFF9BD893);
  static const cream = Color(0xFFE9FFCA);
  static const surface = Color(0xFFFBFFF2);
  static const danger = Color(0xFFD64545);

  static const textDim = Color(0x8C000654); // navy @ 55%
  static const border = Color(0x14000654); // navy @ 8%
}
