import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/current_weather.dart';
import '../../domain/entities/forecast.dart';
import 'weather_providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/location_helper.dart';

/// State class for the weather dashboard
/// 
/// Contains current weather, forecast, selected city, and loading/error states
class DashboardState {
  final CurrentWeather? currentWeather;
  final Forecast? forecast;
  final String? selectedCity;
  final Position? currentPosition;
  final bool isLoading;
  final Failure? error;
  final bool isOffline;

  DashboardState({
    this.currentWeather,
    this.forecast,
    this.selectedCity,
    this.currentPosition,
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  DashboardState copyWith({
    CurrentWeather? currentWeather,
    Forecast? forecast,
    String? selectedCity,
    Position? currentPosition,
    bool? isLoading,
    Failure? error,
    bool? isOffline,
  }) {
    return DashboardState(
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      selectedCity: selectedCity ?? this.selectedCity,
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

/// StateNotifier for managing dashboard state
/// 
/// Handles loading weather data by city name or location coordinates.
/// Manages loading, success, and error states.
class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref ref;

  DashboardNotifier(this.ref) : super(DashboardState());

  Future<void> loadWeatherByCity(String cityName) async {
    try {
      state = state.copyWith(isLoading: true, error: null, selectedCity: cityName);
      print('Loading weather for city: $cityName');
      
      final weatherResult = await ref.read(weatherRepositoryProvider)
          .getCurrentWeatherByCity(cityName);
      final forecastResult = await ref.read(weatherRepositoryProvider)
          .getFiveDayForecastByCity(cityName);

      weatherResult.fold(
        (failure) {
          print('Weather error for $cityName: ${failure.toString()}');
          state = state.copyWith(
            isLoading: false,
            error: failure,
            isOffline: true,
          );
        },
        (weather) {
          forecastResult.fold(
            (failure) {
              print('Forecast error for $cityName: ${failure.toString()}');
              // Still show current weather even if forecast fails
              state = state.copyWith(
                isLoading: false,
                currentWeather: weather,
                error: null, // Don't show error if we have current weather
                isOffline: false,
              );
            },
            (forecast) {
              print('Successfully loaded weather and forecast for $cityName');
              state = state.copyWith(
                isLoading: false,
                currentWeather: weather,
                forecast: forecast,
                isOffline: false,
              );
            },
          );
        },
      );
    } catch (e) {
      print('Unexpected error loading weather for $cityName: $e');
      state = state.copyWith(
        isLoading: false,
        error: ServerFailure('Failed to load weather: ${e.toString()}'),
      );
    }
  }

  Future<void> loadWeatherByLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Check location service enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Fallback to default city if location service is disabled
        print('Location service disabled, loading London');
        await loadWeatherByCity('London');
        return;
      }

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Fallback to default city if permission denied
          print('Location permission denied, loading London');
          await loadWeatherByCity('London');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Fallback to default city if permission permanently denied
        print('Location permission permanently denied, loading London');
        await loadWeatherByCity('London');
        return;
      }
      
      // Get current position with shorter timeout for emulator
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // Use low accuracy for faster response
        timeLimit: const Duration(seconds: 8), // Reduced timeout
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw TimeoutException('Location request timed out', const Duration(seconds: 8));
        },
      );

      state = state.copyWith(currentPosition: position);

      // Fetch weather data
      final weatherResult = await ref.read(weatherRepositoryProvider)
          .getCurrentWeatherByCoords(position.latitude, position.longitude);
      final forecastResult = await ref.read(weatherRepositoryProvider)
          .getFiveDayForecastByCoords(position.latitude, position.longitude);

      weatherResult.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure,
            isOffline: true,
          );
        },
        (weather) {
          forecastResult.fold(
            (failure) {
              state = state.copyWith(
                isLoading: false,
                currentWeather: weather,
                error: failure,
                isOffline: true,
              );
            },
            (forecast) {
              state = state.copyWith(
                isLoading: false,
                currentWeather: weather,
                forecast: forecast,
                selectedCity: weather.cityName,
                isOffline: false,
              );
            },
          );
        },
      );
    } on TimeoutException catch (e) {
      // Location timeout - fallback to default city immediately
      print('Location timeout: $e, loading London');
      try {
        await loadWeatherByCity('London');
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
        state = state.copyWith(
          isLoading: false,
          error: LocationFailure('Location unavailable. Please search for a city.'),
        );
      }
    } catch (e) {
      // If location fails, try loading default city
      print('Location error: $e, loading London');
      try {
        await loadWeatherByCity('London');
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
        state = state.copyWith(
          isLoading: false,
          error: LocationFailure('Failed to get location. Please check your connection or try searching for a city.'),
        );
      }
    }
  }

  Future<void> refresh() async {
    if (state.selectedCity != null) {
      await loadWeatherByCity(state.selectedCity!);
    } else if (state.currentPosition != null) {
      await loadWeatherByLocation();
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});

