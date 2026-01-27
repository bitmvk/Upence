import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(AppDatabase db) : super(db);

  Future<List<Category>> getAllCategories() => select(categories).get();

  Future<Category?> getCategoryById(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);

  Future<bool> deleteCategory(int id) async {
    final count = await (delete(
      categories,
    )..where((c) => c.id.equals(id))).go();
    return count > 0;
  }
}
