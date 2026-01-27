import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sms.dart';

part 'sms_dao.g.dart';

@DriftAccessor(tables: [SmsTable])
class SmsDao extends DatabaseAccessor<AppDatabase> with _$SmsDaoMixin {
  SmsDao(AppDatabase db) : super(db);

  Future<List<Sms>> getAllSMS() => select(smsTable).get();

  Future<List<Sms>> getUnprocessedSMS() =>
      (select(smsTable)..where((s) => s.processed.equals(0))).get();

  Future<Sms?> getSmsById(int id) =>
      (select(smsTable)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<List<Sms>> getSMSBySender(String sender) =>
      (select(smsTable)..where((s) => s.sender.equals(sender))).get();

  Future<List<Sms>> getRecentSMS(int limit) =>
      (select(smsTable)
            ..orderBy([(s) => OrderingTerm.desc(s.timestamp)])
            ..limit(limit))
          .get();

  Future<int> insertSMS(SmsTableCompanion sms) => into(smsTable).insert(sms);

  Future<bool> updateSMS(Sms sms) => update(smsTable).replace(sms);

  Future<bool> markAsProcessed(int id) async {
    final count = await (update(smsTable)..where((s) => s.id.equals(id))).write(
      const SmsTableCompanion(processed: Value(1)),
    );
    return count > 0;
  }

  Future<bool> deleteSMS(int id) async {
    final count = await (delete(smsTable)..where((s) => s.id.equals(id))).go();
    return count > 0;
  }

  Future<int> deleteAllProcessedSMS() =>
      (delete(smsTable)..where((s) => s.processed.equals(1))).go();

  Future<int> getUnprocessedCount() async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM sms WHERE processed = ?',
      variables: [Variable(0)],
      readsFrom: {smsTable},
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  }

  Future<void> maintainCacheLimit(int limit) async {
    final allSMS = await getRecentSMS(limit * 2);
    if (allSMS.length > limit) {
      final toDelete = allSMS.skip(limit).map((s) => s.id).toList();
      for (final id in toDelete) {
        await deleteSMS(id);
      }
    }
  }
}
