import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_master_pro/core/utils/constants.dart';
import 'package:weather_master_pro/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:weather_master_pro/features/favorites/domain/entities/favorite_city.dart';
import 'package:weather_master_pro/features/favorites/data/models/favorite_city_model.dart';

void main() {
  late Box box;
  late FavoritesRepository repository;

  setUpAll(() async {
    await Hive.initFlutter();
  });

  setUp(() async {
    box = await Hive.openBox('test_favorites');
    repository = FavoritesRepository(box);
    await box.clear();
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  group('FavoritesRepository', () {
    test('should add a favorite city', () async {
      // Arrange
      final favorite = FavoriteCity(
        id: '1',
        cityName: 'London',
        createdAt: DateTime.now(),
      );

      // Act
      await repository.addFavorite(favorite);

      // Assert
      final favorites = repository.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.cityName, 'London');
    });

    test('should get all favorites', () async {
      // Arrange
      final favorite1 = FavoriteCity(
        id: '1',
        cityName: 'London',
        createdAt: DateTime.now(),
      );
      final favorite2 = FavoriteCity(
        id: '2',
        cityName: 'Paris',
        createdAt: DateTime.now(),
      );

      // Act
      await repository.addFavorite(favorite1);
      await repository.addFavorite(favorite2);

      // Assert
      final favorites = repository.getFavorites();
      expect(favorites.length, 2);
      expect(favorites.map((f) => f.cityName), containsAll(['London', 'Paris']));
    });

    test('should update a favorite city', () async {
      // Arrange
      final favorite = FavoriteCity(
        id: '1',
        cityName: 'London',
        createdAt: DateTime.now(),
      );
      await repository.addFavorite(favorite);

      // Act
      final updated = favorite.copyWith(
        cityName: 'London, UK',
        region: 'Europe',
      );
      await repository.updateFavorite(updated);

      // Assert
      final favorites = repository.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.cityName, 'London, UK');
      expect(favorites.first.region, 'Europe');
    });

    test('should delete a favorite city', () async {
      // Arrange
      final favorite1 = FavoriteCity(
        id: '1',
        cityName: 'London',
        createdAt: DateTime.now(),
      );
      final favorite2 = FavoriteCity(
        id: '2',
        cityName: 'Paris',
        createdAt: DateTime.now(),
      );
      await repository.addFavorite(favorite1);
      await repository.addFavorite(favorite2);

      // Act
      await repository.deleteFavorite('1');

      // Assert
      final favorites = repository.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.cityName, 'Paris');
    });

    test('should filter favorites by region', () async {
      // Arrange
      final favorite1 = FavoriteCity(
        id: '1',
        cityName: 'London',
        region: 'Europe',
        createdAt: DateTime.now(),
      );
      final favorite2 = FavoriteCity(
        id: '2',
        cityName: 'Tokyo',
        region: 'Asia',
        createdAt: DateTime.now(),
      );
      final favorite3 = FavoriteCity(
        id: '3',
        cityName: 'Paris',
        region: 'Europe',
        createdAt: DateTime.now(),
      );

      await repository.addFavorite(favorite1);
      await repository.addFavorite(favorite2);
      await repository.addFavorite(favorite3);

      // Act
      final europeanCities = repository.getFavoritesByRegion('Europe');

      // Assert
      expect(europeanCities.length, 2);
      expect(europeanCities.map((f) => f.cityName), containsAll(['London', 'Paris']));
    });
  });
}

