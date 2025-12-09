import 'package:equatable/equatable.dart';

class FavoriteCity extends Equatable {
  final String id;
  final String cityName;
  final String? region;
  final String? note;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  const FavoriteCity({
    required this.id,
    required this.cityName,
    this.region,
    this.note,
    required this.createdAt,
    this.lastUpdated,
  });

  FavoriteCity copyWith({
    String? id,
    String? cityName,
    String? region,
    String? note,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return FavoriteCity(
      id: id ?? this.id,
      cityName: cityName ?? this.cityName,
      region: region ?? this.region,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        cityName,
        region,
        note,
        createdAt,
        lastUpdated,
      ];
}

