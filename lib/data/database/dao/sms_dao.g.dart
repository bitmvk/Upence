// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_dao.dart';

// ignore_for_file: type=lint
mixin _$SmsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SmsMessagesTable get smsMessages => attachedDatabase.smsMessages;
  SmsDaoManager get managers => SmsDaoManager(this);
}

class SmsDaoManager {
  final _$SmsDaoMixin _db;
  SmsDaoManager(this._db);
  $$SmsMessagesTableTableManager get smsMessages =>
      $$SmsMessagesTableTableManager(_db.attachedDatabase, _db.smsMessages);
}
