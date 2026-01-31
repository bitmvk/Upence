import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/regex_sender_patterns.dart';

part 'regex_sender_patterns_dao.g.dart';

@DriftAccessor(tables: [RegexSenderPatterns])
class RegexSenderPatternsDao extends DatabaseAccessor<AppDatabase>
    with _$RegexSenderPatternsDaoMixin {
  RegexSenderPatternsDao(super.db);

  Future<List<RegexSenderPattern>> getAllPatterns() =>
      select(regexSenderPatterns).get();

  Future<List<RegexSenderPattern>> getActivePatterns() =>
      (select(regexSenderPatterns)
            ..where((p) => p.isActive.equals(1))
            ..orderBy([(p) => OrderingTerm.desc(p.priority)]))
          .get();

  Future<int> insertPattern(RegexSenderPatternsCompanion pattern) =>
      into(regexSenderPatterns).insert(pattern);

  Future<bool> updatePattern(RegexSenderPattern pattern) =>
      update(regexSenderPatterns).replace(pattern);

  Future<bool> deletePattern(int id) async {
    final count = await (delete(
      regexSenderPatterns,
    )..where((p) => p.id.equals(id))).go();
    return count > 0;
  }
}
