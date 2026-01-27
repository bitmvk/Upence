import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tags.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(AppDatabase db) : super(db);

  Future<List<Tag>> getAllTags() => select(tags).get();

  Future<Tag?> getTagById(int id) =>
      (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTag(TagsCompanion tag) => into(tags).insert(tag);

  Future<bool> updateTag(Tag tag) => update(tags).replace(tag);

  Future<bool> deleteTag(int id) async {
    final count = await (delete(tags)..where((t) => t.id.equals(id))).go();
    return count > 0;
  }
}
