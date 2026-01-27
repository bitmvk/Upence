import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/dao/category_dao.dart';
import '../models/category.dart' as models;

class CategoryRepository {
  final CategoryDao _categoryDao;

  CategoryRepository(this._categoryDao);

  Future<List<models.Category>> getAllCategories() async {
    final categories = await _categoryDao.getAllCategories();
    return categories.map(_toModel).toList();
  }

  Future<models.Category?> getCategoryById(int id) async {
    final category = await _categoryDao.getCategoryById(id);
    if (category == null) return null;
    return _toModel(category);
  }

  Future<int> insertCategory(models.Category category) async {
    final companion = CategoriesCompanion(
      icon: Value(category.icon),
      name: Value(category.name),
      color: Value(category.color),
      description: Value(category.description),
    );
    return await _categoryDao.insertCategory(companion);
  }

  Future<bool> updateCategory(models.Category category) async {
    final dbCategory = Category(
      id: category.id,
      icon: category.icon,
      name: category.name,
      color: category.color,
      description: category.description,
    );
    return await _categoryDao.updateCategory(dbCategory);
  }

  Future<bool> deleteCategory(int id) => _categoryDao.deleteCategory(id);

  models.Category _toModel(Category c) {
    return models.Category(
      id: c.id,
      icon: c.icon,
      name: c.name,
      color: c.color,
      description: c.description,
    );
  }
}
