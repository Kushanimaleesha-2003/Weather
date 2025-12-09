import 'package:flutter/material.dart';
import '../features/weather/presentation/screens/home_screen.dart';
import '../features/weather/presentation/screens/search_screen.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/weather/presentation/screens/forecast_detail_screen.dart';
import '../features/alerts/presentation/screens/alerts_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/weather/presentation/screens/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String forecastDetail = '/forecast-detail';
  static const String alerts = '/alerts';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case forecastDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ForecastDetailScreen(
            cityName: args?['cityName'] ?? '',
            date: args?['date'],
          ),
        );
      case alerts:
        return MaterialPageRoute(builder: (_) => const AlertsScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

