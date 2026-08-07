import 'package:flutter/material.dart';

/// App-wide constants for Xulka Quraada mobile.
class AppConstants {
  static const String appName = 'Xulka Quraada';
  static const String logoAsset = 'assets/images/logo.svg';

  /// Override with `--dart-define=API_BASE_URL=http://...`
  /// Android emulator default reaches the host machine's localhost:8000.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Public website origin for share links (`/listen/{id}`).
  /// Defaults to the same host as [apiBaseUrl] (no `/api` path).
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: '',
  );

  static const String apiPrefix = '/api/v1';

  static const List<Locale> supportedLocales = [
    Locale('so'),
    Locale('ar'),
    Locale('en'),
  ];

  static String get resolvedWebBaseUrl {
    if (webBaseUrl.trim().isNotEmpty) {
      return webBaseUrl.trim().replaceAll(RegExp(r'/$'), '');
    }
    return apiBaseUrl.replaceAll(RegExp(r'/$'), '');
  }

  static String listenUrl(int recitationId) =>
      '$resolvedWebBaseUrl/listen/$recitationId';
}
