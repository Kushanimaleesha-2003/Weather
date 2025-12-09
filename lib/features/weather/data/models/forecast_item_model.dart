import '../../domain/entities/forecast_item.dart';

class ForecastItemModel extends ForecastItem {
  const ForecastItemModel({
    required super.dateTime,
    required super.temperature,
    required super.minTemp,
    required super.maxTemp,
    required super.description,
    required super.icon,
    required super.humidity,
    required super.windSpeed,
  });

  factory ForecastItemModel.fromJson(Map<String, dynamic> json) {
    return ForecastItemModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int?) ?? 0,
        isUtc: true,
      ).toLocal(),
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      minTemp: (json['main']?['temp_min'] as num?)?.toDouble() ?? 0.0,
      maxTemp: (json['main']?['temp_max'] as num?)?.toDouble() ?? 0.0,
      description: json['weather']?[0]?['description'] ?? '',
      icon: json['weather']?[0]?['icon'] ?? '',
      humidity: (json['main']?['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

