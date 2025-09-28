# Snapdi - Photographer Booking App

A Flutter mobile application for booking photographers, built with Clean Architecture principles.

## Project Structure

```
lib/
├── core/                           # Core functionality and utilities
│   ├── constants/                  # App constants, themes, and configuration
│   │   ├── app_constants.dart      # API endpoints, timeouts, storage keys
│   │   └── app_theme.dart          # Colors, text styles, dimensions
│   ├── error/                      # Error handling
│   │   ├── exceptions.dart         # Custom exception classes
│   │   └── failures.dart          # Failure classes for error handling
│   ├── network/                    # Network-related utilities
│   │   ├── api_response.dart       # API response models
│   │   └── network_info.dart       # Network connectivity checking
│   ├── usecases/                   # Base use case classes
│   │   └── usecase.dart           # Abstract use case interface
│   ├── utils/                      # Utility functions
│   │   └── utils.dart             # Date, validation, string utilities
│   └── dependency_injection/       # Dependency injection setup
│       └── injection_container.dart # GetIt service locator configuration
├── features/                       # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/       # Remote and local data sources
│   │   │   ├── models/            # Data models with JSON serialization
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/          # Business entities
│   │   │   │   └── user.dart
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/          # Business logic use cases
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/              # BLoC state management
│   │       ├── pages/             # UI screens
│   │       └── widgets/           # Reusable widgets
│   ├── photographer/              # Photographer browsing feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── booking/                   # Booking management feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/                   # User profile feature
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart                      # App entry point
```

## Architecture

This app follows **Clean Architecture** principles with three main layers:

### 1. Domain Layer (Business Logic)
- **Entities**: Core business objects (User, Photographer, Booking)
- **Repositories**: Interfaces defining data operations
- **Use Cases**: Business logic implementations

### 2. Data Layer
- **Models**: Data transfer objects with JSON serialization
- **Data Sources**: Remote (API) and local (cache/database) data access
- **Repository Implementations**: Concrete implementations of domain repositories

### 3. Presentation Layer
- **BLoC**: State management using flutter_bloc
- **Pages**: UI screens and navigation
- **Widgets**: Reusable UI components

## Key Dependencies

- **State Management**: `flutter_bloc` - BLoC pattern for state management
- **Functional Programming**: `dartz` - Either type for error handling
- **Network**: `dio` - HTTP client with interceptors
- **Dependency Injection**: `get_it` - Service locator pattern
- **Local Storage**: `shared_preferences` - Simple key-value storage
- **JSON Serialization**: `json_annotation` + `json_serializable`
- **Navigation**: `go_router` - Declarative routing
- **UI Components**: `cached_network_image`, `flutter_svg`, `shimmer`

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate JSON Serialization Code**
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Features

### Authentication
- User login and registration
- JWT token management
- Email verification
- Password reset

### Photographer Discovery
- Browse photographer profiles
- Filter by location, price, style
- View portfolios and reviews

### Booking Management
- Schedule photography sessions
- Payment integration
- Booking history
- Real-time updates

### Profile Management
- User profile editing
- Photographer portfolio management
- Settings and preferences

## Backend Integration

This app is designed to work with an ASP.NET Web API backend. Make sure to:

1. Update `AppConstants.baseUrl` with your API endpoint
2. Configure authentication endpoints in `AppConstants`
3. Implement proper error handling for API responses
4. Set up CORS policies in your ASP.NET backend

## Development Guidelines

1. **Feature Development**: Follow the clean architecture structure for new features
2. **State Management**: Use BLoC pattern for complex state, simple setState for local state
3. **Error Handling**: Use Either<Failure, Success> pattern consistently
4. **Testing**: Write unit tests for use cases and widget tests for UI components
5. **Code Generation**: Run build_runner when adding new models or updating existing ones

## TODO

- [ ] Implement complete authentication flow
- [ ] Add photographer discovery features
- [ ] Create booking management system
- [ ] Implement real-time notifications
- [ ] Add payment integration
- [ ] Set up proper routing with go_router
- [ ] Add comprehensive testing
- [ ] Implement offline support
- [ ] Add image upload and caching
- [ ] Create admin panel integration