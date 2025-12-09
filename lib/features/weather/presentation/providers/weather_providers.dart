import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/openweather_api_client.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/datasources/weather_local_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/current_weather.dart';
import '../../domain/entities/forecast.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/constants.dart';

// API Client Provider
final openWeatherApiClientProvider = Provider<OpenWeatherApiClient>((ref) {
  return OpenWeatherApiClient();
});

// Data Sources Providers
final weatherRemoteDataSourceProvider =
    Provider<WeatherRemoteDataSource>((ref) {
  return WeatherRemoteDataSourceImpl(
    ref.watch(openWeatherApiClientProvider),
  );
});

final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>((ref) {
  return WeatherLocalDataSourceImpl(
    Hive.box('weather_cache'),
  );
});

// Repository Provider
final weatherRepositoryProvider = Provider<WeatherRepositoryImpl>((ref) {
  return WeatherRepositoryImpl(
    remoteDataSource: ref.watch(weatherRemoteDataSourceProvider),
    localDataSource: ref.watch(weatherLocalDataSourceProvider),
  );
});

// Current Weather State
class CurrentWeatherState {
  final bool isLoading;
  final CurrentWeather? weather;
  final Failure? error;

  CurrentWeatherState({
    this.isLoading = false,
    this.weather,
    this.error,
  });

  CurrentWeatherState copyWith({
    bool? isLoading,
    CurrentWeather? weather,
    Failure? error,
  }) {
    return CurrentWeatherState(
      isLoading: isLoading ?? this.isLoading,
      weather: weather ?? this.weather,
      error: error ?? this.error,
    );
  }
}

// Current Weather Notifier
class CurrentWeatherNotifier extends StateNotifier<CurrentWeatherState> {
  final WeatherRepositoryImpl repository;

  CurrentWeatherNotifier(this.repository) : super(CurrentWeatherState());

  Future<void> getWeatherByCity(String cityName) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.getCurrentWeatherByCity(cityName);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
      ),
      (weather) => state = state.copyWith(
        isLoading: false,
        weather: weather,
      ),
    );
  }

  Future<void> getWeatherByCoords(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.getCurrentWeatherByCoords(lat, lon);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
      ),
      (weather) => state = state.copyWith(
        isLoading: false,
        weather: weather,
      ),
    );
  }
}

final currentWeatherProvider =
    StateNotifierProvider<CurrentWeatherNotifier, CurrentWeatherState>((ref) {
  return CurrentWeatherNotifier(ref.watch(weatherRepositoryProvider));
});

// Forecast State
class ForecastState {
  final bool isLoading;
  final Forecast? forecast;
  final Failure? error;

  ForecastState({
    this.isLoading = false,
    this.forecast,
    this.error,
  });

  ForecastState copyWith({
    bool? isLoading,
    Forecast? forecast,
    Failure? error,
  }) {
    return ForecastState(
      isLoading: isLoading ?? this.isLoading,
      forecast: forecast ?? this.forecast,
      error: error ?? this.error,
    );
  }
}

// Forecast Notifier
class ForecastNotifier extends StateNotifier<ForecastState> {
  final WeatherRepositoryImpl repository;

  ForecastNotifier(this.repository) : super(ForecastState());

  Future<void> getForecastByCity(String cityName) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.getFiveDayForecastByCity(cityName);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
      ),
      (forecast) => state = state.copyWith(
        isLoading: false,
        forecast: forecast,
      ),
    );
  }

  Future<void> getForecastByCoords(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.getFiveDayForecastByCoords(lat, lon);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
      ),
      (forecast) => state = state.copyWith(
        isLoading: false,
        forecast: forecast,
      ),
    );
  }
}

final forecastProvider =
    StateNotifierProvider<ForecastNotifier, ForecastState>((ref) {
  return ForecastNotifier(ref.watch(weatherRepositoryProvider));
});

