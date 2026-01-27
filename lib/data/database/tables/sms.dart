import 'package:drift/drift.dart';

@DataClassName('Sms')
class SmsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sender => text()();
  TextColumn get message => text()();
  IntColumn get timestamp => integer()();
  IntColumn get processed => integer().withDefault(const Constant(0))();
}
