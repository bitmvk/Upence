# Flutter Migration Plan - Upence Project

## Project Overview
Port the Upence_old (Kotlin/Compose) Android app to Flutter for Android only.

### Original Stack
- **Language**: Kotlin
- **UI**: Jetpack Compose with Material Design 3
- **Database**: Room Database (SQLite)
- **Architecture**: MVVM with Compose ViewModel

### New Stack
- **Language**: Dart (Flutter)
- **UI**: Material 3 with custom theming
- **Database**: Drift (SQLite abstraction)
- **State Management**: Riverpod
- **SMS**: flutter_sms_inbox
- **Notifications**: flutter_local_notifications

---

## Phase 1: Project Setup & Architecture

### 1.1 Project Structure
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── database_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── dark_theme.dart
│   └── utils/
│       ├── currency_formatter.dart
│       ├── date_formatter.dart
│       └── validators.dart
├── data/
│   ├── models/
│   │   ├── transaction.dart
│   │   ├── category.dart
│   │   ├── tag.dart
│   │   ├── bank_account.dart
│   │   ├── sms.dart
│   │   ├── sms_parsing_pattern.dart
│   │   └── sender.dart
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   │   ├── transactions.dart
│   │   │   ├── categories.dart
│   │   │   ├── tags.dart
│   │   │   ├── bank_accounts.dart
│   │   │   ├── sms.dart
│   │   │   ├── sms_parsing_patterns.dart
│   │   │   └── senders.dart
│   │   └── dao/
│   │       ├── transaction_dao.dart
│   │       ├── category_dao.dart
│   │       ├── tag_dao.dart
│   │       ├── bank_account_dao.dart
│   │       ├── sms_dao.dart
│   │       └── pattern_dao.dart
│   └── repositories/
│       ├── transaction_repository.dart
│       ├── category_repository.dart
│       ├── tag_repository.dart
│       ├── bank_account_repository.dart
│       ├── sms_repository.dart
│       ├── pattern_repository.dart
│       └── sender_repository.dart
├── features/
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── home_page.dart
│   │   │   ├── home_provider.dart
│   │   │   └── widgets/
│   │   │       ├── financial_overview_card.dart
│   │   │       └── transaction_list_item.dart
│   ├── sms/
│   │   ├── presentation/
│   │   │   ├── sms_processing_page.dart
│   │   │   ├── sms_processing_provider.dart
│   │   │   ├── unprocessed_sms_page.dart
│   │   │   └── widgets/
│   │   │       ├── sms_message_display.dart
│   │   │       ├── text_field_selector.dart
│   │   │       └── pattern_match_info.dart
│   │   └── services/
│   │       └── sms_parsing_service.dart
│   ├── settings/
│   │   ├── presentation/
│   │   │   ├── settings_page.dart
│   │   │   ├── settings_provider.dart
│   │   │   └── subpages/
│   │   │       ├── category_management_page.dart
│   │   │       ├── account_management_page.dart
│   │   │       ├── tag_management_page.dart
│   │   │       ├── pattern_management_page.dart
│   │   │       └── ignored_senders_page.dart
│   ├── analytics/
│   │   └── presentation/
│   │       └── analytics_page.dart
│   └── accounts/
│       └── presentation/
│           └── account_page.dart
├── services/
│   ├── sms_service.dart
│   ├── notification_service.dart
│   └── background_sms_service.dart
└── main.dart
```

### 1.2 pubspec.yaml Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_riverpod: ^2.5.0
  # Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.20
  path_provider: ^2.1.4
  path: ^1.9.0
  # SMS
  flutter_sms_inbox: ^2.2.0
  permission_handler: ^11.3.0
  # Notifications
  flutter_local_notifications: ^17.2.1
  # Platform Channels
  flutter_background_service: ^5.0.10
  # UI
  flutter_svg: ^2.0.10+1
  material_color_utilities: ^0.11.1
  # Utils
  intl: ^0.19.0
  shared_preferences: ^2.2.3
  # Icons
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.14.0
  build_runner: ^2.4.12
  flutter_lints: ^4.0.0
```

