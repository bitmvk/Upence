import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/dao/bank_account_dao.dart';
import '../models/bank_account.dart' as models;

class BankAccountRepository {
  final BankAccountDao _bankAccountDao;

  BankAccountRepository(this._bankAccountDao);

  Future<List<models.BankAccount>> getAllAccounts() async {
    final accounts = await _bankAccountDao.getAllAccounts();
    return accounts.map(_toModel).toList();
  }

  Future<models.BankAccount?> getAccountById(int id) async {
    final account = await _bankAccountDao.getAccountById(id);
    if (account == null) return null;
    return _toModel(account);
  }

  Future<int> insertAccount(models.BankAccount account) async {
    final companion = BankAccountsCompanion(
      accountName: Value(account.accountName),
      accountNumber: Value(account.accountNumber),
      description: Value(account.description),
    );
    return await _bankAccountDao.insertAccount(companion);
  }

  Future<bool> updateAccount(models.BankAccount account) async {
    final dbAccount = BankAccount(
      id: account.id,
      accountName: account.accountName,
      accountNumber: account.accountNumber,
      description: account.description,
    );
    return await _bankAccountDao.updateAccount(dbAccount);
  }

  Future<bool> deleteAccount(int id) => _bankAccountDao.deleteAccount(id);

  models.BankAccount _toModel(BankAccount a) {
    return models.BankAccount(
      id: a.id,
      accountName: a.accountName,
      accountNumber: a.accountNumber,
      description: a.description,
    );
  }
}
