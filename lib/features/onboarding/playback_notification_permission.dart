import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Asks Android 13+ for notification permission so playback controls can show.
///
/// Android 12 and below already treat this permission as granted, so no dialog
/// appears. iOS lock-screen controls come from the media session, and this app
/// does not send its own alerts, so iOS is left alone.
Future<void> requestPlaybackNotifications() async {
  if (kIsWeb || !Platform.isAndroid) return;
  final status = await Permission.notification.status;
  if (status.isGranted || status.isLimited || status.isProvisional) return;
  await Permission.notification.request();
}
