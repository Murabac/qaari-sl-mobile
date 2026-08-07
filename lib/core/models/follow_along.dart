import 'package:qaari_sl_mobile/core/models/recitation.dart';

class AyahLine {
  const AyahLine({
    required this.number,
    required this.textUthmani,
  });

  final int number;
  final String textUthmani;

  factory AyahLine.fromJson(Map<String, dynamic> json) {
    return AyahLine(
      number: (json['number'] as num).toInt(),
      textUthmani: (json['text_uthmani'] as String?) ?? '',
    );
  }
}

class FollowAlongPayload {
  const FollowAlongPayload({
    required this.recitation,
    required this.ayahs,
    required this.ayahStarts,
  });

  final Recitation recitation;
  final List<AyahLine> ayahs;
  final List<double> ayahStarts;

  factory FollowAlongPayload.fromJson(Map<String, dynamic> json) {
    final ayahsRaw = json['ayahs'];
    final startsRaw = json['ayah_starts'];
    return FollowAlongPayload(
      recitation: Recitation.fromJson(
        json['recitation'] as Map<String, dynamic>,
      ),
      ayahs: ayahsRaw is List
          ? ayahsRaw
              .whereType<Map<String, dynamic>>()
              .map(AyahLine.fromJson)
              .toList()
          : const [],
      ayahStarts: startsRaw is List
          ? startsRaw.map((e) => (e as num).toDouble()).toList()
          : const [],
    );
  }
}
