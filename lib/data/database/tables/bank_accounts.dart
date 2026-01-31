import 'package:drift/drift.dart';

@DataClassName('BankAccount')
class BankAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get number => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text()();
}
