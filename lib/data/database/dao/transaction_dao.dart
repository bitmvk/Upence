import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(AppDatabase db) : super(db);

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
      'SELECT SUM(CASE WHEN transactionType = ? THEN amount ELSE -amount END) as total FROM transactions',
      variables: [Variable('CREDIT')],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['total'] as double? ?? 0.0;
  }

  Future<double> getTotalIncome() async {
    final result = await customSelect(
      'SELECT SUM(amount) as total FROM transactions WHERE transactionType = ?',
      variables: [Variable('CREDIT')],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['total'] as double? ?? 0.0;
  }

  Future<double> getTotalExpense() async {
    final result = await customSelect(
      'SELECT SUM(amount) as total FROM transactions WHERE transactionType = ?',
      variables: [Variable('DEBIT')],
      readsFrom: {transactions},
    ).getSingle();
    return result.data['total'] as double? ?? 0.0;
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
