// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_dao.dart';

// ignore_for_file: type=lint
mixin _$PatternDaoMixin on DatabaseAccessor<AppDatabase> {
  $SMSParsingPatternsTable get sMSParsingPatterns =>
      attachedDatabase.sMSParsingPatterns;
  PatternDaoManager get managers => PatternDaoManager(this);
}

class PatternDaoManager {
  final _$PatternDaoMixin _db;
  PatternDaoManager(this._db);
  $$SMSParsingPatternsTableTableManager get sMSParsingPatterns =>
      $$SMSParsingPatternsTableTableManager(
        _db.attachedDatabase,
        _db.sMSParsingPatterns,
      );
}
