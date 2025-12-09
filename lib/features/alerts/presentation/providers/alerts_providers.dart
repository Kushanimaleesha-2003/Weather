import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/weather_alert_rule.dart';
import '../../data/repositories/alerts_repository_impl.dart';

// Hive Box Provider
final alertsBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.alertsBox);
});

// Repository Provider
final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(ref.watch(alertsBoxProvider));
});

// Alerts State
class AlertsState {
  final List<WeatherAlertRule> rules;
  final bool isLoading;
  final String? error;

  AlertsState({
    this.rules = const [],
    this.isLoading = false,
    this.error,
  });

  AlertsState copyWith({
    List<WeatherAlertRule>? rules,
    bool? isLoading,
    String? error,
  }) {
    return AlertsState(
      rules: rules ?? this.rules,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Alerts Notifier
class AlertsNotifier extends StateNotifier<AlertsState> {
  final AlertsRepository repository;

  AlertsNotifier(this.repository) : super(AlertsState()) {
    loadAlerts();
  }

  void loadAlerts() {
    try {
      final rules = repository.getAlertRules();
      state = state.copyWith(rules: rules);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addAlertRule(WeatherAlertRule rule) async {
    try {
      await repository.addAlertRule(rule);
      loadAlerts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateAlertRule(WeatherAlertRule rule) async {
    try {
      await repository.updateAlertRule(rule);
      loadAlerts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteAlertRule(String id) async {
    try {
      await repository.deleteAlertRule(id);
      loadAlerts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  return AlertsNotifier(ref.watch(alertsRepositoryProvider));
});

