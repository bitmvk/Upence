import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/repositories/bank_account_repository.dart';
import 'package:upence/repositories/categories_repository.dart';
import 'package:upence/repositories/rules_repository.dart';
import 'package:upence/repositories/tags_repository.dart';
import 'package:upence/repositories/transactions_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionsRepository(db.transactionDao);
});

final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BankAccountRepository(db.bankAccountDao);
});

final rulesRepositoryProvider = Provider<RulesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RulesRepository(db.parsingPatternDao, db.senderFilterDao);
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoriesRepository(db.categoryDao);
});

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TagsRepository(db.tagDao);
});
