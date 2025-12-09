import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/current_weather.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeatherByCity {
  final WeatherRepository repository;

  GetCurrentWeatherByCity(this.repository);

  Future<Either<Failure, CurrentWeather>> call(String cityName) async {
    return await repository.getCurrentWeatherByCity(cityName);
  }
}

