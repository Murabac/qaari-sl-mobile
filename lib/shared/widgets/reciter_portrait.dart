import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

/// Portraits for the live reciters.
/// Sufi uses Abdirashid, Alafasy uses his own photo, al-Hussary uses Mustafe.
String? reciterPortraitAsset(Reciter reciter) {
  final haystack =
      '${reciter.nameEnglish} ${reciter.nameSomali}'.toLowerCase();

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
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
