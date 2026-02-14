import 'package:drift/drift.dart';

@DataClassName('SenderFilter')
class SenderFilters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get pattern => text()();
  TextColumn get action => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get description => text().nullable()();
}
