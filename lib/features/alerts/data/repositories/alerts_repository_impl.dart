import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/weather_alert_rule.dart';
import '../models/weather_alert_rule_model.dart';

class AlertsRepository {
  final Box box;

  AlertsRepository(this.box);

  Future<void> addAlertRule(WeatherAlertRule rule) async {
    final model = WeatherAlertRuleModel.fromEntity(rule);
    await box.put(rule.id, model.toJson());
  }

  List<WeatherAlertRule> getAlertRules() {
    final rules = <WeatherAlertRule>[];
    for (var key in box.keys) {
      final json = box.get(key);
      if (json != null && json is Map) {
        try {
          final model = WeatherAlertRuleModel.fromJson(
            Map<String, dynamic>.from(json),
          );
          if (model.isActive) {
            rules.add(model);
          }
        } catch (e) {
          // Skip invalid entries
        }
      }
    }
    return rules;
  }

  Future<void> updateAlertRule(WeatherAlertRule rule) async {
    final model = WeatherAlertRuleModel.fromEntity(rule);
    await box.put(rule.id, model.toJson());
  }

  Future<void> deleteAlertRule(String id) async {
    await box.delete(id);
  }
}

