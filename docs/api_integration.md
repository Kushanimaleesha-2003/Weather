# API Integration Documentation

## OpenWeatherMap API

The application uses the **OpenWeatherMap API** (https://openweathermap.org/api) to fetch weather data.

## Endpoints Used

### 1. Current Weather
- **Endpoint**: `/weather`
- **Method**: GET
- **Parameters**:
  - By city: `q={cityName}`
  - By coordinates: `lat={latitude}&lon={longitude}`
- **Response**: Current weather conditions including temperature, humidity, wind speed, description, etc.

### 2. 5-Day Forecast
- **Endpoint**: `/forecast`
- **Method**: GET
- **Parameters**:
  - By city: `q={cityName}`
  - By coordinates: `lat={latitude}&lon={longitude}`
- **Response**: 5-day weather forecast with 3-hour intervals

## API Client Implementation

The `OpenWeatherApiClient` class (located in `core/network/openweather_api_client.dart`) handles all API communication:

- Uses **Dio** for HTTP requests
- Automatically includes API key from environment variables
- Sets default units to metric (Celsius)
- Handles timeouts (10 seconds)
- Maps errors to user-friendly exceptions

## Data Parsing

### Models

Weather data is parsed into strongly-typed models:

1. **CurrentWeatherModel**: Represents current weather conditions
   - Extends `CurrentWeather` entity
   - Includes JSON serialization/deserialization

2. **ForecastModel**: Represents 5-day forecast
   - Contains list of `ForecastItemModel`
   - Groups forecast items by day

3. **ForecastItemModel**: Represents individual forecast entry
   - 3-hour interval data
   - Temperature, description, wind, humidity

### Parsing Flow

```
API Response (JSON)
    ↓
Model.fromJson()
    ↓
Domain Entity
    ↓
UI Display
```

## Error Handling

API errors are handled at multiple levels:

1. **DioException**: Caught in API client
2. **ServerException**: Thrown for API errors
3. **ServerFailure**: Mapped to user-friendly messages
4. **UI**: Displays error with retry option

### Error Messages

- **Timeout**: "Unable to reach server. Please check your connection."
- **404**: "City not found. Please try another city name."
- **401**: "API key is invalid. Please check your configuration."
- **Network**: "Unable to reach server. Please check your connection."

## Caching Strategy

- Weather data is cached locally using **Hive**
- Cache expiration: 1 hour
- Automatic fallback to cached data when API fails
- Cache key format: `weather_{cityName}`

## CRUD Operations

While OpenWeatherMap API is read-only, the app demonstrates CRUD operations through:

### Favorites (Hive Storage)
- **Create**: Add city to favorites
- **Read**: List all favorites
- **Update**: Edit favorite details
- **Delete**: Remove favorite

### Alerts (Hive Storage)
- **Create**: Add alert rule
- **Read**: List all alert rules
- **Update**: Edit alert rule
- **Delete**: Remove alert rule

Both use Hive boxes for persistent local storage, demonstrating full CRUD capabilities.

## API Key Configuration

API key is stored in `.env` file:
```
OPENWEATHER_API_KEY=your_api_key_here
```

The app loads this key at startup and includes it in all API requests.

