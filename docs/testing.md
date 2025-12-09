# Testing Documentation

## Test Structure

Tests are organized in the `test/` directory following the same structure as the source code:

```
test/
├── helpers/              # Test utilities and helpers
├── unit/                 # Unit tests
└── widget/               # Widget tests
```

## Unit Tests

### Weather Repository Tests (`test/unit/weather_repository_test.dart`)

Tests the weather repository implementation:

- ✅ **Success case**: Returns weather data when API call succeeds
- ✅ **Error handling**: Returns ServerFailure when API fails
- ✅ **Cache fallback**: Returns cached data when API fails but cache exists
- ✅ **Forecast**: Tests 5-day forecast retrieval

**What it verifies**:
- Correct data parsing from API responses
- Error handling and failure mapping
- Cache integration
- Repository contract compliance

### Favorites Repository Tests (`test/unit/favorites_repository_test.dart`)

Tests the favorites repository CRUD operations:

- ✅ **Add favorite**: Successfully adds a city to favorites
- ✅ **Get favorites**: Retrieves all favorite cities
- ✅ **Update favorite**: Modifies existing favorite
- ✅ **Delete favorite**: Removes favorite from storage
- ✅ **Filter by region**: Returns only favorites matching region

**What it verifies**:
- CRUD operations work correctly
- Data persistence in Hive
- Region filtering functionality
- Data integrity

## Widget Tests

### Home Screen Tests (`test/widget/home_screen_test.dart`)

Tests the home screen UI behavior:

- ✅ **Loading state**: Shows loading indicator when fetching data
- ✅ **Error state**: Displays error message with retry button
- ✅ **Success state**: Shows weather data when available

**What it verifies**:
- UI responds correctly to different states
- Error messages are displayed
- Loading indicators appear during data fetching

### Favorites Screen Tests (`test/widget/favorites_screen_test.dart`)

Tests the favorites screen UI:

- ✅ **Empty state**: Shows message when no favorites exist
- ✅ **List display**: Shows all favorites when available

**What it verifies**:
- Empty state handling
- List rendering with data
- UI state management

## Test Tools

- **flutter_test**: Core testing framework
- **mocktail**: Mocking library for dependencies
- **Hive**: In-memory boxes for testing storage

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/weather_repository_test.dart

# Run with coverage
flutter test --coverage
```

## Test Coverage

Current test coverage includes:
- Repository layer (data operations)
- Widget layer (UI state handling)
- Error handling scenarios

## Future Test Improvements

Potential areas for additional testing:
- Integration tests for complete user flows
- Provider state management tests
- API client unit tests
- More comprehensive widget tests

