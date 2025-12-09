import '../../domain/entities/forecast.dart';
import 'forecast_item_model.dart';

class ForecastModel extends Forecast {
  const ForecastModel({
    required super.cityName,
    required super.items,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final List<ForecastItemModel> items = [];
    if (json['list'] != null) {
      for (var item in json['list']) {
        items.add(ForecastItemModel.fromJson(item));
      }
    }

    return ForecastModel(
      cityName: json['city']?['name'] ?? '',
      items: items,
    );
  }
}

