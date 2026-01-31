import 'package:drift/drift.dart';

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  TextColumn get description => text().nullable()();
}
