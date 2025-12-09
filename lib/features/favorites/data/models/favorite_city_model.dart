import '../../domain/entities/favorite_city.dart';

class FavoriteCityModel extends FavoriteCity {
  @override
  final String id;

  @override
  final String cityName;

  @override
  final String? region;

  @override
  final String? note;

  @override
  final DateTime createdAt;

  @override
  final DateTime? lastUpdated;

  FavoriteCityModel({
    required this.id,
    required this.cityName,
    this.region,
    this.note,
    required this.createdAt,
    this.lastUpdated,
  }) : super(
          id: id,
          cityName: cityName,
          region: region,
          note: note,
          createdAt: createdAt,
          lastUpdated: lastUpdated,
        );

  factory FavoriteCityModel.fromEntity(FavoriteCity entity) {
    return FavoriteCityModel(
      id: entity.id,
      cityName: entity.cityName,
      region: entity.region,
      note: entity.note,
      createdAt: entity.createdAt,
      lastUpdated: entity.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityName': cityName,
      'region': region,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  factory FavoriteCityModel.fromJson(Map<String, dynamic> json) {
    return FavoriteCityModel(
      id: json['id'] as String,
      cityName: json['cityName'] as String,
      region: json['region'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
      ),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int)
          : null,
    );
  }
}

