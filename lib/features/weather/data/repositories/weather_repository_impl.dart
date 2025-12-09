import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/entities/current_weather.dart';
import '../../domain/entities/forecast.dart';
import '../datasources/weather_remote_datasource.dart';
import '../datasources/weather_local_datasource.dart';

/// Implementation of WeatherRepository
/// 
/// Handles weather data retrieval from remote API and local cache.
/// Falls back to cached data when network requests fail.
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, CurrentWeather>> getCurrentWeatherByCity(
    String cityName,
  ) async {
    try {
      final weather = await remoteDataSource.getCurrentWeatherByCity(cityName);
      await localDataSource.cacheWeather(cityName, weather);
      return Right(weather);
    } on ServerException catch (e) {
      // Try to get cached data if available
      final cached = await localDataSource.getCachedWeather(cityName);
      if (cached != null) {
        return Right(cached);
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CurrentWeather>> getCurrentWeatherByCoords(
    double lat,
    double lon,
  ) async {
    try {
      final weather = await remoteDataSource.getCurrentWeatherByCoords(
        lat,
        lon,
      );
      return Right(weather);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Forecast>> getFiveDayForecastByCity(
    String cityName,
  ) async {
    try {
      final forecast = await remoteDataSource.getFiveDayForecastByCity(
        cityName,
      );
      return Right(forecast);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Forecast>> getFiveDayForecastByCoords(
    double lat,
    double lon,
  ) async {
    try {
      final forecast = await remoteDataSource.getFiveDayForecastByCoords(
        lat,
        lon,
      );
      return Right(forecast);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

