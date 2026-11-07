import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/models/surah.dart';

class Moment {
  const Moment({
    required this.id,
    required this.reciterId,
    required this.surahId,
    required this.ayahNumber,
    required this.title,
    required this.caption,
    required this.videoUrl,
    required this.posterUrl,
    required this.duration,
    required this.width,
    required this.height,
    required this.likesCount,
    required this.liked,
    required this.savesCount,
    required this.saved,
    required this.commentsCount,
    required this.followedReciter,
    required this.hashtags,
    required this.linkedRecitationId,
    this.reciter,
    this.surah,
  });

  final int id;
  final int? reciterId;
  final int? surahId;
  final int? ayahNumber;
  final String? title;
  final String? caption;
  final String? videoUrl;
  final String? posterUrl;
  final int? duration;
  final int? width;
  final int? height;
  final int likesCount;
  final bool liked;
  final int savesCount;
  final bool saved;
  final int commentsCount;
  final bool followedReciter;
  final List<String> hashtags;
  final int? linkedRecitationId;
  final Reciter? reciter;
  final Surah? surah;

  factory Moment.fromJson(Map<String, dynamic> json) {
    final reciterJson = json['reciter'];
    final surahJson = json['surah'];
    return Moment(
      id: (json['id'] as num).toInt(),
      reciterId: (json['reciter_id'] as num?)?.toInt(),
      surahId: (json['surah_id'] as num?)?.toInt(),
      ayahNumber: (json['ayah_number'] as num?)?.toInt(),
      title: json['title'] as String?,
      caption: json['caption'] as String?,
      videoUrl: json['video_url'] as String?,
      posterUrl: json['poster_url'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      liked: json['liked'] == true,
      savesCount: (json['saves_count'] as num?)?.toInt() ?? 0,
      saved: json['saved'] == true,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      followedReciter: json['followed_reciter'] == true,
      hashtags: json['hashtags'] is List
          ? (json['hashtags'] as List).whereType<String>().toList()
          : const [],
      linkedRecitationId: (json['linked_recitation_id'] as num?)?.toInt(),
      reciter: reciterJson is Map<String, dynamic>
          ? Reciter.fromJson(reciterJson)
          : null,
      surah: surahJson is Map<String, dynamic>
          ? Surah.fromJson(surahJson)
          : null,
    );
  }

  Moment copyWith({
    bool? liked,
    int? likesCount,
    bool? saved,
    int? savesCount,
    int? commentsCount,
    bool? followedReciter,
  }) {
    return Moment(
      id: id,
      reciterId: reciterId,
      surahId: surahId,
      ayahNumber: ayahNumber,
      title: title,
      caption: caption,
      videoUrl: videoUrl,
      posterUrl: posterUrl,
      duration: duration,
      width: width,
      height: height,
      likesCount: likesCount ?? this.likesCount,
      liked: liked ?? this.liked,
      savesCount: savesCount ?? this.savesCount,
      saved: saved ?? this.saved,
      commentsCount: commentsCount ?? this.commentsCount,
      followedReciter: followedReciter ?? this.followedReciter,
      hashtags: hashtags,
      linkedRecitationId: linkedRecitationId,
      reciter: reciter,
      surah: surah,
    );
  }
}

class MomentComment {
  const MomentComment({
    required this.id,
    required this.body,
    required this.userName,
    required this.mine,
  });

  final int id;
  final String body;
  final String userName;
  final bool mine;

  factory MomentComment.fromJson(Map<String, dynamic> json) {
    return MomentComment(
      id: (json['id'] as num).toInt(),
      body: (json['body'] as String?) ?? '',
      userName: (json['user_name'] as String?) ?? '',
      mine: json['mine'] == true,
    );
  }
}
