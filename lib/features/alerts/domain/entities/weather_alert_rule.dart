import 'package:equatable/equatable.dart';

enum AlertType {
  rain,
  temperatureAbove,
  temperatureBelow,
  windSpeed,
}

class WeatherAlertRule extends Equatable {
  final String id;
  final String cityName;
  final AlertType type;
  final double? threshold;
  final String? message;
  final bool isActive;
  final DateTime createdAt;

  const WeatherAlertRule({
    required this.id,
    required this.cityName,
    required this.type,
    this.threshold,
    this.message,
    this.isActive = true,
    required this.createdAt,
  });

  WeatherAlertRule copyWith({
    String? id,
    String? cityName,
    AlertType? type,
    double? threshold,
    String? message,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return WeatherAlertRule(
      id: id ?? this.id,
      cityName: cityName ?? this.cityName,
      type: type ?? this.type,
      threshold: threshold ?? this.threshold,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cityName,
        type,
        threshold,
        message,
        isActive,
        createdAt,
      ];
}

