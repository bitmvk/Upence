import 'package:drift/drift.dart';

@DataClassName('Tag')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
}
