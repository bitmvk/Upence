import 'package:drift/drift.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/data/local/database/tables/tags.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<List<Tag>> getAllTags({int? limit, int? offset}) async {
    final query = select(tags);
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<Tag?> getTag(int id) async {
    return (select(tags)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<Tag?>> getTags(List<int> ids) async {
    return (select(tags)..where((tbl) => tbl.id.isIn(ids))).get();
  }

  Future<int> insertTag(Tag tag) {
    return into(tags).insert(tag);
  }

  Future<bool> updateTag(Tag tag) {
    return update(tags).replace(tag);
  }

  Future<int> deleteTag(int id) {
    return (delete(tags)..where((tbl) => tbl.id.equals(id))).go();
  }
}
