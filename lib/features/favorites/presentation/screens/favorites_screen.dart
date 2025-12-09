import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/temperature_converter.dart';
import '../../../../core/utils/weather_icons.dart';
import '../../../../router/app_router.dart';
import '../providers/favorites_providers.dart';
import '../../domain/entities/favorite_city.dart';
import '../../../weather/presentation/providers/dashboard_provider.dart';
import '../../../weather/presentation/providers/weather_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../weather/domain/entities/current_weather.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoritesProvider);
    final settings = ref.watch(settingsProvider).settings;
    final regions = settings.regions;

    List<FavoriteCity> favorites = _selectedRegion == null
        ? favoritesState.favorites
        : favoritesState.favorites
            .where((f) => f.region == _selectedRegion)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Cities'),
        actions: [
          if (regions.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                setState(() {
                  _selectedRegion = value == 'all' ? null : value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('All Regions'),
                ),
                ...regions.map((region) => PopupMenuItem(
                      value: region,
                      child: Text(region),
                    )),
              ],
            ),
        ],
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite cities yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add cities from search or home screen',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return _FavoriteCityCard(
                  favorite: favorite,
                  settings: settings,
                  onTap: () async {
                    await ref
                        .read(dashboardProvider.notifier)
                        .loadWeatherByCity(favorite.cityName);
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  onEdit: () => _showEditDialog(favorite),
                  onDelete: () => _showDeleteDialog(favorite),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFavoriteDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Current City'),
      ),
    );
  }

  Future<void> _showAddFavoriteDialog() async {
    final dashboard = ref.read(dashboardProvider);
    final cityName = dashboard.selectedCity ?? dashboard.currentWeather?.cityName;

    if (cityName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No city selected'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final favorite = FavoriteCity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cityName: cityName,
      createdAt: DateTime.now(),
    );

    await ref.read(favoritesProvider.notifier).addFavorite(favorite);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$cityName added to favorites'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showEditDialog(FavoriteCity favorite) async {
    final nameController = TextEditingController(text: favorite.cityName);
    final regionController = TextEditingController(text: favorite.region ?? '');
    final noteController = TextEditingController(text: favorite.note ?? '');
    final settings = ref.read(settingsProvider).settings;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Favorite'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'City Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: regionController,
                decoration: InputDecoration(
                  labelText: 'Region',
                  hintText: 'e.g., Asia, Europe',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = favorite.copyWith(
                cityName: nameController.text.trim(),
                region: regionController.text.trim().isEmpty
                    ? null
                    : regionController.text.trim(),
                note: noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
              );

              await ref.read(favoritesProvider.notifier).updateFavorite(updated);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Favorite updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(FavoriteCity favorite) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Favorite'),
        content: Text('Remove ${favorite.cityName} from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(favoritesProvider.notifier).deleteFavorite(favorite.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.cityName} removed from favorites'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

class _FavoriteCityCard extends ConsumerWidget {
  final FavoriteCity favorite;
  final dynamic settings;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FavoriteCityCard({
    required this.favorite,
    required this.settings,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<CurrentWeather?>(
      future: _getWeatherData(ref),
      builder: (context, snapshot) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.location_city, color: Colors.blue),
            ),
            title: Text(
              favorite.cityName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (favorite.region != null)
                  Text(
                    favorite.region!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (snapshot.hasData)
                  Text(
                    TemperatureConverter.formatTemperature(
                      snapshot.data!.temperature,
                      settings.temperatureUnit,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (snapshot.connectionState == ConnectionState.waiting)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
            ),
            onTap: onTap,
            onLongPress: onEdit,
          ),
        );
      },
    );
  }

  Future<CurrentWeather?> _getWeatherData(WidgetRef ref) async {
    try {
      final result = await ref
          .read(weatherRepositoryProvider)
          .getCurrentWeatherByCity(favorite.cityName);
      return result.fold((failure) => null, (weather) => weather);
    } catch (e) {
      return null;
    }
  }
}
