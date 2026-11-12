import 'package:flutter/material.dart';

/// v2 color tokens. Screens read these through [BuildContext.palette].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.bg,
    required this.bgDeep,
    required this.bgGlow,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.text,
    required this.muted,
    required this.accent,
    required this.primary,
    required this.onPrimary,
    required this.chip,
    required this.navGlass,
    required this.danger,
    required this.brand,
  });

  final Brightness brightness;
  final Color bg;
  final Color bgDeep;
  final Color bgGlow;
  final Color surface;
  final Color surface2;
  final Color line;
  final Color text;
  final Color muted;
  final Color accent;
  final Color primary;
  final Color onPrimary;
  final Color chip;
  final Color navGlass;
  final Color danger;
  final Color brand;

  static const dark = AppPalette(
    brightness: Brightness.dark,
    bg: Color(0xFF062B26),
    bgDeep: Color(0xFF041D1A),
    bgGlow: Color(0xFF0F5A50),
    surface: Color(0xFF0B3A34),
    surface2: Color(0xFF0F4A42),
    line: Color(0x1AF4EFE6),
    text: Color(0xFFF4EFE6),
    muted: Color(0xFF9FB8B0),
    accent: Color(0xFFD9B76A),
    primary: Color(0xFFD9B76A),
    onPrimary: Color(0xFF062B26),
    chip: Color(0x1AF4EFE6),
    navGlass: Color(0xD10B3A34),
    danger: Color(0xFFE7A38F),
    brand: Color(0xFF084038),
  );

  static const light = AppPalette(
    brightness: Brightness.light,
    bg: Color(0xFFF5F1E8),
    bgDeep: Color(0xFFEFE9DB),
    bgGlow: Color(0xFFF8F5EE),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE9E3D3),
    line: Color(0x1F084038),
    text: Color(0xFF0C2420),
    muted: Color(0xFF55655F),
    accent: Color(0xFF7E5D14),
    primary: Color(0xFF084038),
    onPrimary: Color(0xFFF5F1E8),
    chip: Color(0x1A084038),
    navGlass: Color(0xDBFFFFFF),
    danger: Color(0xFFB3472E),
    brand: Color(0xFF084038),
  );

  /// Shared hero card: 140° #13675B → #084038 → #05302B.
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF13675B), Color(0xFF084038), Color(0xFF05302B)],
    stops: [0, 0.55, 1],
  );

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? bg,
    Color? bgDeep,
    Color? bgGlow,
    Color? surface,
    Color? surface2,
    Color? line,
    Color? text,
    Color? muted,
    Color? accent,
    Color? primary,
    Color? onPrimary,
    Color? chip,
    Color? navGlass,
    Color? danger,
    Color? brand,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      bg: bg ?? this.bg,
      bgDeep: bgDeep ?? this.bgDeep,
      bgGlow: bgGlow ?? this.bgGlow,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      line: line ?? this.line,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      chip: chip ?? this.chip,
      navGlass: navGlass ?? this.navGlass,
      danger: danger ?? this.danger,
      brand: brand ?? this.brand,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: Color.lerp(bg, other.bg, t)!,
      bgDeep: Color.lerp(bgDeep, other.bgDeep, t)!,
      bgGlow: Color.lerp(bgGlow, other.bgGlow, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      line: Color.lerp(line, other.line, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
      navGlass: Color.lerp(navGlass, other.navGlass, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
