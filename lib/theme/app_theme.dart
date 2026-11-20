import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// League Spartan para títulos/cifras, Plus Jakarta Sans para texto de cuerpo
/// — mismo par tipográfico que el prototipo.
class AppTheme {
  AppTheme._();

  static TextStyle display({
    double size = 20,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.navy,
  }) =>
      GoogleFonts.leagueSpartan(fontSize: size, fontWeight: weight, color: color);

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.navy,
  }) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: weight, color: color);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.green,
        secondary: AppColors.greenDark,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.navy,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.surface,
          textStyle: body(weight: FontWeight.w700, color: AppColors.surface),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }
}
