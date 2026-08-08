import 'package:flutter/material.dart';

/// App-wide constants for Xulka Quraada mobile.
class AppConstants {
  static const String appName = 'Xulka Quraada';
  static const String logoAsset = 'assets/images/logo.svg';

  /// Override for local/dev: `--dart-define=API_BASE_URL=http://10.0.2.2:8000`
  /// Production APKs use the live API by default.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://qaari.mahaysaa.com',
  );

  /// Public website origin for share links (`/listen/{id}`).
  /// Defaults to the same host as [apiBaseUrl] (no `/api` path).
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'https://qaari.mahaysaa.com',
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

  static String get accountDeletionUrl =>
      '${resolvedWebBaseUrl}/account-deletion';

  static String get privacyPolicyUrl => '${resolvedWebBaseUrl}/privacy';

  /// Google Play listing (package `com.xulkaquraada.app`).
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.xulkaquraada.app';
}
