import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/app_settings.dart';
import '../../data/repositories/settings_repository_impl.dart';

// Hive Box Provider
final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.settingsBox);
});

// Repository Provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(settingsBoxProvider));
});

// Settings State
class SettingsState {
  final AppSettings settings;
  final bool isLoading;
  final String? error;

  SettingsState({
    required this.settings,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Settings Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository repository;

  SettingsNotifier(this.repository)
      : super(SettingsState(settings: const AppSettings())) {
    loadSettings();
  }

  void loadSettings() {
    try {
      final settings = repository.getSettings();
      state = state.copyWith(settings: settings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      await repository.saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleTemperatureUnit() async {
    final newUnit = state.settings.temperatureUnit == TemperatureUnit.celsius
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
    await updateSettings(state.settings.copyWith(temperatureUnit: newUnit));
  }

  Future<void> toggleTheme() async {
    await updateSettings(
      state.settings.copyWith(isDarkMode: !state.settings.isDarkMode),
    );
  }

  Future<void> addRegion(String region) async {
    await repository.addRegion(region);
    loadSettings();
  }

  Future<void> removeRegion(String region) async {
    await repository.removeRegion(region);
    loadSettings();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

