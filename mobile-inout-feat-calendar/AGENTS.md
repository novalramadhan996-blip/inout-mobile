# AGENTS.md - Flutter Mobile In/Out

## Build/Test/Lint Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (auto_route, retrofit, riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run code generation (watch mode during development)
dart run build_runner watch --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run tests with matching name pattern
flutter test --name "checkIn"

# Run tests in a specific directory
flutter test test/feature/auth/

# Run tests with coverage
flutter test --coverage

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle

# Build iOS
flutter build ios

# Clean build artifacts
flutter clean
```

## Code Style Guidelines

### Imports

- Group imports in this order: Dart SDK (`dart:*`), Flutter SDK (`package:flutter/*`), third-party packages, project imports (`package:mobile_in_out/*`)
- Separate groups with blank line, sort alphabetically within groups
- Use relative imports only within same feature module

### Naming Conventions

- **Files**: `snake_case.dart` (e.g., `check_in_page.dart`)
- **Classes**: `PascalCase` (e.g., `CheckInPage`)
- **Variables/Functions**: `camelCase` (e.g., `checkInRequest`)
- **Constants**: `camelCase` or `PascalCase` for enum-like constants
- **Private members**: Prefix with underscore (e.g., `_isLoading`)

### Model Classes

- Include `fromJson` factory constructor and `toJson` method
- Use nullable types (`String?`, `int?`) for optional fields
- Keep JSON keys in snake_case
- Extend `Equatable` for value equality

### State Management

- Use `ChangeNotifier` for providers
- Call `notifyListeners()` after state changes
- Use `RequestState` enum: `Empty`, `Loading`, `Loaded`, `Error`

### Widget Structure

- Use `const` constructors when possible
- Place `key` parameter first, use `super.key` shorthand
- Extract large widgets into private methods or separate widgets

### Error Handling

- Use `try-catch` for async operations
- Log errors using `LogHelper.logDebug()` from `dart:developer` or `logger` package
- Use Either pattern from `dartz` for repositories
- Failure types: `ServerFailure`, `ConnectionFailure`, `DatabaseFailure`, `CommonFailure`

### Linting

- Uses `flutter_lints` (v5.0.0)
- Custom rules in `analysis_options.yaml`
- Run `flutter analyze` before committing

## Project Structure

```
lib/
├── app.dart                    # App widget
├── main.dart                   # Development entry point
├── main_common.dart            # Shared entry point logic
├── main_stage.dart             # Staging entry point
├── main_production.dart        # Production entry point
├── core/
│   ├── resources/
│   │   ├── env/               # Environment configs
│   │   ├── injector/          # Dependency injection (get_it)
│   │   ├── local/             # Local services (DB, prefs, camera)
│   │   ├── network/           # Network layer (Dio, REST client)
│   │   ├── repositories/      # Repository implementations
│   │   └── theme/             # App themes, colors, styles
│   ├── routes/                # AutoRoute configuration
│   └── utils/
│       ├── errors/            # Error handling (Failure classes)
│       ├── models/            # Data models
│       ├── widgets/           # Reusable widgets
│       └── base_response/     # Response handling
└── feature/
    ├── auth/                  # Authentication
    ├── absence/               # Absence management (check-in/out)
    ├── history/              # History feature
    ├── task/                 # Task management
    └── ...
```

## Key Dependencies

- `auto_route`: Navigation/routing
- `dio` + `retrofit`: HTTP client
- `dartz`: Either type for functional error handling
- `provider` + `riverpod`: State management
- `get_it`: Service locator/DI
- `sqflite`: Local SQLite database
- `google_ml_kit`: Face detection
- `firebase_core` + `firebase_messaging` + `firebase_crashlytics`: Firebase services

## Environment Setup

1. Copy `.env.sample` to `.env` and configure
2. Run `flutter pub get`
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Ensure Android SDK min version 21, target 34

## Common Tasks

### Adding a New Route

1. Add route to `lib/core/routes/router.dart`
2. Run `dart run build_runner build`
3. Navigate using `context.router.push(RouteName())`

### Adding a New API Endpoint

1. Add method to `RestClient` interface in `lib/core/resources/network/rest_client.dart`
2. Run `dart run build_runner build`
3. Add corresponding repository method using Either pattern
4. Create appropriate model classes with `fromJson`/`toJson`

### Adding a New Model

1. Create class with `fromJson` factory and `toJson` method
2. Use nullable types for optional fields
3. Extend `Equatable` for value equality
