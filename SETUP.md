# Setup Instructions

## Prerequisites

1. Flutter SDK 3.0 or higher
2. Android Studio / VS Code with Flutter extensions
3. OpenWeatherMap API key (free tier available at https://openweathermap.org/api)

## Installation Steps

1. **Get dependencies:**
   ```bash
   flutter pub get
   ```

2. **Create `.env` file:**
   Create a `.env` file in the root directory with the following content:
   ```
   OPENWEATHER_API_KEY=your_api_key_here
   ```
   
   Replace `your_api_key_here` with your actual OpenWeatherMap API key.

3. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/                    # Core utilities and shared code
│   ├── errors/             # Error handling (failures, exceptions)
│   ├── network/            # API client (OpenWeatherMap)
│   ├── theme/              # App themes
│   └── utils/              # Utilities (constants, helpers)
├── features/               # Feature-based modules
│   ├── weather/           # Weather feature
│   │   ├── data/          # Data layer (models, datasources, repositories)
│   │   ├── domain/        # Domain layer (entities, repositories, usecases)
│   │   └── presentation/  # Presentation layer (providers, screens, widgets)
│   ├── favorites/         # Favorites feature
│   ├── alerts/            # Alerts feature
│   └── settings/          # Settings feature
└── router/                # App routing
```

## Architecture

The project follows **Clean Architecture** principles:

- **Domain Layer**: Business logic, entities, and repository interfaces
- **Data Layer**: API calls, local storage, repository implementations
- **Presentation Layer**: UI, state management (Riverpod), screens

## State Management

The app uses **Riverpod** for state management. Providers are organized by feature in `presentation/providers/`.

## Local Storage

**Hive** is used for local storage:
- Favorites
- Alert rules
- Settings
- Search history
- Weather cache (offline support)

## Next Steps

1. Implement UI screens (currently placeholders)
2. Add location permissions handling
3. Implement weather alert evaluation logic
4. Add unit tests
5. Add error handling UI

