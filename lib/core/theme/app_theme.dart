import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_palette.dart';

abstract final class AppTheme {
  static ThemeData get dark => _build(AppPalette.dark);

  static ThemeData get light => _build(AppPalette.light);

  static ThemeData _build(AppPalette palette) {
    final base = ThemeData(useMaterial3: true, brightness: palette.brightness);
    final sans = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: palette.text, displayColor: palette.text);

    return base.copyWith(
      scaffoldBackgroundColor: palette.bg,
      extensions: [palette],
      textTheme: sans,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: palette.brand,
            brightness: palette.brightness,
          ).copyWith(
            primary: palette.primary,
            onPrimary: palette.onPrimary,
            secondary: palette.accent,
            onSecondary: palette.bgDeep,
            surface: palette.surface,
            onSurface: palette.text,
            error: palette.danger,
            onError: palette.bg,
            outline: palette.line,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.bg,
        foregroundColor: palette.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: displayFont(
          fontSize: 22,
          color: palette.text,
          weight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: palette.line),
        ),
      ),
      dividerColor: palette.line,
      iconTheme: IconThemeData(color: palette.text),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.accent, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  static TextStyle displayFont({
    double fontSize = 20,
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w600,
    double height = 1.15,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      color: color,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sans({
    double fontSize = 14,
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w500,
    double height = 1.35,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      color: color,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
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
