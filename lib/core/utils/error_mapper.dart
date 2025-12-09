import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Maps various error types to user-friendly Failure objects
class ErrorMapper {
  /// Maps DioException to ServerFailure
  static Failure mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return ServerFailure('City not found. Please try another city name.');
        } else if (statusCode == 401) {
          return ServerFailure('API key is invalid. Please check your configuration.');
        }
        return ServerFailure(
          error.response?.data?['message'] ?? 'Server error occurred.',
        );
      case DioExceptionType.cancel:
        return ServerFailure('Request was cancelled.');
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return ServerFailure('Unable to reach server. Please check your connection.');
        }
        return ServerFailure('An unexpected error occurred.');
      default:
        return ServerFailure('Network error occurred.');
    }
  }

  /// Maps generic exceptions to appropriate failures
  static Failure mapException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    if (exception is CacheException) {
      return CacheFailure(exception.message);
    }
    if (exception is LocationException) {
      return LocationFailure(exception.message);
    }
    return ServerFailure(exception.toString());
  }
}

