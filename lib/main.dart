import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'package:upence/core/theme/app_theme.dart';
import 'package:upence/core/providers/app_providers.dart';
import 'package:upence/data/database/app_database.dart';
import 'package:upence/features/home/presentation/home_page.dart';
import 'package:upence/features/settings/presentation/settings_page.dart';
import 'package:upence/features/analytics/presentation/analytics_page.dart';
import 'package:upence/features/accounts/presentation/account_page.dart';
import 'package:upence/features/onboarding/presentation/setup_page.dart';
import 'package:upence/features/transactions/presentation/transaction_list_page.dart';
import 'package:upence/features/transactions/presentation/transaction_details_page.dart';
import 'package:upence/features/settings/presentation/subpages/ignored_senders_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.getDatabase();

  // Set up SMS method channel
  const smsChannel = MethodChannel('com.upence.upence/sms');
  smsChannel.setMethodCallHandler((call) async {
    if (call.method == 'onSMSReceived') {
      final sender = call.arguments['sender'] as String?;
      final message = call.arguments['message'] as String?;
      final timestamp = call.arguments['timestamp'] as int?;

      if (sender != null && message != null && timestamp != null) {
        // Store SMS in database
        try {
          await database
              .into(database.smsTable)
              .insert(
                SmsTableCompanion(
                  sender: Value(sender),
                  message: Value(message),
                  timestamp: Value(timestamp),
                  processed: const Value(0),
                ),
              );
          debugPrint('SMS received and stored: $sender');
        } catch (e) {
          debugPrint('Error storing SMS: $e');
        }
      }
    }
  });

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupCompletedAsync = ref.watch(setupCompletedProvider);
    final themeModeAsync = ref.watch(themeModeProvider);

    return setupCompletedAsync.when(
      data: (setupCompleted) {
        return themeModeAsync.when(
          data: (themeMode) => MaterialApp(
            title: 'Upence',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: setupCompleted ? const MainApp() : const SetupPage(),
            routes: {'/accounts': (context) => const AccountPage()},
          ),
          loading: () => MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
          error: (error, stack) => MaterialApp(
            home: Scaffold(body: Center(child: Text('Error: $error'))),
          ),
        );
      },
      loading: () => MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);

    return themeModeAsync.when(
      data: (themeMode) => MaterialApp(
        title: 'Upence',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const HomePage(),
        routes: {
          '/analytics': (context) => const AnalyticsPage(),
          '/settings': (context) => const SettingsPage(),
          '/transactions': (context) => const TransactionListPage(),
          '/settings/ignored-senders': (context) => const IgnoredSendersPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name != null && settings.name!.startsWith('/transaction/')) {
            final id = int.tryParse(settings.name!.split('/')[2]);
            if (id != null) {
              return MaterialPageRoute(
                builder: (context) => TransactionDetailsPage(transactionId: id),
              );
            }
          }
          if (settings.name == '/accounts') {
            // Check if showBackButton argument is passed
            final showBackButton = settings.arguments as bool? ?? false;
            return MaterialPageRoute(
              builder: (context) => AccountPage(showBackButton: showBackButton),
            );
          }
          return null;
        },
      ),
      loading: () => MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}
