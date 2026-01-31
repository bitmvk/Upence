import 'package:drift/drift.dart';

@DataClassName('SenderIgnoreRule')
class SenderIgnoreRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ruleName => text()();
  TextColumn get regexPattern => text()();
  TextColumn get description => text().nullable()();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  IntColumn get isBundled => integer().withDefault(const Constant(0))();
  IntColumn get createdTimestamp => integer()();
}
