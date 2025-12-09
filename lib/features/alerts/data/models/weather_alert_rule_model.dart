import '../../domain/entities/weather_alert_rule.dart';

class WeatherAlertRuleModel extends WeatherAlertRule {
  @override
  final String id;

  @override
  final String cityName;

  @override
  final AlertType type;

  @override
  final double? threshold;

  @override
  final String? message;

  @override
  final bool isActive;

  @override
  final DateTime createdAt;

  WeatherAlertRuleModel({
    required this.id,
    required this.cityName,
    required this.type,
    this.threshold,
    this.message,
    this.isActive = true,
    required this.createdAt,
  }) : super(
          id: id,
          cityName: cityName,
          type: type,
          threshold: threshold,
          message: message,
          isActive: isActive,
          createdAt: createdAt,
        );

  factory WeatherAlertRuleModel.fromEntity(WeatherAlertRule entity) {
    return WeatherAlertRuleModel(
      id: entity.id,
      cityName: entity.cityName,
      type: entity.type,
      threshold: entity.threshold,
      message: entity.message,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityName': cityName,
      'type': type.name,
      'threshold': threshold,
      'message': message,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory WeatherAlertRuleModel.fromJson(Map<String, dynamic> json) {
    return WeatherAlertRuleModel(
      id: json['id'] as String,
      cityName: json['cityName'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.rain,
      ),
      threshold: json['threshold'] as double?,
      message: json['message'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
      ),
    );
  }
}

