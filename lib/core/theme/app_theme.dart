import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final nunito = GoogleFonts.nunitoTextTheme();
    final amiri = GoogleFonts.amiriTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forest,
        onPrimary: AppColors.cream,
        secondary: AppColors.gold,
        onSecondary: AppColors.forest,
        surface: AppColors.creamCard,
        onSurface: AppColors.ink,
        outline: AppColors.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: nunito.titleLarge?.copyWith(
          color: AppColors.cream,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
      textTheme: nunito
          .apply(
            bodyColor: AppColors.ink,
            displayColor: AppColors.ink,
          )
          .copyWith(
            headlineLarge: nunito.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
            headlineMedium: amiri.headlineMedium?.copyWith(
              color: AppColors.gold,
            ),
            titleLarge: nunito.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
      cardTheme: CardThemeData(
        color: AppColors.creamCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dividerColor: AppColors.border,
    );
  }

  static TextStyle amiri({
    double fontSize = 22,
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w400,
    double height = 1.6,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }
}
