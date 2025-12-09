import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/weather_icons.dart';
import '../../../../core/utils/temperature_converter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/weather_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/forecast_item.dart';

class ForecastDetailScreen extends ConsumerStatefulWidget {
  final String cityName;
  final DateTime? date;

  const ForecastDetailScreen({
    super.key,
    required this.cityName,
    this.date,
  });

  @override
  ConsumerState<ForecastDetailScreen> createState() => _ForecastDetailScreenState();
}

class _ForecastDetailScreenState extends ConsumerState<ForecastDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadForecast();
    });
  }

  Future<void> _loadForecast() async {
    await ref.read(forecastProvider.notifier).getForecastByCity(widget.cityName);
  }

  @override
  Widget build(BuildContext context) {
    final forecastState = ref.watch(forecastProvider);
    final settings = ref.watch(settingsProvider).settings;
    final targetDate = widget.date ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('Forecast - ${widget.cityName}'),
      ),
      body: forecastState.isLoading
          ? const AppLoadingWidget()
          : forecastState.error != null
              ? AppErrorWidget(
                  error: forecastState.error!.toString(),
                  onRetry: _loadForecast,
                )
              : forecastState.forecast == null
                  ? const AppLoadingWidget()
                  : _buildForecastDetail(forecastState.forecast!, targetDate, settings),
    );
  }

  Widget _buildForecastDetail(
    dynamic forecast,
    DateTime targetDate,
    dynamic settings,
  ) {
    final dayItems = forecast.items
        .where((item) {
          final itemDate = DateTime(
            item.dateTime.year,
            item.dateTime.month,
            item.dateTime.day,
          );
          final target = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
          );
          return itemDate.year == target.year &&
              itemDate.month == target.month &&
              itemDate.day == target.day;
        })
        .toList();

    if (dayItems.isEmpty) {
      return Center(
        child: Text(
          'No forecast data for ${DateFormatter.formatDate(targetDate)}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    DateFormatter.formatDate(targetDate),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    WeatherIcons.getWeatherIcon(dayItems.first.icon),
                    style: const TextStyle(fontSize: 48),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Temperature Chart
          _buildTemperatureChart(dayItems, settings),

          const SizedBox(height: 24),

          // Detailed Forecast List
          const Text(
            'Hourly Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...dayItems.map((item) => _buildForecastItem(item, settings)),
        ],
      ),
    );
  }

  Widget _buildTemperatureChart(List<ForecastItem> items, dynamic settings) {
    final spots = items.asMap().entries.map((entry) {
      final temp = TemperatureConverter.convertToDisplay(
        entry.value.temperature,
        settings.temperatureUnit,
      );
      return FlSpot(entry.key.toDouble(), temp);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}${TemperatureConverter.getUnitSymbol(settings.temperatureUnit)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < items.length) {
                            return Text(
                              DateFormatter.formatTime(items[value.toInt()].dateTime),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(ForecastItem item, dynamic settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              WeatherIcons.getWeatherIcon(item.icon),
              style: const TextStyle(fontSize: 32),
            ),
          ],
        ),
        title: Text(
          DateFormatter.formatTime(item.dateTime),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              TemperatureConverter.formatTemperature(
                item.temperature,
                settings.temperatureUnit,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Feels like ${TemperatureConverter.formatTemperature(item.temperature, settings.temperatureUnit)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
