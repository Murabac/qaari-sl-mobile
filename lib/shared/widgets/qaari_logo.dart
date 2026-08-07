import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';

/// Circular Qaari mark matching Mobile APP Design Ref `QaariLogo`.
class QaariLogo extends StatelessWidget {
  const QaariLogo({super.key, this.size = 80});

  final double size;

  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <defs>
    <radialGradient id="qlBg" cx="42%" cy="36%" r="72%">
      <stop offset="0%" stop-color="#244D3B"/>
      <stop offset="100%" stop-color="#0A1C11"/>
    </radialGradient>
    <radialGradient id="qlGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#C9A24B" stop-opacity="0.18"/>
      <stop offset="100%" stop-color="#C9A24B" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <circle cx="100" cy="100" r="99" fill="url(#qlBg)"/>
  <circle cx="100" cy="100" r="80" fill="url(#qlGlow)"/>
  <circle cx="100" cy="100" r="97" fill="none" stroke="#C9A24B" stroke-width="1.8"/>
  <circle cx="100" cy="100" r="86" fill="none" stroke="#C9A24B" stroke-width="0.6" opacity="0.35"/>
  <polygon points="100,35 115,63 146,54 137,85 165,100 137,115 146,146 115,137 100,165 85,137 54,146 63,115 35,100 63,85 54,54 85,63" fill="#C9A24B" opacity="0.10"/>
  <polygon points="100,35 115,63 146,54 137,85 165,100 137,115 146,146 115,137 100,165 85,137 54,146 63,115 35,100 63,85 54,54 85,63" fill="none" stroke="#C9A24B" stroke-width="1.1" opacity="0.50"/>
  <circle cx="100" cy="100" r="42" fill="none" stroke="#C9A24B" stroke-width="0.8" opacity="0.45"/>
  <text x="100" y="119" font-family="Amiri, serif" font-size="64" fill="#C9A24B" text-anchor="middle" font-weight="400">ق</text>
  <circle cx="100" cy="26" r="3" fill="#C9A24B"/>
  <circle cx="174" cy="100" r="3" fill="#C9A24B"/>
  <circle cx="100" cy="174" r="3" fill="#C9A24B"/>
  <circle cx="26" cy="100" r="3" fill="#C9A24B"/>
  <circle cx="148" cy="52" r="2" fill="#C9A24B" opacity="0.65"/>
  <circle cx="148" cy="148" r="2" fill="#C9A24B" opacity="0.65"/>
  <circle cx="52" cy="148" r="2" fill="#C9A24B" opacity="0.65"/>
  <circle cx="52" cy="52" r="2" fill="#C9A24B" opacity="0.65"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(_svg, width: size, height: size),
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
      const Color(0xFF1B5E3B),
      const Color(0xFF2E4A3A),
      const Color(0xFF3D6B55),
      const Color(0xFF24614A),
      const Color(0xFF4A7862),
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
