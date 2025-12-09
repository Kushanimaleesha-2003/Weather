import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../errors/exceptions.dart';
import '../../features/weather/data/models/current_weather_model.dart';
import '../../features/weather/data/models/forecast_model.dart';

class OpenWeatherApiClient {
  late final Dio _dio;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  OpenWeatherApiClient() {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('ERROR: OPENWEATHER_API_KEY not found in .env file');
      throw Exception('OPENWEATHER_API_KEY not found in .env file');
    }
    
    print('API Key loaded: ${apiKey.substring(0, 8)}...'); // Debug: show first 8 chars

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        queryParameters: {
          'appid': apiKey,
          'units': 'metric',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  /// Fetches current weather data for a given city name
  /// 
  /// Throws [ServerException] if the API call fails
  Future<CurrentWeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      print('Fetching weather for city: $cityName');
      final response = await _dio.get(
        '/weather',
        queryParameters: {'q': cityName},
      );
      print('Weather API response received for $cityName');
      return CurrentWeatherModel.fromJson(response.data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['message'] ?? 
          'Failed to fetch weather data for $cityName';
      
      print('API Error for $cityName: Status $statusCode - $errorMessage');
      
      if (statusCode == 401) {
        throw ServerException('Invalid API key. Please check your .env file.');
      } else if (statusCode == 404) {
        throw ServerException('City "$cityName" not found. Please try another city.');
      } else if (statusCode == 429) {
        throw ServerException('API rate limit exceeded. Please try again later.');
      }
      
      throw ServerException(errorMessage);
    } catch (e) {
      print('Unexpected error for $cityName: ${e.toString()}');
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// Fetches current weather data using latitude and longitude coordinates
  /// 
  /// Throws [ServerException] if the API call fails
  Future<CurrentWeatherModel> getCurrentWeatherByCoords(
    double lat,
    double lon,
  ) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
        },
      );
      return CurrentWeatherModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 
          'Failed to fetch weather data for coordinates';
      throw ServerException(errorMessage);
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// Fetches 5-day weather forecast for a given city name
  /// 
  /// Throws [ServerException] if the API call fails
  Future<ForecastModel> getFiveDayForecastByCity(String cityName) async {
    try {
      print('Fetching forecast for city: $cityName');
      final response = await _dio.get(
        '/forecast',
        queryParameters: {'q': cityName},
      );
      print('Forecast API response received for $cityName');
      return ForecastModel.fromJson(response.data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['message'] ?? 
          'Failed to fetch forecast data for $cityName';
      
      print('Forecast API Error for $cityName: Status $statusCode - $errorMessage');
      
      if (statusCode == 401) {
        throw ServerException('Invalid API key. Please check your .env file.');
      } else if (statusCode == 404) {
        throw ServerException('City "$cityName" not found. Please try another city.');
      } else if (statusCode == 429) {
        throw ServerException('API rate limit exceeded. Please try again later.');
      }
      
      throw ServerException(errorMessage);
    } catch (e) {
      print('Unexpected forecast error for $cityName: ${e.toString()}');
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// Fetches 5-day weather forecast using latitude and longitude coordinates
  /// 
  /// Throws [ServerException] if the API call fails
  Future<ForecastModel> getFiveDayForecastByCoords(
    double lat,
    double lon,
  ) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
        },
      );
      return ForecastModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 
          'Failed to fetch forecast data for coordinates';
      throw ServerException(errorMessage);
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}

