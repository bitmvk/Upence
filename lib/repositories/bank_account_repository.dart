import 'package:upence/data/local/database/dao/bank_account_dao.dart';
import 'package:upence/data/local/database/database.dart';

class BankAccountRepository {
  final BankAccountDao _bankAccountDao;

  BankAccountRepository(this._bankAccountDao);

  Future<List<BankAccount>> getAllBankAccounts() async {
    return await _bankAccountDao.getAllAccounts();
  }

  Future<BankAccount?> getBankAccount(int id) async {
    return await _bankAccountDao.getAccount(id);
  }

  Future<int> createBankAccount(BankAccount account) async {
    return await _bankAccountDao.insertAccount(account);
  }

  Future<bool> updateBankAccount(BankAccount account) async {
    return await _bankAccountDao.updateAccount(account);
  }

  Future<int> deleteBankAccount(int id) async {
    return await _bankAccountDao.deleteAccount(id);
  }
}
