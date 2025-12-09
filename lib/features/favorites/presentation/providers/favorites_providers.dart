import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/favorite_city.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/search_history_repository.dart';

// Hive Box Provider
final favoritesBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.favoritesBox);
});

final searchHistoryBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.searchHistoryBox);
});

// Repositories Providers
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(favoritesBoxProvider));
});

final searchHistoryRepositoryProvider =
    Provider<SearchHistoryRepository>((ref) {
  return SearchHistoryRepository(ref.watch(searchHistoryBoxProvider));
});

// Favorites State
class FavoritesState {
  final List<FavoriteCity> favorites;
  final bool isLoading;
  final String? error;

  FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<FavoriteCity>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Favorites Notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesRepository repository;

  FavoritesNotifier(this.repository) : super(FavoritesState()) {
    loadFavorites();
  }

  void loadFavorites() {
    try {
      final favorites = repository.getFavorites();
      state = state.copyWith(favorites: favorites);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addFavorite(FavoriteCity city) async {
    try {
      await repository.addFavorite(city);
      loadFavorites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateFavorite(FavoriteCity city) async {
    try {
      await repository.updateFavorite(city);
      loadFavorites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteFavorite(String id) async {
    try {
      await repository.deleteFavorite(id);
      loadFavorites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<FavoriteCity> getFavoritesByRegion(String? region) {
    return repository.getFavoritesByRegion(region);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
});

// Search History State
class SearchHistoryState {
  final List<String> history;

  SearchHistoryState({this.history = const []});
}

// Search History Notifier
class SearchHistoryNotifier extends StateNotifier<SearchHistoryState> {
  final SearchHistoryRepository repository;

  SearchHistoryNotifier(this.repository)
      : super(SearchHistoryState()) {
    loadHistory();
  }

  void loadHistory() {
    final history = repository.getSearchHistory();
    state = SearchHistoryState(history: history);
  }

  Future<void> addSearch(String cityName) async {
    await repository.addSearch(cityName);
    loadHistory();
  }

  Future<void> clearHistory() async {
    await repository.clearSearchHistory();
    loadHistory();
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, SearchHistoryState>((ref) {
  return SearchHistoryNotifier(ref.watch(searchHistoryRepositoryProvider));
});

