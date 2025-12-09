import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

class HiveInit {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return; // Already initialized
    }

    await Hive.initFlutter();

    // Open boxes (safe to call multiple times - Hive will return existing box if already open)
    if (!Hive.isBoxOpen(AppConstants.favoritesBox)) {
      await Hive.openBox(AppConstants.favoritesBox);
    }
    if (!Hive.isBoxOpen(AppConstants.alertsBox)) {
      await Hive.openBox(AppConstants.alertsBox);
    }
    if (!Hive.isBoxOpen(AppConstants.settingsBox)) {
      await Hive.openBox(AppConstants.settingsBox);
    }
    if (!Hive.isBoxOpen(AppConstants.searchHistoryBox)) {
      await Hive.openBox(AppConstants.searchHistoryBox);
    }
    if (!Hive.isBoxOpen('weather_cache')) {
      await Hive.openBox('weather_cache');
    }

    _initialized = true;
  }
}

