import 'package:equatable/equatable.dart';

/// Domain entity representing current weather data for a location
/// 
/// This entity contains all the essential weather information including
/// temperature, description, humidity, wind speed, and other meteorological data
class CurrentWeather extends Equatable {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final double feelsLike;
  final double pressure;
  final int visibility;
  final DateTime dateTime;

  const CurrentWeather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.pressure,
    required this.visibility,
    required this.dateTime,
  });

  @override
  List<Object> get props => [
        cityName,
        temperature,
        description,
        icon,
        humidity,
        windSpeed,
        feelsLike,
        pressure,
        visibility,
        dateTime,
      ];
}

