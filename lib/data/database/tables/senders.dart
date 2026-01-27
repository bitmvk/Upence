import 'package:drift/drift.dart';
import 'bank_accounts.dart';

@DataClassName('Sender')
class Senders extends Table {
  IntColumn get id => integer()();
  TextColumn get senderName => text()();
  TextColumn get accountId => text().references(BankAccounts, #id)();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get isIgnored => integer().withDefault(const Constant(0))();
  TextColumn get ignoreReason => text().nullable()();
  IntColumn get ignoredAt => integer().nullable()();
}