---

## Phase 2: Database Layer (Drift)

### 2.1 Database Schema

#### Tables to Create:
1. **transactions**
   - id (INTEGER PRIMARY KEY AUTOINCREMENT)
   - counter_party (TEXT NOT NULL)
   - amount (REAL NOT NULL)
   - timestamp (INTEGER NOT NULL)
   - category_id (TEXT, FOREIGN KEY → categories.id)
   - description (TEXT)
   - account_id (TEXT, FOREIGN KEY → bank_accounts.id)
   - transaction_type (TEXT NOT NULL) - 'CREDIT' or 'DEBIT'
   - reference_number (TEXT)

2. **categories**
   - id (INTEGER PRIMARY KEY AUTOINCREMENT)
   - icon (TEXT NOT NULL)
   - name (TEXT NOT NULL)
   - color (INTEGER NOT NULL)
   - description (TEXT)

3. **tags**
   - id (INTEGER PRIMARY KEY AUTOINCREMENT)
   - name (TEXT NOT NULL)
   - color (TEXT NOT NULL)

4. **transaction_tags**
   - id (INTEGER PRIMARY KEY AUTOINCREMENT)
   - tag_id (TEXT, FOREIGN KEY → tags.id)
   - transaction_id (TEXT, FOREIGN KEY → transactions.id)

5. **bank_accounts**
   - id (INTEGER PRIMARY KEY AUTOINCREMENT)
   - account_name (TEXT NOT NULL)
   - account_number (TEXT NOT NULL)
   - description (TEXT)

6. **sms**
   - id (INTEGER PRIMARY KEY AUTOINCREMENT)
   - sender (TEXT NOT NULL)
   - message (TEXT NOT NULL)
   - timestamp (INTEGER NOT NULL)
   - processed (INTEGER NOT NULL DEFAULT 0)

7. **sms_parsing_patterns**
   - id (INTEGER PRIMARY KEY AUTOINCREMENT)
   - sender_identifier (TEXT NOT NULL)
   - pattern_name (TEXT NOT NULL)
   - message_structure (TEXT NOT NULL)
   - amount_pattern (TEXT NOT NULL)
   - counterparty_pattern (TEXT NOT NULL)
   - date_pattern (TEXT)
   - reference_pattern (TEXT)
   - transaction_type (TEXT NOT NULL)
   - is_active (INTEGER NOT NULL DEFAULT 1)
   - default_category_id (TEXT)
   - default_account_id (TEXT)
   - auto_select_account (INTEGER NOT NULL DEFAULT 0)
   - sender_name (TEXT)
   - sample_sms (TEXT)
   - created_timestamp (INTEGER NOT NULL)
   - last_used_timestamp (INTEGER)

8. **senders**
   - id (INTEGER PRIMARY KEY)
   - sender_name (TEXT NOT NULL)
   - account_id (TEXT, FOREIGN KEY → bank_accounts.id)
   - description (TEXT)
   - is_ignored (INTEGER NOT NULL DEFAULT 0)
   - ignore_reason (TEXT)
   - ignored_at (INTEGER)

---

## Phase 3: Data Models & Repositories

### 3.1 Data Models
- Transaction
- Category
- Tag
- BankAccount
- SMS
- SMSParsingPattern
- Sender
- TransactionType enum
- FieldType enum

### 3.2 Repository Pattern
Implement repositories for:
- TransactionRepository
- CategoryRepository
- TagRepository
- BankAccountRepository
- SMSRepository
- PatternRepository
- SenderRepository

---

## Phase 4: SMS Service (Critical)

### 4.1 SMS Reading
- Use flutter_sms_inbox to query SMS
- Filter by sender patterns (BANK, UPI, -S suffix)
- Parse timestamp and sender info
- Store in database
- Maintain cache of 50 most recent SMS

