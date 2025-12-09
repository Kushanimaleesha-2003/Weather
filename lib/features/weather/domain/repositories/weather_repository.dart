import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/current_weather.dart';
import '../entities/forecast.dart';

/// Repository interface for weather data operations
/// 
/// This abstract class defines the contract for weather data retrieval.
/// Implementations should handle API calls, caching, and error handling.
abstract class WeatherRepository {
  Future<Either<Failure, CurrentWeather>> getCurrentWeatherByCity(
    String cityName,
  );
  Future<Either<Failure, CurrentWeather>> getCurrentWeatherByCoords(
    double lat,
    double lon,
  );
  Future<Either<Failure, Forecast>> getFiveDayForecastByCity(
    String cityName,
  );
  Future<Either<Failure, Forecast>> getFiveDayForecastByCoords(
    double lat,
    double lon,
  );
}

