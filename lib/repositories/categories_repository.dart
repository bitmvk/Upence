import 'package:upence/data/local/database/dao/category_dao.dart';
import 'package:upence/data/local/database/database.dart';

class CategoriesRepository {
  final CategoryDao _categoryDao;

  CategoriesRepository(this._categoryDao);

  Future<List<Category>> getAllCategories() async {
    return await _categoryDao.getAllCategories();
  }

  Future<Category?> getCategory(int id) async {
    return await _categoryDao.getCategory(id);
  }

  Future<int> addCategory(Category category) async {
    return await _categoryDao.insertCategory(category);
  }

  Future<int> deleteCategory(int id) async {
    return await _categoryDao.deleteCategory(id);
  }

  Future<bool> updateCategory(Category category) async {
    return await _categoryDao.updateCategory(category);
  }
}
