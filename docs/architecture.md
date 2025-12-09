# Architecture Documentation

## Design Pattern

The application follows **Clean Architecture** principles with a layered architecture approach. This ensures separation of concerns, testability, and maintainability.

## Architecture Layers

### 1. Domain Layer
- **Purpose**: Contains business logic and entities
- **Location**: `lib/features/{feature}/domain/`
- **Components**:
  - Entities (pure Dart classes representing business objects)
  - Repository interfaces (abstract contracts)
  - Use cases (optional, for complex business logic)

### 2. Data Layer
- **Purpose**: Handles data sources and repository implementations
- **Location**: `lib/features/{feature}/data/`
- **Components**:
  - Models (data transfer objects with JSON serialization)
  - Data sources (remote API, local storage)
  - Repository implementations

### 3. Presentation Layer
- **Purpose**: UI and state management
- **Location**: `lib/features/{feature}/presentation/`
- **Components**:
  - Screens (UI pages)
  - Widgets (reusable UI components)
  - Providers (Riverpod state management)

## Folder Structure

```
lib/
├── core/                          # Shared utilities and infrastructure
│   ├── errors/                    # Error handling (failures, exceptions)
│   ├── network/                   # API client (OpenWeatherMap)
│   ├── theme/                     # App themes
│   ├── utils/                    # Utilities (constants, helpers)
│   └── widgets/                  # Reusable widgets
│
├── features/                      # Feature-based modules
│   ├── weather/
│   │   ├── data/
│   │   │   ├── datasources/      # Remote & local data sources
│   │   │   ├── models/           # Data models
│   │   │   └── repositories/     # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/         # Business entities
│   │   │   ├── repositories/     # Repository interfaces
│   │   │   └── usecases/         # Business logic use cases
│   │   └── presentation/
│   │       ├── providers/        # Riverpod providers
│   │       ├── screens/          # UI screens
│   │       └── widgets/          # Feature-specific widgets
│   │
│   ├── favorites/                # Favorites feature
│   ├── alerts/                   # Alerts feature
│   └── settings/                 # Settings feature
│
└── router/                        # App routing configuration
```

## Data Flow

```
UI (Screen)
    ↓
Provider (State Management)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
Data Source (Remote/Local)
    ↓
API/Storage
```

## State Management

**Riverpod** is used for state management throughout the application:

- **Providers**: Define data sources and business logic
- **StateNotifiers**: Manage complex state with loading, success, and error states
- **ConsumerWidget**: React to state changes in UI

### Provider Hierarchy

```
Repository Providers
    ↓
State Notifiers
    ↓
UI Consumers
```

## Key Design Decisions

1. **Feature-based Structure**: Each feature is self-contained with its own data, domain, and presentation layers
2. **Dependency Inversion**: Domain layer doesn't depend on data layer
3. **Repository Pattern**: Abstracts data sources from business logic
4. **Either Type**: Functional error handling with Either<Failure, Success>
5. **Hive for Storage**: Lightweight, fast local storage without code generation

## Benefits

- **Testability**: Each layer can be tested independently
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add new features
- **Reusability**: Core utilities can be shared across features

