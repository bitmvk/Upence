import 'package:drift/drift.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/data/local/database/tables/transactions.dart';
import 'package:upence/domain/models/composite_transaction.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

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

  Future<List<CompositeTransaction>> getCompositeTransactions(
    List<int> transactionIds,
  ) async {
    if (transactionIds.isEmpty) return [];

    final transactionsList = await getTransactions(ids: transactionIds);
    if (transactionsList.isEmpty) return [];

    final transactionIdSet = transactionsList.map((t) => t.id).toSet();
    final accountIds = transactionsList.map((t) => t.accountId).toSet();
    final categoryIds = transactionsList
        .where((t) => t.categoryId != null)
        .map((t) => t.categoryId!)
        .toSet();
    final smsIds = transactionsList
        .where((t) => t.smsId != null)
        .map((t) => t.smsId!)
        .toSet();

    final accounts = accountIds.isEmpty
        ? <BankAccount>[]
        : await (select(
            db.bankAccounts,
          )..where((tbl) => tbl.id.isIn(accountIds))).get();
    final accountsMap = {for (var a in accounts) a.id: a};

    final categories = categoryIds.isEmpty
        ? <Category>[]
        : await (select(
            db.categories,
          )..where((tbl) => tbl.id.isIn(categoryIds))).get();
    final categoriesMap = {for (var c in categories) c.id: c};

    final smsMessages = smsIds.isEmpty
        ? <Sms>[]
        : await (select(
            db.smsMessages,
          )..where((tbl) => tbl.id.isIn(smsIds))).get();
    final smsMap = {for (var s in smsMessages) s.id: s};

    final transactionTags = await (select(
      db.transactionTags,
    )..where((tbl) => tbl.transactionId.isIn(transactionIdSet))).get();

    final tagIds = transactionTags.map((tt) => tt.tagId).toSet();
    final tags = tagIds.isEmpty
        ? <Tag>[]
        : await (select(db.tags)..where((tbl) => tbl.id.isIn(tagIds))).get();
    final tagsMap = {for (var t in tags) t.id: t};

    final Map<int, List<Tag>> transactionTagsMap = {};
    for (final tt in transactionTags) {
      transactionTagsMap.putIfAbsent(tt.transactionId, () => []);
      final tag = tagsMap[tt.tagId];
      if (tag != null) {
        transactionTagsMap[tt.transactionId]!.add(tag);
      }
    }

    return transactionsList.map((tx) {
      return CompositeTransaction(
        transaction: tx,
        account: accountsMap[tx.accountId],
        category: tx.categoryId != null ? categoriesMap[tx.categoryId] : null,
        sms: tx.smsId != null ? smsMap[tx.smsId] : null,
        tags: transactionTagsMap[tx.id] ?? [],
      );
    }).toList();
  }

  Future<int> insertTransaction(Transaction transaction) {
    return into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: transaction.accountId,
        amount: transaction.amount,
        type: transaction.type,
        occurredAt: transaction.occurredAt,
        categoryId: Value(transaction.categoryId),
        smsId: Value(transaction.smsId),
        payee: Value(transaction.payee),
        reference: Value(transaction.reference),
        description: Value(transaction.description),
      ),
    );
  }

  Future<bool> updateTransaction(Transaction transaction) {
    return update(transactions).replace(transaction);
  }

  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }
}
