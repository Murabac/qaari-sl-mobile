import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController({
    SharedPreferences? prefs,
    bool autoLoad = true,
  })  : _prefs = prefs,
        super(const Locale('so')) {
    if (autoLoad) {
      _load();
    }
  }

  static const prefsKey = 'qaari_sl_locale';

  SharedPreferences? _prefs;

  Future<void> _load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final code = _prefs!.getString(prefsKey);
    if (code == null || code.isEmpty) return;
    final match = AppConstants.supportedLocales
        .where((locale) => locale.languageCode == code)
        .toList();
    if (match.isNotEmpty) {
      state = match.first;
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppConstants.supportedLocales
        .any((item) => item.languageCode == locale.languageCode)) {
      return;
    }
    state = locale;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(prefsKey, locale.languageCode);
  }

  /// Test helper: apply a persisted code without hitting disk.
  void applyCode(String code) {
    final match = AppConstants.supportedLocales
        .where((locale) => locale.languageCode == code)
        .toList();
    if (match.isNotEmpty) {
      state = match.first;
    }
  }
}
