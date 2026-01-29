import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  Future<Transaction?> getTransactionById(int id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Transaction>> getTransactionsByType(String type) => (select(
    transactions,
  )..where((t) => t.transactionType.equals(type))).get();

  Future<List<Transaction>> getTransactionsByCategory(String categoryId) =>
      (select(
        transactions,
      )..where((t) => t.categoryId.equals(categoryId))).get();

  Future<List<Transaction>> getTransactionsByAccount(String accountId) =>
      (select(transactions)..where((t) => t.accountId.equals(accountId))).get();

  Future<List<Transaction>> getRecentTransactions(int limit) =>
      (select(transactions)
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(limit))
          .get();

  Future<double> getTotalBalance() async {
    final result = await customSelect(
      'SELECT SUM(CASE WHEN transaction_type = ? THEN amount ELSE -amount END) as total FROM transactions',
      variables: [Variable('CREDIT')],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['total'] as double? ?? 0.0;
  }

  Future<double> getTotalIncome() async {
    final result = await customSelect(
      'SELECT SUM(amount) as total FROM transactions WHERE transaction_type = ?',
      variables: [Variable('CREDIT')],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['total'] as double? ?? 0.0;
  }

  Future<double> getTotalExpense() async {
    final result = await customSelect(
      'SELECT SUM(amount) as total FROM transactions WHERE transaction_type = ?',
      variables: [Variable('DEBIT')],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['total'] as double? ?? 0.0;
  }

  Future<double> getAccountBalance(String accountId) async {
    final result = await customSelect(
      'SELECT SUM(CASE WHEN transaction_type = ? THEN amount ELSE -amount END) as total FROM transactions WHERE account_id = ?',
      variables: [Variable('CREDIT'), Variable(accountId)],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['total'] as double? ?? 0.0;
  }

  Future<double> getAccountIncome(String accountId) async {
    final result = await customSelect(
      'SELECT SUM(amount) as total FROM transactions WHERE transaction_type = ? AND account_id = ?',
      variables: [Variable('CREDIT'), Variable(accountId)],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['total'] as double? ?? 0.0;
  }

  Future<double> getAccountExpense(String accountId) async {
    final result = await customSelect(
      'SELECT SUM(amount) as total FROM transactions WHERE transaction_type = ? AND account_id = ?',
      variables: [Variable('DEBIT'), Variable(accountId)],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['total'] as double? ?? 0.0;
  }

  Future<int> getAccountTransactionCount(String accountId) async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM transactions WHERE account_id = ?',
      variables: [Variable(accountId)],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  }

  Future<double> getAccountMonthlyAvgIncome(String accountId) async {
    final result = await customSelect(
      'SELECT SUM(amount) as total, MIN(timestamp) as firstTs, MAX(timestamp) as lastTs FROM transactions WHERE transaction_type = ? AND account_id = ?',
      variables: [Variable('CREDIT'), Variable(accountId)],
      readsFrom: {transactions},
    ).getSingle();

    final total = result.data['total'] as double? ?? 0.0;
    final firstTs = result.data['firstTs'] as int?;
    final lastTs = result.data['lastTs'] as int?;

    if (firstTs == null || lastTs == null) return 0.0;

    final firstDate = DateTime.fromMillisecondsSinceEpoch(firstTs);
    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastTs);

    final months =
        (lastDate.year - firstDate.year) * 12 +
        (lastDate.month - firstDate.month) +
        1;

    return months > 0 ? total / months : total;
  }

  Future<double> getAccountMonthlyAvgExpense(String accountId) async {
    final result = await customSelect(
      'SELECT SUM(amount) as total, MIN(timestamp) as firstTs, MAX(timestamp) as lastTs FROM transactions WHERE transaction_type = ? AND account_id = ?',
      variables: [Variable('DEBIT'), Variable(accountId)],
      readsFrom: {transactions},
    ).getSingle();

    final total = result.data['total'] as double? ?? 0.0;
    final firstTs = result.data['firstTs'] as int?;
    final lastTs = result.data['lastTs'] as int?;

    if (firstTs == null || lastTs == null) return 0.0;

    final firstDate = DateTime.fromMillisecondsSinceEpoch(firstTs);
    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastTs);

    final months =
        (lastDate.year - firstDate.year) * 12 +
        (lastDate.month - firstDate.month) +
        1;

    return months > 0 ? total / months : total;
  }

  Future<DateTime?> getAccountLastTransactionDate(String accountId) async {
    final result =
        await (select(transactions)
              ..where((t) => t.accountId.equals(accountId))
              ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
              ..limit(1))
            .getSingleOrNull();
    return result?.timestamp;
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);

  Future<bool> updateTransaction(Transaction transaction) =>
      update(transactions).replace(transaction);

  Future<bool> deleteTransaction(int id) async {
    final count = await (delete(
      transactions,
    )..where((t) => t.id.equals(id))).go();
    return count > 0;
  }
}
