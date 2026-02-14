import 'package:upence/data/local/database/dao/transaction_dao.dart';
import 'package:upence/data/local/database/database.dart';

class TransactionsRepository {
  final TransactionDao _transactionDao;

  TransactionsRepository(this._transactionDao);

  Future<List<Transaction>> getTransactions(
    List<int>? ids,
    List<int>? accountIds,
    List<int>? categoryIds,
    List<int>? smsIds,
    DateTimeRange? dateRange,
    int? minAmount,
    int? maxAmount,
    List<String>? payees,
    int? limit,
    int? offset,
  ) async {
    return await _transactionDao.getTransactions(
      ids: ids,
      accountIds: accountIds,
      categoryIds: categoryIds,
      smsIds: smsIds,
      dateRange: dateRange,
      minAmount: minAmount,
      maxAmount: maxAmount,
      payees: payees,
      limit: limit,
      offset: offset,
    );
  }

  Future<Transaction?> getTransaction(int id) async {
    return await _transactionDao.getTransaction(id);
  }

  Future<List<CompositeTransactions>> getCompositeTransactions(
    List<int> ids,
  ) async {
    return await _transactionDao.getCompositeTransactions(ids);
  }

  Future<int> addTransaction(Transaction transaction) async {
    return await _transactionDao.insertTransaction(transaction);
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    return await _transactionDao.updateTransaction(transaction);
  }

  Future<int> deleteTransaction(int id) async {
    return await _transactionDao.deleteTransaction(id);
  }
}
