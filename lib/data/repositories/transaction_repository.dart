import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/transaction_model.dart' as models;
import '../models/transaction.dart' as enums;

class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository(this._db);

  Future<List<models.Transaction>> getAllTransactions() async {
    final transactions = await _db.transactionDao.getAllTransactions();
    return transactions.map(_toModel).toList();
  }

  Future<models.Transaction?> getTransactionById(int id) async {
    final transaction = await _db.transactionDao.getTransactionById(id);
    if (transaction == null) return null;
    return _toModel(transaction);
  }

  Future<List<models.Transaction>> getRecentTransactions(int limit) async {
    final transactions = await _db.transactionDao.getRecentTransactions(limit);
    return transactions.map(_toModel).toList();
  }

  Future<double> getTotalBalance() => _db.transactionDao.getTotalBalance();

  Future<double> getTotalIncome() => _db.transactionDao.getTotalIncome();

  Future<double> getTotalExpense() => _db.transactionDao.getTotalExpense();

  Future<double> getAccountBalance(String accountId) =>
      _db.transactionDao.getAccountBalance(accountId);

  Future<double> getAccountIncome(String accountId) =>
      _db.transactionDao.getAccountIncome(accountId);

  Future<double> getAccountExpense(String accountId) =>
      _db.transactionDao.getAccountExpense(accountId);

  Future<int> getAccountTransactionCount(String accountId) =>
      _db.transactionDao.getAccountTransactionCount(accountId);

  Future<double> getAccountMonthlyAvgIncome(String accountId) =>
      _db.transactionDao.getAccountMonthlyAvgIncome(accountId);

  Future<double> getAccountMonthlyAvgExpense(String accountId) =>
      _db.transactionDao.getAccountMonthlyAvgExpense(accountId);

  Future<DateTime?> getAccountLastTransactionDate(String accountId) =>
      _db.transactionDao.getAccountLastTransactionDate(accountId);

  Future<int> insertTransaction(models.Transaction transaction) async {
    final companion = TransactionsCompanion(
      counterParty: Value(transaction.counterParty),
      amount: Value(transaction.amount),
      timestamp: Value(transaction.timestamp),
      categoryId: Value(transaction.categoryId),
      description: Value(transaction.description),
      accountId: Value(transaction.accountId),
      transactionType: Value(transaction.transactionType.value),
      referenceNumber: Value(transaction.referenceNumber),
    );
    return await _db.transactionDao.insertTransaction(companion);
  }

  Future<bool> updateTransaction(models.Transaction transaction) async {
    final dbTransaction = Transaction(
      id: transaction.id,
      counterParty: transaction.counterParty,
      amount: transaction.amount,
      timestamp: transaction.timestamp,
      categoryId: transaction.categoryId,
      description: transaction.description,
      accountId: transaction.accountId,
      transactionType: transaction.transactionType.value,
      referenceNumber: transaction.referenceNumber,
    );
    return await _db.transactionDao.updateTransaction(dbTransaction);
  }

  Future<bool> deleteTransaction(int id) =>
      _db.transactionDao.deleteTransaction(id);

  models.Transaction _toModel(Transaction t) {
    return models.Transaction(
      id: t.id,
      counterParty: t.counterParty,
      amount: t.amount,
      timestamp: t.timestamp,
      categoryId: t.categoryId,
      description: t.description,
      accountId: t.accountId,
      transactionType: enums.TransactionType.values.firstWhere(
        (e) => e.value == t.transactionType,
        orElse: () => enums.TransactionType.debit,
      ),
      referenceNumber: t.referenceNumber,
    );
  }
}
