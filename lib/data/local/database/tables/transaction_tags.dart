import 'package:drift/drift.dart';
import 'tags.dart';
import 'transactions.dart';

@DataClassName('TransactionTag')
class TransactionTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tagId => integer().references(Tags, #id)();
  IntColumn get transactionId => integer().references(Transactions, #id)();
}
