import 'package:flutter/material.dart';

class WeatherIcons {
  static String getWeatherIcon(String iconCode) {
    // Map OpenWeatherMap icon codes to emoji or icon names
    switch (iconCode) {
      case '01d': // clear sky day
        return '☀️';
      case '01n': // clear sky night
        return '🌙';
      case '02d': // few clouds day
        return '⛅';
      case '02n': // few clouds night
        return '☁️';
      case '03d':
      case '03n': // scattered clouds
        return '☁️';
      case '04d':
      case '04n': // broken clouds
        return '☁️';
      case '09d':
      case '09n': // shower rain
        return '🌧️';
      case '10d': // rain day
        return '🌦️';
      case '10n': // rain night
        return '🌧️';
      case '11d':
      case '11n': // thunderstorm
        return '⛈️';
      case '13d':
      case '13n': // snow
        return '❄️';
      case '50d':
      case '50n': // mist
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  static IconData getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'rain':
        return Icons.water_drop;
      case 'temperatureabove':
        return Icons.wb_sunny;
      case 'temperaturebelow':
        return Icons.ac_unit;
      case 'windspeed':
        return Icons.air;
      default:
        return Icons.notifications;
    }
  }
}

