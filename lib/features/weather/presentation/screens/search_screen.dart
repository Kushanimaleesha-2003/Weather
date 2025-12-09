import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/temperature_converter.dart';
import '../../../../core/utils/weather_icons.dart';
import '../../../../router/app_router.dart';
import '../providers/weather_providers.dart';
import '../providers/dashboard_provider.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../favorites/domain/entities/favorite_city.dart';
import '../../domain/entities/current_weather.dart';
import '../providers/dashboard_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  CurrentWeather? _searchResult;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _searchResult = null;
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(value.trim());
    });
  }

  Future<void> _performSearch(String cityName) async {
    try {
      final result = await ref.read(weatherRepositoryProvider)
          .getCurrentWeatherByCity(cityName);
      
      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.toString();
            _isSearching = false;
            _searchResult = null;
          });
        },
        (weather) {
          setState(() {
            _searchResult = weather;
            _isSearching = false;
            _errorMessage = null;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSearching = false;
        _searchResult = null;
      });
    }
  }

  Future<void> _selectCity(CurrentWeather weather) async {
    // Add to search history
    await ref.read(searchHistoryProvider.notifier).addSearch(weather.cityName);
    
    // Update dashboard
    await ref.read(dashboardProvider.notifier).loadWeatherByCity(weather.cityName);
    
    // Navigate back to home
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _addToFavorites(CurrentWeather weather) async {
    final favorite = FavoriteCity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cityName: weather.cityName,
      createdAt: DateTime.now(),
    );
    
    await ref.read(favoritesProvider.notifier).addFavorite(favorite);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${weather.cityName} added to favorites'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).settings;
    final searchHistory = ref.watch(searchHistoryProvider).history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter city name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResult = null;
                            _isSearching = false;
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Content
          Expanded(
            child: _isSearching
                ? const AppLoadingWidget(message: 'Searching...')
                : _errorMessage != null
                    ? AppErrorWidget(
                        error: _errorMessage!,
                        onRetry: () => _performSearch(_searchController.text.trim()),
                      )
                    : _searchResult != null
                        ? _buildSearchResult(_searchResult!, settings)
                        : _buildSearchHistory(searchHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResult(CurrentWeather weather, dynamic settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      WeatherIcons.getWeatherIcon(weather.icon),
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.cityName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weather.description.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            TemperatureConverter.formatTemperature(
                              weather.temperature,
                              settings.temperatureUnit,
                            ),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectCity(weather),
                        icon: const Icon(Icons.check),
                        label: const Text('Select'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _addToFavorites(weather),
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Add to Favorites'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHistory(List<String> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a city',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(searchHistoryProvider.notifier).clearHistory();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...history.map((city) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(city),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _searchController.text = city;
                _performSearch(city);
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}
