import 'package:drift/drift.dart';
import 'package:upence/data/database/database.dart';
import 'package:upence/data/database/tables/sender_filters.dart';

part 'sender_filter_dao.g.dart';

@DriftAccessor(tables: [SenderFilters])
class SenderFilterDao extends DatabaseAccessor<AppDatabase>
    with _$SenderFilterDaoMixin {
  SenderFilterDao(AppDatabase db) : super(db);

  Future<List<SenderFilter>> getAllFilters({int? limit, int? offset}) async {
    final query = select(senderFilters);
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<List<SenderFilter>> getAllActiveFilters({
    int? limit,
    int? offset,
  }) async {
    final query = select(senderFilters)
      ..where((tbl) => tbl.isActive.equals(true));
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<SenderFilter?> getFilterById(int id) async {
    return (select(
      senderFilters,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertFilter(SenderFilter filter) {
    return into(senderFilters).insert(filter);
  }

  Future<bool> updateFilter(SenderFilter filter) {
    return update(senderFilters).replace(filter);
  }

  Future<int> deleteFilter(int id) {
    return (delete(senderFilters)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<bool> deactivateFilter(int id) async {
    final rowsAffected =
        await (update(senderFilters)..where((tbl) => tbl.id.equals(id))).write(
          SenderFiltersCompanion(isActive: const Value(false)),
        );
    return rowsAffected > 0;
  }
}
