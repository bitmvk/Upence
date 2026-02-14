import 'package:upence/data/local/database/dao/tag_dao.dart';
import 'package:upence/data/local/database/database.dart';

class TagsRepository {
  final TagDao _tagDao;

  TagsRepository(this._tagDao);

  Future<List<Tag>> getAllTags() async {
    return await _tagDao.getAllTags();
  }

  Future<Tag?> getTag(int id) async {
    return await _tagDao.getTag(id);
  }

  Future<int> createTag(Tag tag) async {
    return await _tagDao.insertTag(tag);
  }

  Future<bool> updateTag(Tag tag) async {
    return await _tagDao.updateTag(tag);
  }

  Future<int> deleteTag(int id) async {
    return await _tagDao.deleteTag(id);
  }
}
