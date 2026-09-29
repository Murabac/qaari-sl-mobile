import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';

/// Safwat al-Qurra brand mark (transparent white calligraphy, or green badge).
class QaariLogo extends StatelessWidget {
  const QaariLogo({
    super.key,
    this.size = 80,
    this.circle = true,
    this.light = false,
  });

  final double size;
  final bool circle;

  /// White mark for dark backgrounds (splash / hero).
  final bool light;

  @override
  Widget build(BuildContext context) {
    final asset = light
        ? 'assets/images/logo-mark-light.png'
        : (circle
            ? 'assets/images/logo-circle.png'
            : AppConstants.logoAsset);

    final image = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );

    if (light || !circle) {
      return SizedBox(width: size, height: size, child: image);
    }

    return ClipOval(
      child: SizedBox(width: size, height: size, child: image),
    );
  }
}

/// Initials avatar on forest/gold when no photo — matches design `Avatar`.
class ReciterInitialsAvatar extends StatelessWidget {
  const ReciterInitialsAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.color,
  });

  final String name;
  final double size;
  final Color? color;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'ق';
    if (parts.length == 1) {
      final word = parts.first;
      return word.substring(0, word.length.clamp(0, 2)).toUpperCase();
    }
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.last.isNotEmpty ? parts.last[0] : '';
    return ('$a$b').toUpperCase();
  }

  Color get _bg {
    if (color != null) return color!;
    final palette = [
      const Color(0xFF0C403E),
      const Color(0xFF1C5A58),
      const Color(0xFF14504E),
      const Color(0xFF0A3836),
      const Color(0xFF246866),
    ];
    return palette[name.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.33,
        ),
      ),
    );
  }
}
