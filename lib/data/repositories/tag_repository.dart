import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/dao/tag_dao.dart';
import '../models/tag.dart' as models;

class TagRepository {
  final TagDao _tagDao;

  TagRepository(this._tagDao);

  Future<List<models.Tag>> getAllTags() async {
    final tags = await _tagDao.getAllTags();
    return tags.map(_toModel).toList();
  }

  Future<models.Tag?> getTagById(int id) async {
    final tag = await _tagDao.getTagById(id);
    if (tag == null) return null;
    return _toModel(tag);
  }

  Future<int> insertTag(models.Tag tag) async {
    final companion = TagsCompanion(
      name: Value(tag.name),
      color: Value(tag.color),
    );
    return await _tagDao.insertTag(companion);
  }

  Future<bool> updateTag(models.Tag tag) async {
    final dbTag = Tag(id: tag.id, name: tag.name, color: tag.color);
    return await _tagDao.updateTag(dbTag);
  }

  Future<bool> deleteTag(int id) => _tagDao.deleteTag(id);

  models.Tag _toModel(Tag t) {
    return models.Tag(id: t.id, name: t.name, color: t.color);
  }
}