### 4.2 SMS Parsing Logic
Port from SMSUtils.kt:
1. Pattern matching algorithm (structure-based)
2. Amount extraction (position-based with cleaning)
3. Counterparty extraction
4. Reference number extraction
5. Validation scoring
6. Threshold: 50% match score
7. Best pattern selection based on score + recency

### 4.3 Auto-Create Transactions
When SMS matches pattern:
- Extract amount, counterparty, reference
- Create transaction with default category/account
- Update last_used_timestamp of pattern

---

## Phase 5: Notification Service (Critical)

### 5.1 Notification Setup
- Use flutter_local_notifications
- Channel: "Transaction Alerts" (IMPORTANCE_HIGH)
- Show: Sender, Amount (if extractable), Message body
- High priority, visible on lockscreen
- Auto-cancel after 60 seconds

### 5.2 Notification Actions
1. **Add Transaction** - Navigate to SMS processing page
2. **Not This SMS** - Delete SMS only
3. **Ignore Sender** - Mark sender as ignored, delete SMS

### 5.3 Handling Actions
- Update database accordingly
- Cancel notification
- Refresh UI if app is open

---

## Phase 6: State Management (Riverpod)

### 6.1 Providers to Create
- Database instance provider
- All repository providers
- User preferences provider (theme, currency, setup status)
- SMS processing state provider
- Filtering and search state providers

### 6.2 State Notifiers
- TransactionListNotifier (with filtering)
- SMSProcessingNotifier
- SettingsNotifier
- PermissionNotifier

---

## Phase 7: UI Implementation

### 7.1 Home Page
- Financial overview card (balance, income, expense)
- Account and category summary
- Recent transactions list (last 20)
- FAB for unprocessed SMS with badge count

### 7.2 SMS Processing Page
- Display SMS message with word highlighting
- Interactive text selection for:
  - Amount
  - Counterparty
  - Reference
- Pattern matching display
- Category/account/tag selection
- Transaction type toggle (Credit/Debit)
- Save transaction button

### 7.3 Settings Page
- Theme toggle (Light/Dark/System)
- Currency configuration
- Category management (CRUD)
- Account management (CRUD)
- Tag management (CRUD)
- Pattern management (CRUD, enable/disable)
- Ignored senders list
- Data export/import
- India sender ruleset toggle

### 7.4 Analytics Page
- Placeholder for future enhancements

### 7.5 Unprocessed SMS Page
- List of all unprocessed SMS
- Navigate to processing page
- Bulk delete option

### 7.6 Navigation Sidebar
- Slide-in navigation
- Route highlighting
- Smooth animations

---

## Phase 8: Theme & Styling

### 8.1 Color Scheme (Preserve Original)
- Primary: 0xFF4361EE (Purple)
- Income: 0xFF06D6A0 (Green)
- Expense: 0xFFEF476F (Red)
- Success: 0xFF06D6A0
- Error: 0xFFEF476F
- Warning: 0xFFFFD166

### 8.2 Theme Variants
- Light Theme
- Dark Theme
- System Theme (follow device)

### 8.3 Custom Components
- Custom cards with rounded corners
- Custom FAB with badge
- Custom list items
- Custom dropdowns

---

## Phase 9: Permission Handling

### 9.1 Required Permissions
- READ_SMS
- RECEIVE_SMS
- POST_NOTIFICATIONS
- FOREGROUND_SERVICE

### 9.2 Permission Flow
1. Check permissions on app launch
2. Request if not granted
3. Show rationale if denied
4. Deep link to settings if permanently denied
5. Handle permission changes in UI

---

## Phase 10: SMS Receiver (Android Platform Channel)

### 10.1 Native Android Code
1. Create BroadcastReceiver for SMS_RECEIVED
2. Use MethodChannel to communicate with Flutter
3. Trigger notification on new SMS
4. Store SMS in database
5. Auto-parse transactions using patterns
6. Cache management (keep 50 SMS)

