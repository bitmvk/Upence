import 'package:drift/drift.dart';
import 'package:upence/data/database/database.dart';
import 'package:upence/data/database/tables/transaction_tags.dart';

part 'transaction_tag_dao.g.dart';

@DriftAccessor(tables: [TransactionTags])
class TransactionTagDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionTagDaoMixin {
  TransactionTagDao(AppDatabase db) : super(db);

  Future<List<TransactionTag>> getAllTransactionTags({
    int? limit,
    int? offset,
  }) async {
    final query = select(transactionTags);
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<List<TransactionTag>> getTransactionTags({
    List<int>? tagIds,
    List<int>? transactionIds,
    int? limit,
    int? offset,
  }) async {
    final query = select(transactionTags);

    if (tagIds != null && tagIds.isNotEmpty) {
      query.where((tbl) => tbl.tagId.isIn(tagIds));
    }

    if (transactionIds != null && transactionIds.isNotEmpty) {
      query.where((tbl) => tbl.transactionId.isIn(transactionIds));
    }

    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  Future<int> insertTransactionTag(TransactionTag transactionTag) {
    return into(transactionTags).insert(transactionTag);
  }

  Future<int> deleteTransactionTag(int id) {
    return (delete(transactionTags)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> updateTagsForTransaction(
    int transactionId,
    List<int> tagIds,
  ) async {
    return transaction(() async {
      await (delete(
        transactionTags,
      )..where((tbl) => tbl.transactionId.equals(transactionId))).go();

      for (final tagId in tagIds) {
        await into(transactionTags).insert(
          TransactionTagsCompanion.insert(
            transactionId: transactionId,
            tagId: tagId,
          ),
        );
      }
    });
  }
}
