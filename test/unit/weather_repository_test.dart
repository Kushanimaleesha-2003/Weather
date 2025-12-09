import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_master_pro/core/network/openweather_api_client.dart';
import 'package:weather_master_pro/core/errors/exceptions.dart';
import 'package:weather_master_pro/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:weather_master_pro/features/weather/data/datasources/weather_local_datasource.dart';
import 'package:weather_master_pro/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:weather_master_pro/features/weather/data/models/current_weather_model.dart';
import 'package:weather_master_pro/features/weather/data/models/forecast_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MockOpenWeatherApiClient extends Mock implements OpenWeatherApiClient {}

class MockBox extends Mock implements Box {}

void main() {
  late WeatherRepositoryImpl repository;
  late MockOpenWeatherApiClient mockApiClient;
  late WeatherRemoteDataSource remoteDataSource;
  late WeatherLocalDataSource localDataSource;
  late MockBox mockBox;

  setUpAll(() async {
    await Hive.initFlutter();
  });

  setUp(() {
    mockApiClient = MockOpenWeatherApiClient();
    mockBox = MockBox();
    remoteDataSource = WeatherRemoteDataSourceImpl(mockApiClient);
    localDataSource = WeatherLocalDataSourceImpl(mockBox);
    repository = WeatherRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  });

  tearDown(() {
    reset(mockApiClient);
    reset(mockBox);
  });

  group('WeatherRepository - getCurrentWeatherByCity', () {
    test('should return CurrentWeather when API call is successful', () async {
      // Arrange
      const cityName = 'London';
      final mockWeatherJson = {
        'name': 'London',
        'main': {
          'temp': 15.5,
          'feels_like': 14.0,
          'pressure': 1013.0,
          'humidity': 65.0,
        },
        'weather': [
          {
            'description': 'clear sky',
            'icon': '01d',
          }
        ],
        'wind': {'speed': 3.5},
        'visibility': 10000,
        'dt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      final mockWeather = CurrentWeatherModel.fromJson(mockWeatherJson);

      when(() => mockApiClient.getCurrentWeatherByCity(cityName))
          .thenAnswer((_) async => mockWeather);
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      // Act
      final result = await repository.getCurrentWeatherByCity(cityName);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (weather) {
          expect(weather.cityName, 'London');
          expect(weather.temperature, 15.5);
          expect(weather.description, 'clear sky');
        },
      );

      verify(() => mockApiClient.getCurrentWeatherByCity(cityName)).called(1);
    });

    test('should return ServerFailure when API call fails', () async {
      // Arrange
      const cityName = 'InvalidCity';
      when(() => mockApiClient.getCurrentWeatherByCity(cityName))
          .thenThrow(ServerException('City not found'));
      when(() => mockBox.get(any())).thenReturn(null);

      // Act
      final result = await repository.getCurrentWeatherByCity(cityName);

      // Assert
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.toString(), contains('City not found'));
        },
        (weather) => fail('Should return failure'),
      );
    });

    test('should return cached data when API fails but cache exists', () async {
      // Arrange
      const cityName = 'London';
      final cachedData = {
        'data': {
          'name': 'London',
          'main': {
            'temp': 15.5,
            'feels_like': 14.0,
            'pressure': 1013.0,
            'humidity': 65.0,
          },
          'weather': [
            {
              'description': 'clear sky',
              'icon': '01d',
            }
          ],
          'wind': {'speed': 3.5},
          'visibility': 10000,
          'dt': DateTime.now().millisecondsSinceEpoch,
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      when(() => mockApiClient.getCurrentWeatherByCity(cityName))
          .thenThrow(ServerException('Network error'));
      when(() => mockBox.get('weather_$cityName')).thenReturn(cachedData);

      // Act
      final result = await repository.getCurrentWeatherByCity(cityName);

      // Assert
      result.fold(
        (failure) => fail('Should return cached data'),
        (weather) {
          expect(weather.cityName, 'London');
        },
      );
    });
  });

  group('WeatherRepository - getFiveDayForecastByCity', () {
    test('should return Forecast when API call is successful', () async {
      // Arrange
      const cityName = 'London';
      final mockForecastJson = {
        'city': {'name': 'London'},
        'list': [
          {
            'dt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
            'main': {
              'temp': 15.5,
              'temp_min': 12.0,
              'temp_max': 18.0,
              'humidity': 65.0,
            },
            'weather': [
              {
                'description': 'clear sky',
                'icon': '01d',
              }
            ],
            'wind': {'speed': 3.5},
          }
        ],
      };

      final mockForecast = ForecastModel.fromJson(mockForecastJson);

      when(() => mockApiClient.getFiveDayForecastByCity(cityName))
          .thenAnswer((_) async => mockForecast);

      // Act
      final result = await repository.getFiveDayForecastByCity(cityName);

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (forecast) {
          expect(forecast.cityName, 'London');
          expect(forecast.items.isNotEmpty, true);
        },
      );
    });

    test('should return ServerFailure when forecast API call fails', () async {
      // Arrange
      const cityName = 'InvalidCity';
      when(() => mockApiClient.getFiveDayForecastByCity(cityName))
          .thenThrow(ServerException('City not found'));

      // Act
      final result = await repository.getFiveDayForecastByCity(cityName);

      // Assert
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (forecast) => fail('Should return failure'),
      );
    });
  });
}

