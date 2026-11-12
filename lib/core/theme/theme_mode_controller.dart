import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
      return ThemeModeController();
    });

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController({SharedPreferences? prefs, bool autoLoad = true})
    : _prefs = prefs,
      super(ThemeMode.dark) {
    if (autoLoad) {
      _load();
    }
  }

  static const prefsKey = 'qaari_sl_theme_mode';

  SharedPreferences? _prefs;

  Future<void> _load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final code = _prefs!.getString(prefsKey);
    if (code == null || code.isEmpty) return;
    applyCode(code);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(prefsKey, mode.name);
  }

  /// Test helper: apply a persisted code without hitting disk.
  void applyCode(String code) {
    final mode = switch (code) {
      'system' => ThemeMode.system,
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => null,
    };
    if (mode != null) state = mode;
  }
}
