import '../../domain/entities/current_weather.dart';

class CurrentWeatherModel extends CurrentWeather {
  const CurrentWeatherModel({
    required super.cityName,
    required super.temperature,
    required super.description,
    required super.icon,
    required super.humidity,
    required super.windSpeed,
    required super.feelsLike,
    required super.pressure,
    required super.visibility,
    required super.dateTime,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherModel(
      cityName: json['name'] ?? '',
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      description: json['weather']?[0]?['description'] ?? '',
      icon: json['weather']?[0]?['icon'] ?? '',
      humidity: (json['main']?['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']?['feels_like'] as num?)?.toDouble() ?? 0.0,
      pressure: (json['main']?['pressure'] as num?)?.toDouble() ?? 0.0,
      visibility: (json['visibility'] as num?)?.toInt() ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int?) ?? 0,
        isUtc: true,
      ).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'pressure': pressure,
        'humidity': humidity,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
        }
      ],
      'wind': {
        'speed': windSpeed,
      },
      'visibility': visibility,
      'dt': dateTime.millisecondsSinceEpoch,
    };
  }
}

