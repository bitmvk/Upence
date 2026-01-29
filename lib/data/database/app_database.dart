import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'tables/transactions.dart';
import 'tables/categories.dart';
import 'tables/tags.dart';
import 'tables/transaction_tags.dart';
import 'tables/bank_accounts.dart';
import 'tables/sms.dart';
import 'tables/sms_parsing_patterns.dart';
import 'tables/senders.dart';
import 'dao/transaction_dao.dart';
import 'dao/category_dao.dart';
import 'dao/tag_dao.dart';
import 'dao/bank_account_dao.dart';
import 'dao/sms_dao.dart';
import 'dao/pattern_dao.dart';
import 'dao/sender_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Transactions,
    Categories,
    Tags,
    TransactionTags,
    BankAccounts,
    SmsTable,
    SMSParsingPatterns,
    Senders,
  ],
  daos: [
    TransactionDao,
    CategoryDao,
    TagDao,
    BankAccountDao,
    SmsDao,
    PatternDao,
    SenderDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // For any upgrade, ensure all tables exist
        // This handles cases where the database file exists but tables are missing
        await m.createAll();
      },
    );
  }

  static Future<AppDatabase> getDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'upence.db'));

    // Check if database file exists and is corrupt (missing tables)
    if (await file.exists()) {
      final prefs = await SharedPreferences.getInstance();
      final setupCompleted = prefs.getBool('setup_completed') ?? false;
      
      // Only delete the database if setup is NOT completed
      // This ensures we don't lose data from a completed setup
      if (!setupCompleted) {
        debugPrint('[Database] Setup not completed, resetting database...');
        await file.delete();
      }
    }

    return AppDatabase(NativeDatabase.createInBackground(file));
  }
}
