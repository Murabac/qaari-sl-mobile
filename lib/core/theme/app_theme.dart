import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final sans = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forest,
        onPrimary: AppColors.cream,
        secondary: AppColors.gold,
        onSecondary: AppColors.deep,
        surface: AppColors.creamCard,
        onSurface: AppColors.ink,
        outline: AppColors.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: displayFont(
          fontSize: 22,
          weight: FontWeight.w600,
        ),
      ),
      textTheme: sans.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      cardTheme: CardThemeData(
        color: AppColors.creamCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerColor: AppColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  static TextStyle displayFont({
    double fontSize = 20,
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w600,
    double height = 1.15,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }

  static TextStyle sans({
    double fontSize = 14,
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w500,
    double height = 1.35,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }

  static TextStyle amiri({
    double fontSize = 22,
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w400,
    double height = 1.8,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }
}
