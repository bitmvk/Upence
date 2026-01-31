import 'package:drift/drift.dart';
import 'bank_accounts.dart';
import 'categories.dart';
import 'sms.dart';

@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(BankAccounts, #id)();
  IntColumn get categoryId =>
      integer().references(Categories, #id).nullable()();
  IntColumn get smsId => integer().references(SmsMessages, #id).nullable()();
  TextColumn get payee => text().nullable()();
  IntColumn get amount => integer()();
  TextColumn get type => text()();
  TextColumn get reference => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
}
