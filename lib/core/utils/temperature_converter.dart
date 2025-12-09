import '../../features/settings/domain/entities/app_settings.dart';

class TemperatureConverter {
  static double convertToDisplay(
    double celsius,
    TemperatureUnit unit,
  ) {
    if (unit == TemperatureUnit.fahrenheit) {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  static String getUnitSymbol(TemperatureUnit unit) {
    return unit == TemperatureUnit.fahrenheit ? '°F' : '°C';
  }

  static String formatTemperature(
    double celsius,
    TemperatureUnit unit,
  ) {
    final temp = convertToDisplay(celsius, unit);
    return '${temp.toStringAsFixed(1)}${getUnitSymbol(unit)}';
  }
}

