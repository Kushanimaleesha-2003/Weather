import 'package:equatable/equatable.dart';

enum TemperatureUnit {
  celsius,
  fahrenheit,
}

class AppSettings extends Equatable {
  final TemperatureUnit temperatureUnit;
  final bool isDarkMode;
  final List<String> regions;

  const AppSettings({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.isDarkMode = false,
    this.regions = const [],
  });

  AppSettings copyWith({
    TemperatureUnit? temperatureUnit,
    bool? isDarkMode,
    List<String>? regions,
  }) {
    return AppSettings(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      regions: regions ?? this.regions,
    );
  }

  @override
  List<Object> get props => [temperatureUnit, isDarkMode, regions];
}

