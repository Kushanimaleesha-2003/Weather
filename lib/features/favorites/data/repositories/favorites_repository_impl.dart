import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/favorite_city.dart';
import '../models/favorite_city_model.dart';

/// Repository for managing favorite cities
/// 
/// Provides CRUD operations for favorite cities stored in Hive.
/// Supports filtering by region tags.
class FavoritesRepository {
  final Box box;

  FavoritesRepository(this.box);

  Future<void> addFavorite(FavoriteCity city) async {
    final model = FavoriteCityModel.fromEntity(city);
    await box.put(city.id, model.toJson());
  }

  List<FavoriteCity> getFavorites() {
    final favorites = <FavoriteCity>[];
    for (var key in box.keys) {
      final json = box.get(key);
      if (json != null && json is Map) {
        try {
          final model = FavoriteCityModel.fromJson(
            Map<String, dynamic>.from(json),
          );
          favorites.add(model);
        } catch (e) {
          // Skip invalid entries
        }
      }
    }
    return favorites;
  }

  Future<void> updateFavorite(FavoriteCity city) async {
    final model = FavoriteCityModel.fromEntity(city);
    await box.put(city.id, model.toJson());
  }

  Future<void> deleteFavorite(String id) async {
    await box.delete(id);
  }

  List<FavoriteCity> getFavoritesByRegion(String? region) {
    if (region == null) {
      return getFavorites();
    }
    return getFavorites().where((city) => city.region == region).toList();
  }
}

