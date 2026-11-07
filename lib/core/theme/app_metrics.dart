/// Shared layout numbers for the public listener screens.
abstract final class AppSpacing {
  static const double page = 20;
  static const double card = 14;
  static const double tight = 8;
  static const double section = 16;
}

abstract final class AppRadius {
  static const double card = 20;
  static const double chip = 999;
  static const double control = 12;
}

/// Frame ratio for a Moment. Portrait stays portrait, landscape stays
/// landscape, and a missing size falls back to 4:5. Extreme values are
/// capped so a bad measurement cannot become a sliver or a banner.
double momentFrameAspect(int? width, int? height) {
  const tallest = 9 / 16;
  const widest = 16 / 9;
  const fallback = 4 / 5;
  if (width == null || height == null || width <= 0 || height <= 0) {
    return fallback;
  }
  final ratio = width / height;
  if (ratio < tallest) return tallest;
  if (ratio > widest) return widest;
  return ratio;
}
