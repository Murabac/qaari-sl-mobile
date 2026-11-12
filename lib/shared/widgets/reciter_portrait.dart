import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

/// Portraits for the live reciters.
/// Sufi uses Abdirashid, Alafasy uses his own photo, al-Hussary uses Mustafe.
String? reciterPortraitAsset(Reciter reciter) {
  final haystack = '${reciter.nameEnglish} ${reciter.nameSomali}'.toLowerCase();

  if (haystack.contains('sufi') ||
      haystack.contains('suufi') ||
      haystack.contains('cabdirashiid')) {
    return 'assets/images/sheikh_abdirashid.jpg';
  }
  if (haystack.contains('alafasy') ||
      haystack.contains('mishary') ||
      haystack.contains('cafaasi')) {
    return 'assets/images/mishary_alafasy.jpg';
  }
  if (haystack.contains('abdilahi') || haystack.contains('cabdilaahi')) {
    return 'assets/images/sheikh_abdilahi.jpg';
  }
  if (haystack.contains('hussary') ||
      haystack.contains('husary') ||
      haystack.contains('mustafe') ||
      haystack.contains('mahmoud')) {
    return 'assets/images/sheikh_mustafe.jpg';
  }

  return null;
}

class ReciterFace extends StatelessWidget {
  const ReciterFace({
    super.key,
    required this.reciter,
    this.size = 48,
    this.borderRadius,
    this.nameForFallback,
  });

  final Reciter reciter;
  final double size;
  final BorderRadius? borderRadius;
  final String? nameForFallback;

  @override
  Widget build(BuildContext context) {
    final asset = reciterPortraitAsset(reciter);
    final radius = borderRadius ?? BorderRadius.circular(16);
    if (asset == null) {
      return NetworkAvatar(
        url: reciter.photoUrl,
        size: size,
        borderRadius: radius,
        nameForFallback: nameForFallback,
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
    );
  }
}

/// Arch frame used by the mini player and later reciter cards.
class ArchPortrait extends StatelessWidget {
  const ArchPortrait({
    super.key,
    required this.reciter,
    required this.width,
    required this.height,
    this.bottomRadius,
  });

  final Reciter reciter;
  final double width;
  final double height;
  final double? bottomRadius;

  static const _fallbacks = <List<Color>>[
    [Color(0xFF2A8574), Color(0xFF0B3F38)],
    [Color(0xFFC9A961), Color(0xFF6B5222)],
    [Color(0xFF5F8F86), Color(0xFF173F39)],
  ];

  @override
  Widget build(BuildContext context) {
    final top = width / 2;
    final bottom = bottomRadius ?? (width >= 120 ? 28.0 : 14.0);
    final radius = BorderRadius.only(
      topLeft: Radius.circular(top),
      topRight: Radius.circular(top),
      bottomLeft: Radius.circular(bottom),
      bottomRight: Radius.circular(bottom),
    );
    final inset = (width * 0.07).clamp(4.0, 11.0);
    final inner = BorderRadius.only(
      topLeft: Radius.circular((top - inset).clamp(0, top)),
      topRight: Radius.circular((top - inset).clamp(0, top)),
      bottomLeft: Radius.circular((bottom - inset).clamp(0, bottom)),
      bottomRight: Radius.circular((bottom - inset).clamp(0, bottom)),
    );

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _fill(),
            Padding(
              padding: EdgeInsets.all(inset),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: inner,
                  border: Border.all(color: const Color(0x38F4EFE6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fill() {
    final asset = reciterPortraitAsset(reciter);
    if (asset != null) {
      return Image.asset(asset, fit: BoxFit.cover);
    }
    final url = reciter.photoUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final colors = _fallbacks[reciter.id.abs() % _fallbacks.length];
    final source = reciter.nameArabic.trim().isNotEmpty
        ? reciter.nameArabic.trim()
        : (reciter.nameEnglish.trim().isNotEmpty
              ? reciter.nameEnglish.trim()
              : reciter.nameSomali.trim());
    final initial = source.isEmpty ? 'ق' : source.substring(0, 1);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTheme.amiri(
            fontSize: width * 0.42,
            color: const Color(0xFFF4EFE6),
          ),
        ),
      ),
    );
  }
}
