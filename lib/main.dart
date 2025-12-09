import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/utils/hive_init.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'features/settings/presentation/providers/settings_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('ERROR: OPENWEATHER_API_KEY is empty in .env file');
    } else {
      print('✓ .env file loaded successfully');
      print('✓ API Key found: ${apiKey.substring(0, 8)}...');
    }
  } catch (e) {
    // .env file not found - will throw error when API is called
    print('ERROR: .env file not found or cannot be loaded: $e');
    print('Please ensure .env file exists in the project root with OPENWEATHER_API_KEY');
  }

  // Initialize Hive
  await HiveInit.initialize();

  runApp(
    const ProviderScope(
      child: WeatherMasterProApp(),
    ),
  );
}

class WeatherMasterProApp extends ConsumerWidget {
  const WeatherMasterProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Weather Master Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsState.settings.isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

