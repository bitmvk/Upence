import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/senders.dart';

part 'sender_dao.g.dart';

@DriftAccessor(tables: [Senders])
class SenderDao extends DatabaseAccessor<AppDatabase> with _$SenderDaoMixin {
  SenderDao(AppDatabase db) : super(db);

  Future<List<Sender>> getAllSenders() => select(senders).get();

  Future<List<Sender>> getIgnoredSenders() =>
      (select(senders)..where((s) => s.isIgnored.equals(1))).get();

  Future<Sender?> getSenderByName(String senderName) => (select(
    senders,
  )..where((s) => s.senderName.equals(senderName))).getSingleOrNull();

  Future<int> insertSender(SendersCompanion sender) =>
      into(senders).insert(sender);

  Future<bool> updateSender(Sender sender) => update(senders).replace(sender);

  Future<bool> markAsIgnored(String senderName, String? reason) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final count =
        await (update(
          senders,
        )..where((s) => s.senderName.equals(senderName))).write(
          SendersCompanion(
            isIgnored: const Value(1),
            ignoreReason: Value(reason),
            ignoredAt: Value(now),
          ),
        );
    return count > 0;
  }

  Future<bool> unmarkAsIgnored(String senderName) async {
    final count =
        await (update(
          senders,
        )..where((s) => s.senderName.equals(senderName))).write(
          const SendersCompanion(
            isIgnored: Value(0),
            ignoreReason: Value(null),
            ignoredAt: Value(null),
          ),
        );
    return count > 0;
  }

  Future<bool> deleteSender(int id) async {
    final count = await (delete(senders)..where((s) => s.id.equals(id))).go();
    return count > 0;
  }

  Future<bool> isSenderIgnored(String senderName) async {
    final sender = await getSenderByName(senderName);
    return (sender?.isIgnored ?? 0) == 1;
  }
}
