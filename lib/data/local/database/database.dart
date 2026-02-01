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
import 'dao/bank_account_dao.dart';
import 'dao/category_dao.dart';
import 'dao/tag_dao.dart';
import 'dao/parsing_pattern_dao.dart';
import 'dao/sender_filter_dao.dart';
import 'dao/sms_dao.dart';
import 'dao/transaction_dao.dart';
import 'dao/transaction_tag_dao.dart';

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
  daos: [
    BankAccountDao,
    CategoryDao,
    TagDao,
    ParsingPatternDao,
    SenderFilterDao,
    SmsDao,
    TransactionDao,
    TransactionTagDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  late final BankAccountDao bankAccountDao = BankAccountDao(this);
  late final CategoryDao categoryDao = CategoryDao(this);
  late final TagDao tagDao = TagDao(this);
  late final ParsingPatternDao parsingPatternDao = ParsingPatternDao(this);
  late final SenderFilterDao senderFilterDao = SenderFilterDao(this);
  late final SmsDao smsDao = SmsDao(this);
  late final TransactionDao transactionDao = TransactionDao(this);
  late final TransactionTagDao transactionTagDao = TransactionTagDao(this);

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
