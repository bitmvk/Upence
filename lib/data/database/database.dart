import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/bank_accounts.dart';
import 'tables/categories.dart';
import 'tables/sms.dart';
import 'tables/tags.dart';
import 'tables/transaction_tags.dart';
import 'tables/transactions.dart';
import 'tables/parsing_patterns.dart';
import 'tables/sender_filters.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    BankAccounts,
    Categories,
    SmsMessages,
    Tags,
    TransactionTags,
    Transactions,
    ParsingPatterns,
    SenderFilters,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'upence_db');
  }
}
