import 'package:qaari_sl_mobile/core/models/recitation.dart';

class Reciter {
  const Reciter({
    required this.id,
    required this.nameSomali,
    required this.nameArabic,
    required this.nameEnglish,
    required this.bioSomali,
    required this.bioArabic,
    required this.bioEnglish,
    required this.photoUrl,
    required this.region,
    required this.approvedRecitationsCount,
    this.followed = false,
    this.recitations = const [],
  });

  final int id;
  final String nameSomali;
  final String nameArabic;
  final String nameEnglish;
  final String bioSomali;
  final String bioArabic;
  final String bioEnglish;
  final String? photoUrl;
  final String? region;
  final int approvedRecitationsCount;
  final bool followed;
  final List<Recitation> recitations;

  factory Reciter.fromJson(Map<String, dynamic> json) {
    final recitationsJson = json['recitations'];
    return Reciter(
      id: (json['id'] as num).toInt(),
      nameSomali: (json['name_somali'] as String?) ?? '',
      nameArabic: (json['name_arabic'] as String?) ?? '',
      nameEnglish: (json['name_english'] as String?) ?? '',
      bioSomali: (json['bio_somali'] as String?) ?? '',
      bioArabic: (json['bio_arabic'] as String?) ?? '',
      bioEnglish: (json['bio_english'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      region: json['region'] as String?,
      approvedRecitationsCount:
          (json['approved_recitations_count'] as num?)?.toInt() ?? 0,
      followed: json['followed'] == true,
      recitations: recitationsJson is List
          ? recitationsJson
              .whereType<Map<String, dynamic>>()
              .map(Recitation.fromJson)
              .map(
                (r) => r.copyWith(
                  reciterName: (json['name_english'] as String?) ?? '',
                  reciterPhotoUrl: json['photo_url'] as String?,
                ),
              )
              .toList()
          : const [],
    );
  }

  String localizedName(String languageCode) {
    return switch (languageCode) {
      'so' when nameSomali.isNotEmpty => nameSomali,
      'ar' when nameArabic.isNotEmpty => nameArabic,
      _ => nameEnglish.isNotEmpty ? nameEnglish : nameSomali,
    };
  }

  String localizedBio(String languageCode) {
    return switch (languageCode) {
      'so' when bioSomali.isNotEmpty => bioSomali,
      'ar' when bioArabic.isNotEmpty => bioArabic,
      _ => bioEnglish.isNotEmpty ? bioEnglish : bioSomali,
    };
  }
}
