import 'package:drift/drift.dart';

@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get counterParty => text()();
  RealColumn get amount => real()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get categoryId => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get accountId => text()();
  TextColumn get transactionType => text()();
  TextColumn get referenceNumber => text().withDefault(const Constant(''))();
}
