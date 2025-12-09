# Weather Master Pro

A cross-platform weather mobile application built with Flutter, featuring location-based weather, forecasts, favorites management, and weather alerts.

## Features

- 🌍 **Location-based Weather** - Get weather for your current location
- 🔍 **City Search** - Search and view weather for any city
- 📅 **5-Day Forecast** - Detailed forecast with hourly breakdown
- ⭐ **Favorites** - Save and manage favorite cities (CRUD)
- 🔔 **Weather Alerts** - Create custom alert rules
- 🌡️ **Temperature Units** - Toggle between Celsius and Fahrenheit
- 🌙 **Dark Mode** - Light and dark theme support
- 📱 **Offline Support** - Cached data for offline access
- 📊 **Charts** - Temperature trend visualization

## Technology Stack

- **Flutter 3** with null-safety
- **Riverpod** - State management
- **Dio** - HTTP client
- **Hive** - Local storage
- **OpenWeatherMap API** - Weather data
- **Material Design 3** - UI components

## Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd weather_master_pro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API key**
   - Create a `.env` file in the root directory
   - Add your OpenWeatherMap API key:
     ```
     OPENWEATHER_API_KEY=your_api_key_here
     ```
   - Get your API key from [OpenWeatherMap](https://openweathermap.org/api)

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/              # Shared utilities and infrastructure
├── features/           # Feature-based modules
│   ├── weather/       # Weather feature
│   ├── favorites/     # Favorites feature
│   ├── alerts/        # Alerts feature
│   └── settings/      # Settings feature
└── router/            # App routing
```

## Testing

Run tests with:
```bash
flutter test
```

## Documentation

See the `docs/` folder for detailed documentation:
- `docs/overview.md` - Feature overview
- `docs/architecture.md` - Architecture details
- `docs/api_integration.md` - API integration guide
- `docs/testing.md` - Testing documentation

## Building for Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

## License

This project is for educational purposes.

## Author

Built as a coursework project demonstrating Flutter development, Clean Architecture, and modern mobile app development practices.
