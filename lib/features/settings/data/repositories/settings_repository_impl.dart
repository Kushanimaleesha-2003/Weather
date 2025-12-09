import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/app_settings.dart';
import '../models/app_settings_model.dart';

class SettingsRepository {
  final Box box;
  static const String _settingsKey = 'app_settings';

  SettingsRepository(this.box);

  Future<void> saveSettings(AppSettings settings) async {
    final model = AppSettingsModel.fromEntity(settings);
    await box.put(_settingsKey, model.toJson());
  }

  AppSettings getSettings() {
    final json = box.get(_settingsKey);
    if (json == null || json is! Map) {
      return const AppSettings();
    }
    try {
      final model = AppSettingsModel.fromJson(
        Map<String, dynamic>.from(json),
      );
      return model;
    } catch (e) {
      return const AppSettings();
    }
  }

  Future<void> addRegion(String region) async {
    final settings = getSettings();
    if (!settings.regions.contains(region)) {
      final updated = settings.copyWith(
        regions: [...settings.regions, region],
      );
      await saveSettings(updated);
    }
  }

  Future<void> removeRegion(String region) async {
    final settings = getSettings();
    final updated = settings.copyWith(
      regions: settings.regions.where((r) => r != region).toList(),
    );
    await saveSettings(updated);
  }
}

