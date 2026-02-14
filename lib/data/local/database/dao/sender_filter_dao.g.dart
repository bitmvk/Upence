// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sender_filter_dao.dart';

// ignore_for_file: type=lint
mixin _$SenderFilterDaoMixin on DatabaseAccessor<AppDatabase> {
  $SenderFiltersTable get senderFilters => attachedDatabase.senderFilters;
  SenderFilterDaoManager get managers => SenderFilterDaoManager(this);
}

class SenderFilterDaoManager {
  final _$SenderFilterDaoMixin _db;
  SenderFilterDaoManager(this._db);
  $$SenderFiltersTableTableManager get senderFilters =>
      $$SenderFiltersTableTableManager(_db.attachedDatabase, _db.senderFilters);
}
