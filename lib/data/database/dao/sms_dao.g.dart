// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_dao.dart';

// ignore_for_file: type=lint
mixin _$SmsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SmsTableTable get smsTable => attachedDatabase.smsTable;
  SmsDaoManager get managers => SmsDaoManager(this);
}

class SmsDaoManager {
  final _$SmsDaoMixin _db;
  SmsDaoManager(this._db);
  $$SmsTableTableTableManager get smsTable =>
      $$SmsTableTableTableManager(_db.attachedDatabase, _db.smsTable);
}
