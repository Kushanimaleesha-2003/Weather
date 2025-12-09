import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/weather_icons.dart';
import '../providers/alerts_providers.dart';
import '../../domain/entities/weather_alert_rule.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(alertsProvider);
    final alerts = alertsState.rules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts'),
      ),
      body: alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alert rules',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create alerts to get notified about weather conditions',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(
                        WeatherIcons.getAlertIcon(alert.type.name),
                        color: Colors.orange.shade700,
                      ),
                    ),
                    title: Text(
                      _getAlertTypeName(alert.type),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('City: ${alert.cityName}'),
                        if (alert.threshold != null)
                          Text('Threshold: ${alert.threshold}'),
                        if (alert.message != null) Text(alert.message!),
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
                          _showEditDialog(alert);
                        } else if (value == 'delete') {
                          _showDeleteDialog(alert);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAlertDialog(),
        icon: const Icon(Icons.add_alert),
        label: const Text('Add Alert'),
      ),
    );
  }

  String _getAlertTypeName(AlertType type) {
    switch (type) {
      case AlertType.rain:
        return 'Rain Alert';
      case AlertType.temperatureAbove:
        return 'High Temperature';
      case AlertType.temperatureBelow:
        return 'Low Temperature';
      case AlertType.windSpeed:
        return 'Wind Speed';
    }
  }

  Future<void> _showAddAlertDialog() async {
    AlertType? selectedType = AlertType.rain;
    final cityController = TextEditingController();
    final thresholdController = TextEditingController();
    final messageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Alert Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AlertType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Alert Type'),
                  items: AlertType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getAlertTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City Name (or "all" for all cities)',
                    hintText: 'e.g., London or all',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: thresholdController,
                  decoration: const InputDecoration(
                    labelText: 'Threshold',
                    hintText: 'e.g., 30 for temperature > 30°C',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message (optional)',
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
                if (cityController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('City name is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final alert = WeatherAlertRule(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  cityName: cityController.text.trim(),
                  type: selectedType!,
                  threshold: thresholdController.text.trim().isNotEmpty
                      ? double.tryParse(thresholdController.text.trim())
                      : null,
                  message: messageController.text.trim().isEmpty
                      ? null
                      : messageController.text.trim(),
                  createdAt: DateTime.now(),
                );

                await ref.read(alertsProvider.notifier).addAlertRule(alert);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alert rule added'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(WeatherAlertRule alert) async {
    AlertType? selectedType = alert.type;
    final cityController = TextEditingController(text: alert.cityName);
    final thresholdController = TextEditingController(
      text: alert.threshold?.toString() ?? '',
    );
    final messageController = TextEditingController(text: alert.message ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Alert Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AlertType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Alert Type'),
                  items: AlertType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getAlertTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: thresholdController,
                  decoration: const InputDecoration(
                    labelText: 'Threshold',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
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
                final updated = alert.copyWith(
                  cityName: cityController.text.trim(),
                  type: selectedType!,
                  threshold: thresholdController.text.trim().isNotEmpty
                      ? double.tryParse(thresholdController.text.trim())
                      : null,
                  message: messageController.text.trim().isEmpty
                      ? null
                      : messageController.text.trim(),
                );

                await ref.read(alertsProvider.notifier).updateAlertRule(updated);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alert rule updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(WeatherAlertRule alert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text('Delete ${_getAlertTypeName(alert.type)} alert?'),
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
      await ref.read(alertsProvider.notifier).deleteAlertRule(alert.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert rule deleted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
