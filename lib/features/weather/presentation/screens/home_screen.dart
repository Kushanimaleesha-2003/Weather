import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/offline_badge.dart';
import '../../../../core/utils/weather_icons.dart';
import '../../../../core/utils/temperature_converter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../router/app_router.dart';
import '../providers/dashboard_provider.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../alerts/presentation/providers/alerts_providers.dart';
import '../../../alerts/domain/entities/weather_alert_rule.dart';
import '../../domain/entities/forecast_item.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/current_weather.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final dashboard = ref.read(dashboardProvider);
    if (dashboard.currentWeather == null) {
      try {
        await ref.read(dashboardProvider.notifier).loadWeatherByLocation();
      } catch (e) {
        // If location fails, try loading a default city
        await ref.read(dashboardProvider.notifier).loadWeatherByCity('London');
      }
    }
    _evaluateAlerts();
  }

  void _evaluateAlerts() {
    final alerts = ref.read(alertsProvider).rules;
    final dashboard = ref.read(dashboardProvider);
    final weather = dashboard.currentWeather;

    if (weather == null) return;

    for (final alert in alerts) {
      if (alert.cityName == weather.cityName || alert.cityName == 'all') {
        bool shouldShow = false;
        String message = '';

        switch (alert.type) {
          case AlertType.rain:
            if (weather.description.toLowerCase().contains('rain')) {
              shouldShow = true;
              message = alert.message ?? 'Rain expected today';
            }
            break;
          case AlertType.temperatureAbove:
            if (alert.threshold != null && weather.temperature > alert.threshold!) {
              shouldShow = true;
              message = alert.message ?? 'Temperature above ${alert.threshold}°C';
            }
            break;
          case AlertType.temperatureBelow:
            if (alert.threshold != null && weather.temperature < alert.threshold!) {
              shouldShow = true;
              message = alert.message ?? 'Temperature below ${alert.threshold}°C';
            }
            break;
          case AlertType.windSpeed:
            if (alert.threshold != null && weather.windSpeed > alert.threshold!) {
              shouldShow = true;
              message = alert.message ?? 'High wind speed expected';
            }
            break;
        }

        if (shouldShow && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(WeatherIcons.getAlertIcon(alert.type.name)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider);
    final settings = ref.watch(settingsProvider).settings;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  dashboard.selectedCity ?? 'Loading...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.search);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.settings);
                  },
                ),
              ],
            ),

            // Content
            if (dashboard.isLoading)
              const SliverFillRemaining(
                child: AppLoadingWidget(message: 'Loading weather data...'),
              )
            else if (dashboard.error != null)
              SliverFillRemaining(
                child: AppErrorWidget(
                  error: dashboard.error!,
                  onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
                ),
              )
            else if (dashboard.currentWeather == null)
              const SliverFillRemaining(
                child: AppLoadingWidget(),
              )
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  // Current Weather Card
                  _buildCurrentWeatherCard(dashboard.currentWeather!, settings),
                  
                  // Hourly Forecast
                  if (dashboard.forecast != null)
                    _buildHourlyForecast(dashboard.forecast!, settings),
                  
                  // 5-Day Forecast
                  if (dashboard.forecast != null)
                    _buildFiveDayForecast(dashboard.forecast!, settings),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  
                  const SizedBox(height: 24),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(CurrentWeather weather, dynamic settings) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            if (ref.read(dashboardProvider).isOffline)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: OfflineBadge(),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  WeatherIcons.getWeatherIcon(weather.icon),
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TemperatureConverter.formatTemperature(
                        weather.temperature,
                        settings.temperatureUnit,
                      ),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weather.description.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  Icons.water_drop,
                  '${weather.humidity.toStringAsFixed(0)}%',
                  'Humidity',
                ),
                _buildWeatherDetail(
                  Icons.air,
                  '${weather.windSpeed.toStringAsFixed(1)} m/s',
                  'Wind',
                ),
                _buildWeatherDetail(
                  Icons.thermostat,
                  TemperatureConverter.formatTemperature(
                    weather.feelsLike,
                    settings.temperatureUnit,
                  ),
                  'Feels like',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(Forecast forecast, dynamic settings) {
    final now = DateTime.now();
    final hourlyItems = forecast.items
        .where((ForecastItem item) => item.dateTime.isAfter(now))
        .take(8)
        .toList();

    if (hourlyItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: hourlyItems.length,
            itemBuilder: (context, index) {
              final item = hourlyItems[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormatter.formatTime(item.dateTime),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          WeatherIcons.getWeatherIcon(item.icon),
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TemperatureConverter.formatTemperature(
                            item.temperature,
                            settings.temperatureUnit,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFiveDayForecast(Forecast forecast, dynamic settings) {
    final grouped = _groupForecastByDay(forecast.items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '5-Day Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...grouped.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormatter.isToday(entry.key)
                        ? 'Today'
                        : DateFormatter.isTomorrow(entry.key)
                            ? 'Tomorrow'
                            : DateFormatter.formatDay(entry.key),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormatter.formatShortDate(entry.key),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              title: Row(
                children: [
                  Text(
                    WeatherIcons.getWeatherIcon(entry.value.first.icon),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value.first.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    TemperatureConverter.formatTemperature(
                      entry.value.map((e) => e.maxTemp).reduce((a, b) => a > b ? a : b),
                      settings.temperatureUnit,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    TemperatureConverter.formatTemperature(
                      entry.value.map((e) => e.minTemp).reduce((a, b) => a < b ? a : b),
                      settings.temperatureUnit,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.forecastDetail,
                  arguments: {
                    'cityName': forecast.cityName,
                    'date': entry.key,
                  },
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Map<DateTime, List<ForecastItem>> _groupForecastByDay(List<ForecastItem> items) {
    final grouped = <DateTime, List<ForecastItem>>{};
    for (final item in items) {
      final day = DateTime(item.dateTime.year, item.dateTime.month, item.dateTime.day);
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(item);
    }
    return grouped;
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.favorite,
            label: 'Favorites',
            onTap: () => Navigator.pushNamed(context, AppRouter.favorites),
          ),
          _buildActionButton(
            icon: Icons.notifications,
            label: 'Alerts',
            onTap: () => Navigator.pushNamed(context, AppRouter.alerts),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
