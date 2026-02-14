import 'package:upence/data/local/database/dao/transaction_dao.dart';
import 'package:upence/data/local/database/dao/transaction_tag_dao.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/domain/models/composite_transaction.dart';

class TransactionsRepository {
  final TransactionDao _transactionDao;
  final TransactionTagDao _transactionTagDao;

  TransactionsRepository(this._transactionDao, this._transactionTagDao);

  Future<List<Transaction>> getTransactions(
    List<int>? ids,
    List<int>? accountIds,
    List<int>? categoryIds,
    List<int>? smsIds,
    AppDateTimeRange? dateRange,
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

  Future<List<CompositeTransaction>> getCompositeTransactions(
    List<int> ids,
  ) async {
    return await _transactionDao.getCompositeTransactions(ids);
  }

  Future<int> createTransaction(
    Transaction transaction, {
    List<int> tagIds = const [],
  }) async {
    final transactionId = await _transactionDao.insertTransaction(transaction);
    if (tagIds.isNotEmpty) {
      await _transactionTagDao.updateTagsForTransaction(transactionId, tagIds);
    }
    return transactionId;
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    return await _transactionDao.updateTransaction(transaction);
  }

  Future<int> deleteTransaction(int id) async {
    return await _transactionDao.deleteTransaction(id);
  }

  Future<void> updateTransactionTags(
    int transactionId,
    List<int> tagIds,
  ) async {
    await _transactionTagDao.updateTagsForTransaction(transactionId, tagIds);
  }
}
