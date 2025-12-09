import '../../../../core/network/openweather_api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/current_weather_model.dart';
import '../models/forecast_model.dart';

abstract class WeatherRemoteDataSource {
  Future<CurrentWeatherModel> getCurrentWeatherByCity(String cityName);
  Future<CurrentWeatherModel> getCurrentWeatherByCoords(
    double lat,
    double lon,
  );
  Future<ForecastModel> getFiveDayForecastByCity(String cityName);
  Future<ForecastModel> getFiveDayForecastByCoords(double lat, double lon);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final OpenWeatherApiClient apiClient;

  WeatherRemoteDataSourceImpl(this.apiClient);

  @override
  Future<CurrentWeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      return await apiClient.getCurrentWeatherByCity(cityName);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CurrentWeatherModel> getCurrentWeatherByCoords(
    double lat,
    double lon,
  ) async {
    try {
      return await apiClient.getCurrentWeatherByCoords(lat, lon);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ForecastModel> getFiveDayForecastByCity(String cityName) async {
    try {
      return await apiClient.getFiveDayForecastByCity(cityName);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ForecastModel> getFiveDayForecastByCoords(
    double lat,
    double lon,
  ) async {
    try {
      return await apiClient.getFiveDayForecastByCoords(lat, lon);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

