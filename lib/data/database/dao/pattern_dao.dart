import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sms_parsing_patterns.dart';

part 'pattern_dao.g.dart';

@DriftAccessor(tables: [SMSParsingPatterns])
class PatternDao extends DatabaseAccessor<AppDatabase> with _$PatternDaoMixin {
  PatternDao(super.db);

  Future<List<SMSParsingPattern>> getAllPatterns() =>
      select(sMSParsingPatterns).get();

  Future<List<SMSParsingPattern>> getActivePatterns() =>
      (select(sMSParsingPatterns)..where((p) => p.isActive.equals(1))).get();

  Future<List<SMSParsingPattern>> getPatternsBySender(String sender) => (select(
    sMSParsingPatterns,
  )..where((p) => p.senderIdentifier.equals(sender))).get();

  Future<SMSParsingPattern?> getPatternById(int id) => (select(
    sMSParsingPatterns,
  )..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertPattern(SMSParsingPatternsCompanion pattern) =>
      into(sMSParsingPatterns).insert(pattern);

  Future<bool> updatePattern(SMSParsingPattern pattern) =>
      update(sMSParsingPatterns).replace(pattern);

  Future<bool> updatePatternLastUsed(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final count =
        await (update(sMSParsingPatterns)..where((p) => p.id.equals(id))).write(
          SMSParsingPatternsCompanion(lastUsedTimestamp: Value(now)),
        );
    return count > 0;
  }

  Future<bool> togglePatternActive(int id, bool isActive) async {
    final count =
        await (update(sMSParsingPatterns)..where((p) => p.id.equals(id))).write(
          SMSParsingPatternsCompanion(isActive: Value(isActive ? 1 : 0)),
        );
    return count > 0;
  }

  Future<bool> deletePattern(int id) async {
    final count = await (delete(
      sMSParsingPatterns,
    )..where((p) => p.id.equals(id))).go();
    return count > 0;
  }
}
