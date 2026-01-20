# Upence

Upence is an Android application that automatically tracks your financial transactions through SMS messages. The app parses bank transaction SMS messages and categorizes them, helping you manage your finances effortlessly.

## Features

- **Automatic SMS Transaction Tracking** - Receives and parses transaction SMS messages from your bank
- **Smart Transaction Parsing** - Customizable patterns to extract transaction details
- **Category Management** - Organize transactions into customizable categories with icons and colors
- **Tag System** - Add tags to transactions for better organization and filtering
- **Multiple Account Support** - Manage multiple bank accounts
- **Currency Support** - Multi-currency formatting and display
- **Detailed Transaction History** - View and search through all your transactions
- **Ignored Senders** - Filter out SMS messages from unwanted senders
- **Material Design 3** - Modern, clean UI following Android's latest design guidelines
- **Dark/Light Theme** - Automatic theme switching based on system preferences
- **Data Management** - Export, import, and reset your transaction data
- **Privacy-Focused** - All data stored locally on your device using Room database

## Tech Stack

- **Language**: Kotlin
- **UI Framework**: Jetpack Compose with Material Design 3
- **Architecture**: MVVM with Compose ViewModel
- **Database**: Room Database (SQLite)
- **Navigation**: Jetpack Navigation Compose
- **Data Storage**: DataStore Preferences
- **Build System**: Gradle with Kotlin DSL
- **Minimum SDK**: 29 (Android 10)
- **Target SDK**: 36

## Permissions

The app requires the following permissions:

- `READ_SMS` - To read transaction SMS messages
- `RECEIVE_SMS` - To receive new SMS messages
- `POST_NOTIFICATIONS` - To show transaction notifications
- `FOREGROUND_SERVICE` - For background SMS processing

## Installation

### Prerequisites

- Android Studio Hedgehog (2023.1.1) or later
- JDK 11 or later
- Android SDK with API level 36

### Build Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/bitmvk/Upence.git
   cd Upence
   ```

2. Open the project in Android Studio

3. Sync Gradle files

4. Build and run on an Android device or emulator:
   ```bash
   ./gradlew assembleDebug
   ./gradlew installDebug
   ```

## Project Structure

```
app/src/main/java/com/upence/
├── data/                    # Database models and DAOs
│   ├── AppDatabase.kt      # Room database configuration
│   ├── Transaction.kt       # Transaction entity
│   ├── Categories.kt       # Category entity
│   ├── Tags.kt            # Tag entity
│   ├── BankAccounts.kt    # Account entity
│   └── *.dao              # Data Access Objects
├── ui/                     # Compose UI screens and components
│   ├── HomePage.kt         # Main dashboard
│   ├── SettingsPage.kt     # Settings screen
│   ├── SMSPageEnhanced.kt  # Transaction list
│   ├── theme/             # App theme and styling
│   └── settings/          # Settings sub-pages
├── util/                   # Utility classes
│   ├── SMSUtils.kt        # SMS parsing utilities
│   ├── CurrencyFormatter.kt
│   └── IconUtils.kt
├── MainActivity.kt         # Main entry point
├── SmsReceiver.kt          # SMS broadcast receiver
└── NotificationActionReceiver.kt  # Notification action handler
```

## Usage

1. **Grant Permissions**: Allow SMS and notification permissions when prompted
2. **Setup Categories**: Create or customize transaction categories in Settings
3. **Add Accounts**: Add your bank accounts in Settings
4. **SMS Parsing**: Configure parsing patterns for your bank's SMS format
5. **Automatic Tracking**: The app will automatically detect and categorize transactions from SMS
6. **Manage Transactions**: View, edit, or delete transactions from the home screen

## Database Schema

The app uses Room database with the following main tables:

- `transactions` - Stores individual financial transactions
- `categories` - Stores transaction categories with icons and colors
- `tags` - Stores tags for transaction organization
- `bank_accounts` - Stores linked bank account information
- `senders` - Stores allowed and ignored SMS senders
- `sms_parsing_patterns` - Stores patterns for extracting transaction data

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Author

Built by [bitmvk](https://github.com/bitmvk)

## Privacy Notice

This application processes SMS messages locally on your device. No data is transmitted to external servers. All transaction data is stored in the local Room database.
