import 'package:drift/drift.dart';
import 'package:upence/data/database/database.dart';
import 'package:upence/data/database/tables/sms.dart';

part 'sms_dao.g.dart';

@DriftAccessor(tables: [SmsMessages])
class SmsDao extends DatabaseAccessor<AppDatabase> with _$SmsDaoMixin {
  SmsDao(AppDatabase db) : super(db);

  Future<List<Sms>> getAllSms({int? limit, int? offset}) async {
    final query = select(smsMessages);
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<Sms?> getSmsById(int id) async {
    return (select(
      smsMessages,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<Sms>> getSmsByIds(List<int> ids) async {
    return (select(smsMessages)..where((tbl) => tbl.id.isIn(ids))).get();
  }

  Future<List<Sms>> getSms({
    List<String>? statuses,
    bool? isDeleted,
    bool? isTransaction,
    int? limit,
    int? offset,
  }) async {
    final query = select(smsMessages);

    if (statuses != null && statuses.isNotEmpty) {
      query.where((tbl) => tbl.status.isIn(statuses));
    }

    if (isDeleted != null) {
      query.where((tbl) => tbl.isDeleted.equals(isDeleted));
    }

    if (isTransaction != null) {
      query.where((tbl) => tbl.isTransaction.equals(isTransaction));
    }

    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  Future<List<Sms>> getSmsBySender(
    String sender, {
    int? limit,
    int? offset,
  }) async {
    final query = select(smsMessages)
      ..where((tbl) => tbl.sender.equals(sender));
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<int> insertSms(Sms sms) {
    return into(smsMessages).insert(sms);
  }

  Future<int> deleteSms(int id) {
    return (delete(smsMessages)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<bool> markAsDeleted(int id) async {
    final rowsAffected =
        await (update(smsMessages)..where((tbl) => tbl.id.equals(id))).write(
          SmsMessagesCompanion(isDeleted: const Value(true)),
        );
    return rowsAffected > 0;
  }
}
