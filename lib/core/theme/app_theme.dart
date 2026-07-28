import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final baseText = GoogleFonts.dmSansTextTheme();
    final display = GoogleFonts.playfairDisplayTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.light(
        primary: AppColors.forest,
        onPrimary: AppColors.cream,
        secondary: AppColors.gold,
        onSecondary: AppColors.ink,
        surface: AppColors.creamCard,
        onSurface: AppColors.ink,
        outline: AppColors.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: display.titleLarge?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: baseText
          .apply(
            bodyColor: AppColors.ink,
            displayColor: AppColors.ink,
          )
          .copyWith(
            headlineLarge: display.headlineLarge?.copyWith(color: AppColors.ink),
            headlineMedium: display.headlineMedium?.copyWith(color: AppColors.ink),
            headlineSmall: display.headlineSmall?.copyWith(color: AppColors.ink),
            titleLarge: display.titleLarge?.copyWith(color: AppColors.ink),
          ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.creamCard,
        indicatorColor: AppColors.forest.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          baseText.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
