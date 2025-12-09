import 'package:hive_flutter/hive_flutter.dart';
import '../models/current_weather_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';

abstract class WeatherLocalDataSource {
  Future<void> cacheWeather(String cityName, CurrentWeatherModel weather);
  Future<CurrentWeatherModel?> getCachedWeather(String cityName);
  Future<void> clearCache();
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final Box box;

  WeatherLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheWeather(
    String cityName,
    CurrentWeatherModel weather,
  ) async {
    try {
      await box.put(
        'weather_$cityName',
        {
          'data': weather.toJson(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      throw CacheException('Failed to cache weather: ${e.toString()}');
    }
  }

  @override
  Future<CurrentWeatherModel?> getCachedWeather(String cityName) async {
    try {
      final cached = box.get('weather_$cityName');
      if (cached == null) return null;

      final timestamp = cached['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiry = AppConstants.cacheExpiryHours * 60 * 60 * 1000;

      if (now - timestamp > expiry) {
        await box.delete('weather_$cityName');
        return null;
      }

      return CurrentWeatherModel.fromJson(cached['data']);
    } catch (e) {
      throw CacheException('Failed to get cached weather: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}

