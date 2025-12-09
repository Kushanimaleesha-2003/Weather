import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/settings_providers.dart';
import '../../domain/entities/app_settings.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/hive_init.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final settings = settingsState.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Temperature Unit
          Card(
            child: ListTile(
              leading: const Icon(Icons.thermostat),
              title: const Text('Temperature Unit'),
              subtitle: Text(
                settings.temperatureUnit == TemperatureUnit.celsius
                    ? 'Celsius (°C)'
                    : 'Fahrenheit (°F)',
              ),
              trailing: Switch(
                value: settings.temperatureUnit == TemperatureUnit.fahrenheit,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).toggleTemperatureUnit();
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Theme Mode
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              subtitle: Text(settings.isDarkMode ? 'Dark' : 'Light'),
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).toggleTheme();
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Regions Section
          const Text(
            'Region Tags',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                if (settings.regions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No region tags yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...settings.regions.map((region) {
                    return ListTile(
                      title: Text(region),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await ref
                              .read(settingsProvider.notifier)
                              .removeRegion(region);
                        },
                      ),
                    );
                  }),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Region Tag'),
                  onTap: () => _showAddRegionDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data Management
          const Text(
            'Data Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Clear cached weather data'),
                  onTap: () => _showClearCacheDialog(),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.favorite_border, color: Colors.red),
                  title: const Text('Clear All Favorites'),
                  subtitle: const Text('Remove all favorite cities'),
                  onTap: () => _showClearFavoritesDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Weather Master Pro'),
              subtitle: const Text(
                'Educational weather app built with Flutter, OpenWeatherMap, Riverpod, Dio, and Hive.',
              ),
              onTap: () => _showAboutDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Weather Master Pro'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weather Master Pro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'A cross-platform weather application built with Flutter.',
              ),
              SizedBox(height: 16),
              Text(
                'Technologies:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('• Flutter 3 (Dart)'),
              Text('• OpenWeatherMap API'),
              Text('• Riverpod (State Management)'),
              Text('• Dio (HTTP Client)'),
              Text('• Hive (Local Storage)'),
              Text('• Material Design 3'),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('• Location-based weather'),
              Text('• City search'),
              Text('• 5-day and hourly forecasts'),
              Text('• Favorite cities (CRUD)'),
              Text('• Weather alerts'),
              Text('• Offline support'),
              Text('• Dark mode'),
              SizedBox(height: 16),
              Text(
                'Version: 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddRegionDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Region Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Region Name',
            hintText: 'e.g., Asia, Europe, North America',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref
                    .read(settingsProvider.notifier)
                    .addRegion(controller.text.trim());

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${controller.text.trim()} added'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearCacheDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Clear all cached weather data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear weather cache box
      try {
        final box = await Hive.openBox('weather_cache');
        await box.clear();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cache cleared'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showClearFavoritesDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text(
          'Remove all favorite cities? This action cannot be undone.',
        ),
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
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final favorites = ref.read(favoritesProvider).favorites;
      for (final favorite in favorites) {
        await ref.read(favoritesProvider.notifier).deleteFavorite(favorite.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All favorites cleared'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
