import 'package:equatable/equatable.dart';
import 'forecast_item.dart';

class Forecast extends Equatable {
  final String cityName;
  final List<ForecastItem> items;

  const Forecast({
    required this.cityName,
    required this.items,
  });

  @override
  List<Object> get props => [cityName, items];
}

