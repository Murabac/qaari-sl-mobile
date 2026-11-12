import 'package:shared_preferences/shared_preferences.dart';

/// Remembers that the first-launch tour and notification ask are finished.
class OnboardingStore {
  static const prefsKey = 'qaari_sl_onboarding_done';

  static Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  static Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
  }
}
