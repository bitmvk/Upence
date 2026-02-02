import 'package:drift/drift.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/data/local/database/tables/parsing_patterns.dart';

part 'parsing_pattern_dao.g.dart';

@DriftAccessor(tables: [ParsingPatterns])
class ParsingPatternDao extends DatabaseAccessor<AppDatabase>
    with _$ParsingPatternDaoMixin {
  ParsingPatternDao(AppDatabase db) : super(db);

  Future<List<ParsingPattern>> getAllRules({int? limit, int? offset}) async {
    final query = select(parsingPatterns);
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<List<ParsingPattern>> getAllActiveRules({
    int? limit,
    int? offset,
  }) async {
    final query = select(parsingPatterns)
      ..where((tbl) => tbl.isActive.equals(true));
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<ParsingPattern?> getRule(int id) async {
    return (select(
      parsingPatterns,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertRule(ParsingPattern rule) {
    return into(parsingPatterns).insert(rule);
  }

  Future<bool> updateRule(ParsingPattern rule) {
    return update(parsingPatterns).replace(rule);
  }

  Future<int> deleteRule(int id) {
    return (delete(parsingPatterns)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<bool> deactivateRule(int id) async {
    final rowsAffected =
        await (update(parsingPatterns)..where((tbl) => tbl.id.equals(id)))
            .write(ParsingPatternsCompanion(isActive: const Value(false)));
    return rowsAffected > 0;
  }

  Future<bool> activateRule(int id) async {
    final rowsAffected =
        await (update(parsingPatterns)..where((tbl) => tbl.id.equals(id)))
            .write(ParsingPatternsCompanion(isActive: const Value(true)));
    return rowsAffected > 0;
  }
}
