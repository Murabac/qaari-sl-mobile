import 'package:flutter/material.dart';

/// Brand colors — aligned with Mobile APP Design Ref / Safwat al-Qurra.
abstract final class AppColors {
  static const Color deep = Color(0xFF08281F);
  static const Color forest = Color(0xFF0D3B2E);
  static const Color forestSoft = Color(0xFF164E3D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3D082);
  static const Color cream = Color(0xFFF5F2EA);
  static const Color creamSurface = Color(0xFFEFECE3);
  static const Color creamCard = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF0D3B2E);
  static const Color muted = Color(0xFF6B7B72);
  static const Color mutedSoft = Color(0xFFA3B5A8);
  static const Color mutedOnDark = Color(0xFFA2B5AA);
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

  static List<BoxShadow> get miniPlayerShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static BoxDecoration get creamHeaderDecoration => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [creamSurface, cream],
        ),
        border: Border(bottom: BorderSide(color: border)),
      );
}