### 10.2 Background Processing
- Use flutter_background_service for reliability
- Ensure SMS processing happens when app is closed
- Handle edge cases (low memory, battery optimization)

---

## Phase 11: Feature Migration

### 11.1 SMS Parsing Patterns
- Create pattern from SMS
- Test pattern with sample SMS
- Enable/disable patterns
- Delete patterns
- View pattern usage statistics

### 11.2 Transaction Tags
- Create/delete tags
- Assign multiple tags to transactions
- Filter transactions by tags
- Tag color selection

### 11.3 Sender Management
- View all senders
- Mark senders as ignored
- Add ignore reason
- Unmark ignored senders

### 11.4 Data Export/Import
- Export all data to JSON
- Import from JSON
- Reset all data
- Validation on import

---

## Phase 12: Polish & Testing

### 12.1 Testing Checklist
- SMS parsing accuracy (various banks)
- Notification delivery (foreground, background, killed)
- Database operations (CRUD)
- Permission handling flows
- Edge cases (malformed SMS, empty data, etc.)
- Performance (large datasets)

### 12.2 Error Handling
- Graceful degradation
- User-friendly error messages
- Logging for debugging
- Crash reporting

### 12.3 Optimization
- Lazy loading for large lists
- Database indexing
- Image caching
- Memory management

---

## Key Technical Considerations

### SMS Pattern Matching Algorithm
1. Convert SMS to word array
2. Build message structure ([AMOUNT], [COUNTERPARTY], [TEXT], etc.)
3. Compare with stored pattern structures
4. Calculate match score
5. Validate extracted data
6. Select best pattern (score + recency)

### Amount Extraction Rules
- Extract numeric values
- Remove currency symbols (Rs., ₹, INR)
- Remove commas
- Handle decimal points
- Clean leading/trailing dots

### Transaction Type Detection
- Credit: income words (received, credited, added)
- Debit: expense words (debited, spent, paid, purchased)

### Sender Filtering
- Ends with "-S" (Indian bank SMS)
- Contains "BANK"
- Contains "UPI"
- Contains "TRANSACTION"
- User-defined ignored senders

---

## Migration Progress

- [x] Phase 1: Project Setup & Architecture
- [ ] Phase 2: Database Layer (Drift)
- [ ] Phase 3: Data Models & Repositories
- [ ] Phase 4: SMS Service (Critical)
- [ ] Phase 5: Notification Service (Critical)
- [ ] Phase 6: State Management (Riverpod)
- [ ] Phase 7: UI Implementation
- [ ] Phase 8: Theme & Styling
- [ ] Phase 9: Permission Handling
- [ ] Phase 10: SMS Receiver (Android Platform Channel)
- [ ] Phase 11: Feature Migration
- [ ] Phase 12: Polish & Testing

---

## Notes

### Why Drift?
- Type-safe database queries
- Compile-time verification
- Automatic migrations
- Similar to Room (familiar concepts)
- Excellent Flutter integration

### Why Riverpod?
- Compile-time safety
- No BuildContext requirement for providers
- Excellent testing support
- Better performance than Provider
- Modern and actively maintained

### Why flutter_sms_inbox?
- Simple and reliable
- Direct SMS reading (no background service complexity for reading)
- Well-maintained
- Good documentation

### SMS Processing Flow
1. Native Android receiver detects SMS
2. Stores SMS in database
3. Shows notification
4. User taps notification
5. Flutter app opens SMS processing page
6. User selects fields and saves transaction
7. Pattern is learned for future auto-detection

---

## Next Steps

1. Create project structure
2. Set up dependencies
3. Implement database layer
4. Implement SMS service
5. Implement notification service
6. Build UI pages
7. Implement platform channels
8. Test thoroughly
9. Deploy to device

---

*Last Updated: January 27, 2026*
