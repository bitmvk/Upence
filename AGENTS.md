# AGENTS.md

This file contains project-specific guidelines for agentic coding assistants working on the Upence Flutter project.

## Build, Lint, and Test Commands

### Building
- `flutter build apk` - Build Android APK
- `flutter build apk --no-tree-shake-icons` - Build Android APK (use this flag when using icon picker)
- `flutter build appbundle` - Build Android App Bundle
- `flutter build appbundle --no-tree-shake-icons` - Build Android App Bundle (use this flag when using icon picker)
- `flutter run -d android` - Run on connected Android device/emulator

### Linting and Analysis
- `flutter analyze` - Run static analysis (checks for errors and lints)
- `dart fix --dry-run` - Preview automatic fixes
- `dart fix --apply` - Apply automatic fixes

### Testing
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run a single test file
- `flutter test --coverage` - Run tests with coverage report

### Code Generation
- `dart run build_runner build` - Generate Drift database code
- `dart run build_runner build --delete-conflicting-outputs` - Force regenerate (use if conflicts)
- `dart run flutter_iconpicker:generate_packs --packs material` - Generate Material icon pack (required for icon picker)

## Code Style Guidelines

### File Organization
- **Features**: `lib/features/{feature}/presentation/` for UI, `lib/features/{feature}/services/` for business logic
- **Data Layer**: `lib/data/models/` for DTOs, `lib/data/repositories/` for repositories, `lib/data/database/` for DB
- **Core**: `lib/core/` for constants, theme, utilities, and shared widgets
- **Services**: `lib/services/` for platform-level services (SMS, notifications, permissions)

### Imports
- Order: Flutter SDK → external packages → project packages → relative imports
- No explicit sorting, but keep related imports together

### Naming Conventions
- **Classes/Enums**: `PascalCase` (e.g., `SMSService`, `TransactionType`)
- **Files**: `snake_case.dart` (e.g., `sms_service.dart`, `transaction_model.dart`)
- **Variables/Methods**: `camelCase` (e.g., `recentTransactions`, `processSMS()`)
- **Constants**: `lowerCamelCase` (static final), or `UPPER_CASE` for app-wide constants
- **Private members**: `_camelCase` prefix (e.g., `_calculateScore()`)
- **Database tables**: `PascalCase` (e.g., `Transactions`), data classes use `@DataClassName('ModelName')`

### Types and Null Safety
- Always use explicit types for public APIs
- Use `String?`, `int?`, etc. for nullable types
- Use `Value()` from Drift for optional database fields
- Prefer `const` constructors for immutable widgets
- Use enum classes for fixed sets of values (e.g., `TransactionType`)

### Error Handling
- Use try-catch blocks for operations that may throw
- Return early on null checks
- Use `debugPrint()` for logging in dev, avoid `print()`
- For async operations, handle errors gracefully in UI with `.error()` states

### State Management (Riverpod)
- Use `ConsumerWidget` for widgets that watch providers
- Use `ref.watch()` for reactive data
- Use `ref.read()` for one-time reads (e.g., in callbacks)
- Create providers in separate files (e.g., `*_provider.dart`)
- Name providers descriptively: `recentTransactionsProvider`, `themeModeProvider`

### Database (Drift)
- Define tables in `lib/data/database/tables/`
- Create DAOs for complex queries in `lib/data/database/dao/`
- Use generated code (`*.g.dart`) - never edit manually
- Use `TransactionsCompanion` for inserts with optional fields
- Repository pattern between database and UI: `lib/data/repositories/`

### UI/Flutter Guidelines
- Use Material Design 3 (enabled in theme)
- Prefer `const` widgets where possible
- Use `Scaffold` with proper structure (appBar, body, floatingActionButton)
- Handle loading/error/empty states explicitly with `.when()`, `.whenData()`, or conditional rendering
- Use `Consumer` widgets for nested provider access
- Navigate using `Navigator.push()` with named routes or MaterialPageRoute

### Platform-Specific Code
- Android platform channels: use `MethodChannel` with naming pattern `com.upence/sms_receiver`
- Background services: use `flutter_background_service`
- SMS permissions: `READ_SMS`, `RECEIVE_SMS`
- Notifications: `POST_NOTIFICATIONS` permission required

### Testing
- Widget tests use `testWidgets()` from `flutter_test`
- Use `WidgetTester` for widget interactions
- Test file naming: `{feature}_test.dart` in `test/` directory
- Mock dependencies in tests

### Comments and Documentation
- Keep code self-documenting with clear names
- Add comments only for non-obvious logic
- Use `// TODO:` for future work items
- Document public API members in complex services

## Architecture Notes

- **Pattern matching**: SMSParsingService uses structure-based algorithm with 0.5 threshold
- **SMS processing**: Filter bank messages (ends with -S, contains BANK/UPI), cache 50 messages
- **Notifications**: Auto-cancel after 60ms, use action buttons for quick processing
- **Database schema**: 8 tables (transactions, categories, tags, transaction_tags, bank_accounts, sms, sms_parsing_patterns, senders)

## Important Constants
- SMS cache: 50 messages max
- Notification timeout: 60 seconds
- Pattern match threshold: 0.5 (50%)
- Database schema version: 1

When making changes, always run `flutter analyze` and `dart run build_runner build` if database files were modified.
