# AGENTS.md - Development Guidelines for Chat Flutter Plugin

## Build, Lint, and Test Commands

### Running the Plugin
```bash
# Get dependencies
flutter pub get

# Build plugin
flutter build apk --debug
# or for iOS
flutter build ios --debug
```

### Running Tests
```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/chat_test.dart

# Run a specific test
flutter test --name "getPlatformVersion"
```

### Code Generation
```bash
# Generate auto_route files
dart run build_runner build --delete-conflicting-outputs

# Generate retrofit files
dart run build_runner build --delete-conflicting-outputs
```

### Linting
```bash
# Run Flutter analyzer
flutter analyze

# Fix auto-fixable issues
flutter analyze --fix
```

---

## Code Style Guidelines

### Architecture Pattern
This project follows a layered architecture:
- **Models**: Data classes with `fromFirestore`/`toFirestore` for Firestore integration
- **Repositories**: Data access layer implementing repository interfaces
- **Controllers**: Business logic layer (use MessageController pattern)
- **ViewModels**: UI state management using Provider
- **UI**: Flutter widgets (screens and components)

### Imports
- Use package imports: `import 'package:chat/models/message_model.dart';`
- Group imports: dart, flutter, external packages, local packages
- Sort alphabetically within groups

```dart
// Example import order
import 'dart:developer';

import 'package:chat/models/message_model.dart';
import 'package:chat/repositories/message_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
```

### Naming Conventions
- **Files**: snake_case (e.g., `message_repository.dart`)
- **Classes**: PascalCase (e.g., `MessageModel`)
- **Methods/Variables**: camelCase (e.g., `fetchMessage`)
- **Constants**: PascalCase with `k` prefix (e.g., `kMaxMessages`)
- **Private members**: prefix with `_` (e.g., `_firestore`)

### Types
- Use explicit types for function parameters and return types
- Use `?` for nullable types
- Prefer `final` over `var` when value won't be reassigned

```dart
// Good
final MessageModel message = MessageModel(...);
Future<void> fetchMessage(String chatId) async { ... }
String? getFileName() => null;

// Avoid
var message = MessageModel(...);
fetchMessage(chatId) async { ... }
```

### Error Handling
- Use `dartz` library's `Either` type for functional error handling
- Use custom `Failure` classes for domain errors
- Use `try-catch` with proper error logging via `log()`

```dart
// Example from codebase
import 'package:dartz/dartz.dart';

Either<Failure, T> handleError(TRY);
```

### State Management
- Use **Provider** for state management
- Use **get_it** for dependency injection (see `lib/core/resources/injector/di.dart`)
- Use **ChangeNotifier** for ViewModels

### Firebase
- Use `cloud_firestore` for database operations
- Models implement `fromFirestore(Map<String, dynamic> data, String id)` factory
- Models implement `toFirestore()` method for Firestore serialization

### Code Generation
- Generated files use `.g.dart` or `.gr.dart` extensions
- Don't edit generated files manually
- Re-run build_runner after modifying models/annotations

### UI Components
- Custom widgets in `lib/core/widget/`
- Reusable components should be extracted
- Follow Flutter best practices (const constructors, etc.)

---

## Project Structure

```
lib/
├── chat.dart                    # Main entry point
├── chat_method_channel.dart     # Platform channel
├── chat_platform_interface.dart # Platform interface
├── controllers/                 # Business logic
├── core/
│   ├── resources/
│   │   ├── constants/          # App constants
│   │   ├── injector/           # DI setup
│   │   ├── network/             # HTTP/Retrofit
│   │   └── storage/             # SharedPreferences
│   ├── routes/                  # Auto-route navigation
│   ├── utils/                   # Utilities
│   └── widget/                  # Reusable widgets
├── models/                      # Data models
├── repositories/                # Data access layer
└── viewmodel/                   # State management
```

---

## Dependencies

Key packages used in this project:
- `provider` - State management
- `get_it` - Dependency injection
- `dartz` - Functional programming (Either)
- `retrofit` - HTTP client
- `cloud_firestore` - Firebase
- `auto_route` - Navigation
- `shared_preferences` - Local storage

---

## Notes for Agents

1. Before modifying models with Firestore annotations, run `dart run build_runner build --delete-conflicting-outputs`
2. Tests use `flutter_test` with mock platform interfaces
3. The plugin follows Flutter platform channel pattern for cross-platform support
4. Follow existing code patterns when adding new features
