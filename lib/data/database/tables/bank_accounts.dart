import 'package:drift/drift.dart';

@DataClassName('BankAccount')
class BankAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountName => text()();
  TextColumn get accountNumber => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get accountIcon => text()();
}
