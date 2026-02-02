import 'package:drift/drift.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/data/local/database/tables/transactions.dart';

part 'transaction_dao.g.dart';

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}

class CompositeTransactions {
  final Transaction transaction;
  final BankAccount? account;
  final Category? category;
  final Sms? sms;
  final List<Tag> tags;

  CompositeTransactions({
    required this.transaction,
    this.account,
    this.category,
    this.sms,
    required this.tags,
  });
}

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(AppDatabase db) : super(db);

  Future<List<Transaction>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    final query = select(transactions);
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<Transaction?> getTransaction(int id) async {
    return (select(
      transactions,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<Transaction>> getTransactions({
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
  }) async {
    final query = select(transactions);

    if (ids != null && ids.isNotEmpty) {
      query.where((tbl) => tbl.id.isIn(ids));
    }

    if (accountIds != null && accountIds.isNotEmpty) {
      query.where((tbl) => tbl.accountId.isIn(accountIds));
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      query.where((tbl) => tbl.categoryId.isIn(categoryIds));
    }

    if (smsIds != null && smsIds.isNotEmpty) {
      query.where((tbl) => tbl.smsId.isIn(smsIds));
    }

    if (dateRange != null) {
      query.where(
        (tbl) => tbl.occurredAt.isBetweenValues(dateRange.start, dateRange.end),
      );
    }

    if (minAmount != null) {
      query.where((tbl) => tbl.amount.isBiggerOrEqualValue(minAmount));
    }

    if (maxAmount != null) {
      query.where((tbl) => tbl.amount.isSmallerOrEqualValue(maxAmount));
    }

    if (payees != null && payees.isNotEmpty) {
      query.where((tbl) => tbl.payee.isIn(payees));
    }

    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  Future<List<Transaction>> getAllTransactionsByType(
    String type, {
    int? limit,
    int? offset,
  }) async {
    final query = select(transactions)..where((tbl) => tbl.type.equals(type));
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<List<CompositeTransactions>> getCompositeTransactions(
    List<int> transactionIds,
  ) async {
    final transactionsList = await getTransactions(ids: transactionIds);

    final compositeTransactionsList = <CompositeTransactions>[];

    for (final transaction in transactionsList) {
      final account = await db.bankAccountDao.getAccount(
        transaction.accountId,
      );
      final category = transaction.categoryId != null
          ? await db.categoryDao.getCategory(transaction.categoryId!)
          : null;
      final sms = transaction.smsId != null
          ? await db.smsDao.getSms(transaction.smsId!)
          : null;

      final transactionTags = await db.transactionTagDao.getTransactionTags(
        transactionIds: [transaction.id],
      );
      final tagIds = transactionTags.map((tt) => tt.tagId).toList();

      final tags = <Tag>[];
      for (final tagId in tagIds) {
        final tag = await db.tagDao.getTag(tagId);
        if (tag != null) {
          tags.add(tag);
        }
      }

      compositeTransactionsList.add(
        CompositeTransactions(
          transaction: transaction,
          account: account,
          category: category,
          sms: sms,
          tags: tags,
        ),
      );
    }

    return compositeTransactionsList;
  }

  Future<int> insertTransaction(Transaction transaction) {
    return into(transactions).insert(transaction);
  }

  Future<bool> updateTransaction(Transaction transaction) {
    return update(transactions).replace(transaction);
  }

  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }
}
