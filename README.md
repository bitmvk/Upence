# Upence - Flutter Port

Flutter port of Upence Android SMS transaction tracker app.

## Current Status

### ✅ Completed
- [x] Project structure created
- [x] Dependencies configured (Drift, Riverpod, Material 3)
- [x] Database schema defined (8 tables)
- [x] Database code generated
- [x] Theme system (light/dark mode)
- [x] Basic app entry point with Riverpod
- [x] Core constants and utilities
- [x] Data models (Transaction, Category, Tag, BankAccount, SMS, Sender, SMSParsingPattern)

### ⏳️ In Progress
- SMS reading service (needs API verification)
- Notification service (needs API verification)
- SMS parsing and pattern matching
- Android platform channel for SMS receiver
- Transaction repositories
- UI implementation (home page, SMS processing, settings)
- Permission handling

### ❌ Not Started
- Transaction CRUD operations
- Category management UI
- Account management UI
- Tag management UI
- Pattern management UI
- Sender filtering UI
- Analytics page
- Data export/import
- India sender ruleset
- Background SMS processing

## Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
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
│   │   ├── sender.dart
│   │   ├── sms_parsing_pattern.dart
│   │   └── transaction_model.dart
│   └── database/
│       ├── app_database.dart
│       ├── app_database.g.dart (generated)
│       └── tables/
│           ├── transactions.dart
│           ├── categories.dart
│           ├── tags.dart
│           ├── transaction_tags.dart
│           ├── bank_accounts.dart
│           ├── sms.dart
│           ├── sms_parsing_patterns.dart
│           └── senders.dart
└── main.dart
```

## Tech Stack

- **Flutter**: 3.10.7+
- **Database**: Drift (SQLite)
- **State Management**: Riverpod
- **UI**: Material Design 3
- **SMS**: To be implemented (flutter_sms_inbox)
- **Notifications**: To be implemented (flutter_local_notifications)

## Database Schema

### Tables Created:
1. `transactions` - Financial transactions
2. `categories` - Transaction categories with icons and colors
3. `tags` - Transaction tags
4. `transaction_tags` - Junction table for transaction-tag relationships
5. `bank_accounts` - User's bank accounts
6. `sms` - Stored SMS messages
7. `sms_parsing_patterns` - Pattern matching rules for SMS parsing
8. `senders` - SMS sender filtering and ignore list

## Next Steps

1. **Implement SMS Service**:
   - Set up flutter_sms_inbox for reading SMS
   - Filter bank SMS messages (BANK, UPI, -S suffix)
   - Store SMS in database
   - Auto-delete old SMS (keep 50 most recent)

2. **Implement Notification Service**:
   - Set up flutter_local_notifications
   - Create notification channel
   - Show notifications for new SMS
   - Handle notification actions (Add Transaction, Ignore Sender, Not This SMS)

3. **Create Android Platform Channel**:
   - BroadcastReceiver for SMS_RECEIVED
   - Trigger Flutter notification
   - Auto-parse transactions using patterns

4. **Implement SMS Parsing**:
   - Port pattern matching algorithm from Kotlin
   - Structure-based matching (≥50% threshold)
   - Amount, counterparty, reference extraction
   - Auto-create transactions

5. **Build UI Pages**:
   - Home page with financial overview
   - SMS processing page with field selection
   - Settings page with all subpages
   - Analytics page
   - Navigation sidebar

6. **Add Permission Handling**:
   - SMS permissions (READ_SMS, RECEIVE_SMS)
   - Notification permission (POST_NOTIFICATIONS)
   - Foreground service permission
   - Permission request dialogs

7. **Create Repositories**:
   - TransactionRepository
   - CategoryRepository
   - TagRepository
   - BankAccountRepository
   - SMSRepository
   - PatternRepository
   - SenderRepository

## Critical Features (as per user request)

### SMS Reading
- ✅ Database schema ready
- ⏳️ Service implementation needed
- ⏳️ Query SMS inbox
- ⏳️ Filter bank-related messages
- ⏳️ Store in database

### Notifications
- ✅ Constants defined
- ⏳️ Service implementation needed
- ⏳️ Create notification channel
- ⏳️ Show high-priority notifications
- ⏳️ Handle action buttons
- ⏳️ Auto-cancel after 60 seconds

## How to Test

1. Run `flutter run -d android` to launch on emulator/device
2. App will show "Database initialized successfully!"
3. Next step: Implement SMS and notification services

## Original Features to Port

From Upence_old (Kotlin):
- Automatic SMS transaction tracking ✓
- Smart transaction parsing ⏳️
- Category management ⏳️
- Tag system ⏳️
- Multiple account support ⏳️
- Currency support ✓
- Detailed transaction history ⏳️
- Ignored senders ⏳️
- Material Design 3 ✓
- Dark/Light theme ✓
- Data management (export/import) ⏳️

## Notes

- The database uses Drift which provides compile-time safety
- Riverpod is used for state management
- Material 3 is used for theming
- SMS parsing will use a structure-based algorithm similar to the original Kotlin implementation
- The app is configured for Android only (minSdk 29, targetSdk 36)

---

*Last Updated: January 27, 2026*
