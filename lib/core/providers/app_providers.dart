import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../../data/repositories/bank_account_repository.dart';
import '../../data/repositories/sms_repository.dart';
import '../../data/repositories/pattern_repository.dart';
import '../../data/repositories/sender_repository.dart';
import '../../data/models/transaction_model.dart' as models;
import '../../data/models/category.dart' as models;
import '../../data/models/tag.dart' as models;
import '../../data/models/bank_account.dart' as models;
import '../../data/models/sms_parsing_pattern.dart' as models;
import '../../data/models/sms.dart' as models;
import '../../data/models/sender.dart' as models;
import '../../data/models/financial_overview.dart';
import '../../data/models/account_analytics.dart';
import '../../services/permission_service.dart';
import '../../services/sms_service.dart';
import '../../services/notification_service.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database must be initialized in main.dart');
});

// Repository Providers
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepository(db);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepository(db.categoryDao);
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TagRepository(db.tagDao);
});

final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BankAccountRepository(db.bankAccountDao);
});

final smsRepositoryProvider = Provider<SMSRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SMSRepository(db.smsDao);
});

final patternRepositoryProvider = Provider<PatternRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PatternRepository(db.patternDao);
});

final senderRepositoryProvider = Provider<SenderRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SenderRepository(db.senderDao);
});

// Service Providers
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final smsServiceProvider = Provider<SMSService>((ref) {
  return SMSService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// SharedPreferences Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// Theme Mode Provider
final themeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final themeMode = prefs.getString('theme_mode') ?? 'system';
  switch (themeMode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});

// Setup Status Provider
final setupCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getBool('setup_completed') ?? false;
});

// Currency Provider
final currencyProvider = FutureProvider<String>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getString('currency') ?? '₹';
});

// Unprocessed SMS Count Provider
final unprocessedSMSCountProvider = FutureProvider<int>((ref) async {
  final smsRepo = ref.watch(smsRepositoryProvider);
  final count = await smsRepo.getUnprocessedCount();
  return count;
});

// Unprocessed SMS List Provider
final unprocessedSMSProvider = FutureProvider<List<models.SMSMessage>>((
  ref,
) async {
  final smsRepo = ref.watch(smsRepositoryProvider);
  return await smsRepo.getUnprocessedSMS();
});

// Transaction List Provider
final transactionListProvider = FutureProvider<List<models.Transaction>>((
  ref,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return await repo.getAllTransactions();
});

// Recent Transactions Provider
final recentTransactionsProvider = FutureProvider<List<models.Transaction>>((
  ref,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return await repo.getRecentTransactions(20);
});

// Financial Overview Provider
final financialOverviewProvider = FutureProvider<FinancialOverview>((
  ref,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final results = await Future.wait([
    repo.getTotalBalance(),
    repo.getTotalIncome(),
    repo.getTotalExpense(),
  ]);
  return FinancialOverview(
    balance: results[0],
    income: results[1],
    expense: results[2],
  );
});

// Account Analytics Provider (family provider for specific account)
final accountAnalyticsProvider =
    FutureProvider.family<AccountAnalytics, String>((ref, accountId) async {
      final repo = ref.watch(transactionRepositoryProvider);
      final results = await Future.wait([
        repo.getAccountBalance(accountId),
        repo.getAccountIncome(accountId),
        repo.getAccountExpense(accountId),
        repo.getAccountTransactionCount(accountId),
        repo.getAccountMonthlyAvgIncome(accountId),
        repo.getAccountMonthlyAvgExpense(accountId),
        repo.getAccountLastTransactionDate(accountId),
      ]);
      return AccountAnalytics(
        balance: results[0] as double,
        totalIncome: results[1] as double,
        totalExpense: results[2] as double,
        transactionCount: results[3] as int,
        avgMonthlyIncome: results[4] as double,
        avgMonthlyExpense: results[5] as double,
        lastTransactionDate: results[6] as DateTime?,
      );
    });

// Categories Provider
final categoriesProvider = FutureProvider<List<models.Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return await repo.getAllCategories();
});

// Bank Accounts Provider
final bankAccountsProvider = FutureProvider<List<models.BankAccount>>((
  ref,
) async {
  final repo = ref.watch(bankAccountRepositoryProvider);
  return await repo.getAllAccounts();
});

// Tags Provider
final tagsProvider = FutureProvider<List<models.Tag>>((ref) async {
  final repo = ref.watch(tagRepositoryProvider);
  return await repo.getAllTags();
});

// SMS Patterns Provider
final patternsProvider = FutureProvider<List<models.SMSParsingPattern>>((
  ref,
) async {
  final repo = ref.watch(patternRepositoryProvider);
  return await repo.getAllPatterns();
});

// Recent SMS Provider
final recentSMSProvider = FutureProvider<List<models.SMSMessage>>((ref) async {
  final smsRepo = ref.watch(smsRepositoryProvider);
  return await smsRepo.getRecentSMS(20);
});

// Ignored Senders Provider
final ignoredSendersProvider = FutureProvider<List<models.Sender>>((ref) async {
  final senderRepo = ref.watch(senderRepositoryProvider);
  return await senderRepo.getIgnoredSenders();
});
