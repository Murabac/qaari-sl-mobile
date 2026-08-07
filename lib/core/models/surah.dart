class Surah {
  const Surah({
    required this.id,
    required this.number,
    required this.nameArabic,
    required this.nameSomali,
    required this.nameEnglish,
    required this.verseCount,
  });

  final int id;
  final int number;
  final String nameArabic;
  final String nameSomali;
  final String nameEnglish;
  final int verseCount;

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: (json['id'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      nameArabic: (json['name_arabic'] as String?) ?? '',
      nameSomali: (json['name_somali'] as String?) ?? '',
      nameEnglish: (json['name_english'] as String?) ?? '',
      verseCount: (json['verse_count'] as num?)?.toInt() ?? 0,
    );
  }

  String localizedName(String languageCode) {
    return switch (languageCode) {
      'so' when nameSomali.isNotEmpty => nameSomali,
      'ar' when nameArabic.isNotEmpty => nameArabic,
      _ => nameEnglish.isNotEmpty ? nameEnglish : nameArabic,
    };
  }

  String get titleLine => '$number. $nameEnglish';
}
