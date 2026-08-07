import 'package:flutter/material.dart';

/// Brand colors from Mobile APP Design Ref.
abstract final class AppColors {
  static const Color deep = Color(0xFF0A1C11);
  static const Color forest = Color(0xFF1B3A2E);
  static const Color forestSoft = Color(0xFF2D5740);
  static const Color gold = Color(0xFFC9A24B);
  static const Color goldLight = Color(0xFFE8C370);
  static const Color cream = Color(0xFFF7F4EE);
  static const Color creamCard = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1B3A2E);
  static const Color muted = Color(0xFF6B7B72);
  static const Color mutedSoft = Color(0xFFA3B5A8);
  static const Color border = Color(0xFFE8E4D8);
  static const Color inputFill = Color(0xFFEDE9DF);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: forest.withValues(alpha: 0.07),
          blurRadius: 14,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get featuredShadow => [
        BoxShadow(
          color: forest.withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ];
}
