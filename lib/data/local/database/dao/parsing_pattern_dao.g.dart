// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsing_pattern_dao.dart';

// ignore_for_file: type=lint
mixin _$ParsingPatternDaoMixin on DatabaseAccessor<AppDatabase> {
  $BankAccountsTable get bankAccounts => attachedDatabase.bankAccounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ParsingPatternsTable get parsingPatterns => attachedDatabase.parsingPatterns;
  ParsingPatternDaoManager get managers => ParsingPatternDaoManager(this);
}

class ParsingPatternDaoManager {
  final _$ParsingPatternDaoMixin _db;
  ParsingPatternDaoManager(this._db);
  $$BankAccountsTableTableManager get bankAccounts =>
      $$BankAccountsTableTableManager(_db.attachedDatabase, _db.bankAccounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ParsingPatternsTableTableManager get parsingPatterns =>
      $$ParsingPatternsTableTableManager(
        _db.attachedDatabase,
        _db.parsingPatterns,
      );
}
