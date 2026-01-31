import 'package:drift/drift.dart';

@DataClassName('RegexSenderPattern')
class RegexSenderPatterns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get regexPattern => text()();
  TextColumn get description => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  IntColumn get createdTimestamp => integer()();
}
