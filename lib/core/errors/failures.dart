import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// 
/// All failures should extend this class to provide consistent error handling
abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  /// User-friendly error message
  String get userMessage;

  @override
  List<Object> get props => [];
}

/// Failure representing server/API errors
class ServerFailure extends Failure {
  final String message;

  const ServerFailure(this.message);

  @override
  String get userMessage {
    if (message.toLowerCase().contains('timeout') ||
        message.toLowerCase().contains('connection')) {
      return 'Unable to reach server. Please check your connection.';
    }
    if (message.toLowerCase().contains('not found') ||
        message.toLowerCase().contains('404')) {
      return 'City not found. Please try another city name.';
    }
    if (message.toLowerCase().contains('401') ||
        message.toLowerCase().contains('unauthorized')) {
      return 'API key is invalid. Please check your configuration.';
    }
    return 'Failed to fetch weather data. Please try again.';
  }

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

/// Failure representing cache/storage errors
class CacheFailure extends Failure {
  final String message;

  const CacheFailure(this.message);

  @override
  String get userMessage => 'Failed to save or load cached data.';

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

/// Failure representing location/GPS errors
class LocationFailure extends Failure {
  final String message;

  const LocationFailure(this.message);

  @override
  String get userMessage {
    if (message.toLowerCase().contains('permission')) {
      return 'Location permission denied. Please enable location access in settings.';
    }
    if (message.toLowerCase().contains('disabled')) {
      return 'Location services are disabled. Please enable them in settings.';
    }
    return 'Unable to get your location. Please try searching for a city instead.';
  }

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

