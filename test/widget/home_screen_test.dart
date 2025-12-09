import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_master_pro/features/weather/presentation/screens/home_screen.dart';
import 'package:weather_master_pro/features/weather/presentation/providers/dashboard_provider.dart';
import 'package:weather_master_pro/features/weather/domain/entities/current_weather.dart';
import 'package:weather_master_pro/core/errors/failures.dart';
import 'package:weather_master_pro/features/settings/presentation/providers/settings_providers.dart';
import 'package:weather_master_pro/features/settings/domain/entities/app_settings.dart';
import 'package:weather_master_pro/features/alerts/presentation/providers/alerts_providers.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('should show loading indicator when loading', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          dashboardProvider.overrideWith(
            (ref) => DashboardNotifier(ref)
              ..state = DashboardState(isLoading: true),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(
              SettingsRepository(ref.read(settingsBoxProvider)),
            )..state = SettingsState(settings: const AppSettings()),
          ),
          alertsProvider.overrideWith(
            (ref) => AlertsNotifier(
              AlertsRepository(ref.read(alertsBoxProvider)),
            )..state = AlertsState(),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Loading weather data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should show error message when error occurs', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          dashboardProvider.overrideWith(
            (ref) => DashboardNotifier(ref)
              ..state = DashboardState(
                isLoading: false,
                error: ServerFailure('Network error'),
              ),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(
              SettingsRepository(ref.read(settingsBoxProvider)),
            )..state = SettingsState(settings: const AppSettings()),
          ),
          alertsProvider.overrideWith(
            (ref) => AlertsNotifier(
              AlertsRepository(ref.read(alertsBoxProvider)),
            )..state = AlertsState(),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show weather data when available', (tester) async {
      // Arrange
      final weather = CurrentWeather(
        cityName: 'London',
        temperature: 15.5,
        description: 'clear sky',
        icon: '01d',
        humidity: 65.0,
        windSpeed: 3.5,
        feelsLike: 14.0,
        pressure: 1013.0,
        visibility: 10000,
        dateTime: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          dashboardProvider.overrideWith(
            (ref) => DashboardNotifier(ref)
              ..state = DashboardState(
                isLoading: false,
                currentWeather: weather,
                selectedCity: 'London',
              ),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(
              SettingsRepository(ref.read(settingsBoxProvider)),
            )..state = SettingsState(settings: const AppSettings()),
          ),
          alertsProvider.overrideWith(
            (ref) => AlertsNotifier(
              AlertsRepository(ref.read(alertsBoxProvider)),
            )..state = AlertsState(),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('London'), findsWidgets);
      expect(find.text('CLEAR SKY'), findsOneWidget);
    });
  });
}

