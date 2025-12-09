import '../../domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  @override
  final TemperatureUnit temperatureUnit;

  @override
  final bool isDarkMode;

  @override
  final List<String> regions;

  AppSettingsModel({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.isDarkMode = false,
    this.regions = const [],
  }) : super(
          temperatureUnit: temperatureUnit,
          isDarkMode: isDarkMode,
          regions: regions,
        );

  factory AppSettingsModel.fromEntity(AppSettings entity) {
    return AppSettingsModel(
      temperatureUnit: entity.temperatureUnit,
      isDarkMode: entity.isDarkMode,
      regions: List.from(entity.regions),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatureUnit': temperatureUnit.name,
      'isDarkMode': isDarkMode,
      'regions': regions,
    };
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      temperatureUnit: TemperatureUnit.values.firstWhere(
        (e) => e.name == json['temperatureUnit'],
        orElse: () => TemperatureUnit.celsius,
      ),
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      regions: (json['regions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

