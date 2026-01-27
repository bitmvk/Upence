// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sender_dao.dart';

// ignore_for_file: type=lint
mixin _$SenderDaoMixin on DatabaseAccessor<AppDatabase> {
  $BankAccountsTable get bankAccounts => attachedDatabase.bankAccounts;
  $SendersTable get senders => attachedDatabase.senders;
  SenderDaoManager get managers => SenderDaoManager(this);
}

class SenderDaoManager {
  final _$SenderDaoMixin _db;
  SenderDaoManager(this._db);
  $$BankAccountsTableTableManager get bankAccounts =>
      $$BankAccountsTableTableManager(_db.attachedDatabase, _db.bankAccounts);
  $$SendersTableTableManager get senders =>
      $$SendersTableTableManager(_db.attachedDatabase, _db.senders);
}
