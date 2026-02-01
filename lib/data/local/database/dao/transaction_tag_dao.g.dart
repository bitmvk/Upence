// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_tag_dao.dart';

// ignore_for_file: type=lint
mixin _$TransactionTagDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsTable get tags => attachedDatabase.tags;
  $BankAccountsTable get bankAccounts => attachedDatabase.bankAccounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $SmsMessagesTable get smsMessages => attachedDatabase.smsMessages;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $TransactionTagsTable get transactionTags => attachedDatabase.transactionTags;
  TransactionTagDaoManager get managers => TransactionTagDaoManager(this);
}

class TransactionTagDaoManager {
  final _$TransactionTagDaoMixin _db;
  TransactionTagDaoManager(this._db);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$BankAccountsTableTableManager get bankAccounts =>
      $$BankAccountsTableTableManager(_db.attachedDatabase, _db.bankAccounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$SmsMessagesTableTableManager get smsMessages =>
      $$SmsMessagesTableTableManager(_db.attachedDatabase, _db.smsMessages);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$TransactionTagsTableTableManager get transactionTags =>
      $$TransactionTagsTableTableManager(
        _db.attachedDatabase,
        _db.transactionTags,
      );
}
