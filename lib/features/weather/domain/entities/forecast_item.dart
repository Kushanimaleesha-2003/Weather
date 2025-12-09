import 'package:equatable/equatable.dart';

class ForecastItem extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;

  const ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  @override
  List<Object> get props => [
        dateTime,
        temperature,
        minTemp,
        maxTemp,
        description,
        icon,
        humidity,
        windSpeed,
      ];
}

