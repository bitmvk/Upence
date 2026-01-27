import 'package:drift/drift.dart';
import 'tags.dart';
import 'transactions.dart';

@DataClassName('TransactionTag')
class TransactionTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tagId => text().references(Tags, #id)();
  TextColumn get transactionId => text().references(Transactions, #id)();
}
