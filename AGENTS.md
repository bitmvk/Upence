# AGENTS.md

Guidelines for AI coding agents working on the Upence Flutter project.

## Project Overview

Upence is a Flutter personal finance app for tracking SMS-based transactions. It uses:
- **Flutter/Dart** with Material Design
- **Riverpod** for state management
- **Drift** for local SQLite database
- **go_router** for navigation

## Build/Lint/Test Commands

### Build Commands
```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build APK
flutter build apk

# Generate Drift database code (required after modifying tables/DAOs)
dart run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate
dart run build_runner watch --delete-conflicting-outputs
```

### Lint Commands
```bash
# Run static analysis
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Test Commands
```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run a specific test by name
flutter test --name "testName"

# Run tests with verbose output
flutter test --reporter expanded

# Run tests with coverage
flutter test --coverage
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── di/proviers.dart         # Riverpod providers (DI)
│   ├── navigation/router.dart   # GoRouter configuration
│   ├── services/                # Background services, notifications
│   └── ui/                      # Shared UI utilities
├── data/local/
│   ├── database/
│   │   ├── database.dart        # Drift database definition
│   │   ├── tables/              # Table definitions
│   │   └── dao/                 # Data Access Objects
├── repositories/                # Data layer abstraction
└── views/
    ├── home/                    # Home screen
    └── setup/                   # Onboarding flow
        └── widgets/             # Setup page widgets
```

## Code Style Guidelines

### Imports

Order imports as follows, separated by blank lines:
1. Dart SDK imports
2. Flutter imports
3. Third-party packages (alphabetical)
4. Project imports (alphabetical)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:upence/core/di/providers.dart';
import 'package:upence/data/local/database/database.dart';
```

Use relative imports for files within the same feature module:
```dart
import 'tables/bank_accounts.dart';
```

### Naming Conventions

- **Files**: `snake_case.dart` (e.g., `setup_view_model.dart`)
- **Classes**: `PascalCase` (e.g., `SetupViewModel`, `TransactionsRepository`)
- **Variables/Methods**: `camelCase` (e.g., `currentStep`, `nextStep()`)
- **Private members**: Prefix with underscore (e.g., `_pageController`, `_transactionDao`)
- **Constants**: `camelCase` for private, `PascalCase` for public (e.g., `totalSteps`)
- **Providers**: Suffix with `Provider` (e.g., `databaseProvider`, `setupViewModelProvider`)
- **Tables**: `PascalCase` plural (e.g., `Transactions`, `BankAccounts`)
- **Data classes**: `PascalCase` singular (e.g., `Transaction`, `BankAccount`)

### Formatting

- Use `const` constructors wherever possible
- Prefer trailing commas for multi-line widget trees
- Maximum line length: 80 characters
- Use double quotes for strings (consistent with existing code)

```dart
return Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        const WelcomePage(),
        SetupProgressIndicator(
          currentStep: state.currentStep.index + 1,
          totalSteps: SetupViewModel.totalSteps,
        ),
      ],
    ),
  ),
);
```

### Types

- Always specify types for public API signatures
- Use `var` only when type is obvious from context
- Prefer nullable types (`Type?`) over dynamic
- Use `late final` for dependencies injected via constructor or init

```dart
Future<List<Transaction>> getTransactions(
  List<int>? ids,
  DateTimeRange? dateRange,
  int? limit,
) async {
  // ...
}
```

### Widget Patterns

- Use `ConsumerWidget` for stateless widgets that read providers
- Use `ConsumerStatefulWidget` for stateful widgets that read providers
- Access providers via `ref.watch()` for rebuild on change
- Use `ref.read()` for event handlers (avoid rebuilding)
- Use `ref.listen()` for side effects (navigation, showing errors)

```dart
class SetupView extends ConsumerStatefulWidget {
  const SetupView({super.key});

  @override
  ConsumerState<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends ConsumerState<SetupView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setupViewModelProvider);
    final viewModel = ref.read(setupViewModelProvider.notifier);

    ref.listen<SetupState>(setupViewModelProvider, (previous, next) {
      // Handle side effects
    });
    // ...
  }
}
```

### State Management

- Use Riverpod `Notifier` for complex state with business logic
- Use `StateProvider` for simple state
- Use `FutureProvider` for async data loading
- Create immutable state classes with `copyWith` pattern

```dart
class SetupState {
  final SetupStep currentStep;
  final bool isLoading;
  final String? errorMessage;

  SetupState({
    required this.currentStep,
    this.isLoading = false,
    this.errorMessage,
  });

  SetupState copyWith({
    SetupStep? currentStep,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SetupState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
```

### Database (Drift)

- Define tables in `lib/data/local/database/tables/`
- Define DAOs in `lib/data/local/database/dao/`
- Register tables and DAOs in `database.dart`
- Run `build_runner` after modifying tables

```dart
@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(BankAccounts, #id)();
  TextColumn get payee => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
}
```

### Error Handling

- Use nullable return types for operations that may fail
- Store error messages in state for UI display
- Wrap async operations in try-catch blocks

```dart
Future<void> completeSetup() async {
  state = state.copyWith(isLoading: true, errorMessage: null);

  try {
    await _batchInsertCategories();
    state = state.copyWith(isLoading: false);
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Failed to complete setup: ${e.toString()}',
    );
  }
}
```

### Repository Pattern

- Repositories abstract database access from business logic
- Each repository wraps one or more DAOs
- Methods should return domain models, not database types

## Pre-commit Checklist

1. Run `flutter analyze` - no errors
2. Run `flutter test` - all tests pass
3. Run `dart run build_runner build` if database files changed
4. Verify app runs with `flutter run`
