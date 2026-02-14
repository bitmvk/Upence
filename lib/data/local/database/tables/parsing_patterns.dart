import 'package:drift/drift.dart';
import 'bank_accounts.dart';
import 'categories.dart';

@DataClassName('ParsingPattern')
class ParsingPatterns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get senderPattern => text()();
  TextColumn get bodyPattern => text()();
  TextColumn get transactionType => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get defAccountId =>
      integer().references(BankAccounts, #id).nullable()();
  IntColumn get defCategoryId =>
      integer().references(Categories, #id).nullable()();
}
