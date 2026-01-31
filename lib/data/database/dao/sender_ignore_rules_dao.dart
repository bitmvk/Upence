import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sender_ignore_rules.dart';

part 'sender_ignore_rules_dao.g.dart';

@DriftAccessor(tables: [SenderIgnoreRules])
class SenderIgnoreRulesDao extends DatabaseAccessor<AppDatabase>
    with _$SenderIgnoreRulesDaoMixin {
  SenderIgnoreRulesDao(super.db);

  Future<List<SenderIgnoreRule>> getAllRules() =>
      select(senderIgnoreRules).get();

  Future<List<SenderIgnoreRule>> getActiveRules() =>
      (select(senderIgnoreRules)..where((r) => r.isActive.equals(1))).get();

  Future<List<SenderIgnoreRule>> getBundledRules() =>
      (select(senderIgnoreRules)..where((r) => r.isBundled.equals(1))).get();

  Future<List<SenderIgnoreRule>> getCustomRules() =>
      (select(senderIgnoreRules)..where((r) => r.isBundled.equals(0))).get();

  Future<int> insertRule(SenderIgnoreRulesCompanion rule) =>
      into(senderIgnoreRules).insert(rule);

  Future<bool> updateRule(SenderIgnoreRule rule) =>
      update(senderIgnoreRules).replace(rule);

  Future<bool> toggleRuleActive(int id, bool isActive) async {
    final count =
        await (update(senderIgnoreRules)..where((r) => r.id.equals(id))).write(
          SenderIgnoreRulesCompanion(isActive: Value(isActive ? 1 : 0)),
        );
    return count > 0;
  }

  Future<bool> deleteRule(int id) async {
    final count = await (delete(
      senderIgnoreRules,
    )..where((r) => r.id.equals(id))).go();
    return count > 0;
  }
}
