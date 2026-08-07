import 'package:qaari_sl_mobile/core/models/surah.dart';

class Recitation {
  const Recitation({
    required this.id,
    required this.reciterId,
    required this.surahId,
    required this.audioUrl,
    required this.duration,
    required this.fileSize,
    this.surah,
    this.reciterName,
    this.reciterPhotoUrl,
  });

  final int id;
  final int reciterId;
  final int surahId;
  final String audioUrl;
  final int duration;
  final int fileSize;
  final Surah? surah;
  final String? reciterName;
  final String? reciterPhotoUrl;

  factory Recitation.fromJson(Map<String, dynamic> json) {
    final reciter = json['reciter'];
    return Recitation(
      id: (json['id'] as num).toInt(),
      reciterId: (json['reciter_id'] as num).toInt(),
      surahId: (json['surah_id'] as num).toInt(),
      audioUrl: (json['audio_url'] as String?) ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      surah: json['surah'] is Map<String, dynamic>
          ? Surah.fromJson(json['surah'] as Map<String, dynamic>)
          : null,
      reciterName: reciter is Map<String, dynamic>
          ? (reciter['name_english'] as String?)
          : null,
      reciterPhotoUrl: reciter is Map<String, dynamic>
          ? (reciter['photo_url'] as String?)
          : null,
    );
  }

  Recitation copyWith({
    String? audioUrl,
    Surah? surah,
    String? reciterName,
    String? reciterPhotoUrl,
  }) {
    return Recitation(
      id: id,
      reciterId: reciterId,
      surahId: surahId,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration,
      fileSize: fileSize,
      surah: surah ?? this.surah,
      reciterName: reciterName ?? this.reciterName,
      reciterPhotoUrl: reciterPhotoUrl ?? this.reciterPhotoUrl,
    );
  }

  String get durationLabel {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
