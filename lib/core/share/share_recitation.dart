import 'package:share_plus/share_plus.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';

Future<void> shareRecitation(Recitation track) {
  final title = track.surah?.titleLine ?? 'Surah ${track.surahId}';
  final artist = track.reciterName ?? AppConstants.appName;
  final url = AppConstants.listenUrl(track.id);
  return SharePlus.instance.share(
    ShareParams(
      text: '$title — $artist\n$url',
      subject: '$title on ${AppConstants.appName}',
    ),
  );
}
