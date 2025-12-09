import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_master_pro/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:weather_master_pro/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:weather_master_pro/features/favorites/domain/entities/favorite_city.dart';
import 'package:weather_master_pro/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:weather_master_pro/features/settings/presentation/providers/settings_providers.dart';
import 'package:weather_master_pro/features/settings/domain/entities/app_settings.dart';
import 'package:weather_master_pro/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:weather_master_pro/core/utils/constants.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();
  });

  group('FavoritesScreen Widget Tests', () {
    testWidgets('should show empty state when no favorites', (tester) async {
      // Arrange
      final favoritesBox = await Hive.openBox(AppConstants.favoritesBox);
      final settingsBox = await Hive.openBox(AppConstants.settingsBox);
      
      final container = ProviderContainer(
        overrides: [
          favoritesBoxProvider.overrideWith((ref) => favoritesBox),
          settingsBoxProvider.overrideWith((ref) => settingsBox),
          favoritesProvider.overrideWith(
            (ref) => FavoritesNotifier(
              FavoritesRepository(ref.read(favoritesBoxProvider)),
            )..state = FavoritesState(favorites: []),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(
              SettingsRepository(ref.read(settingsBoxProvider)),
            )..state = SettingsState(settings: const AppSettings()),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FavoritesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No favorite cities yet'), findsOneWidget);
      expect(find.text('Add cities from search or home screen'), findsOneWidget);
    });

    testWidgets('should show list of favorites when available', (tester) async {
      // Arrange
      final favoritesBox = await Hive.openBox(AppConstants.favoritesBox);
      final settingsBox = await Hive.openBox(AppConstants.settingsBox);
      
      final favorites = [
        FavoriteCity(
          id: '1',
          cityName: 'London',
          createdAt: DateTime.now(),
        ),
        FavoriteCity(
          id: '2',
          cityName: 'Paris',
          createdAt: DateTime.now(),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          favoritesBoxProvider.overrideWith((ref) => favoritesBox),
          settingsBoxProvider.overrideWith((ref) => settingsBox),
          favoritesProvider.overrideWith(
            (ref) => FavoritesNotifier(
              FavoritesRepository(ref.read(favoritesBoxProvider)),
            )..state = FavoritesState(favorites: favorites),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(
              SettingsRepository(ref.read(settingsBoxProvider)),
            )..state = SettingsState(settings: const AppSettings()),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FavoritesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('London'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
    });
  });
}

