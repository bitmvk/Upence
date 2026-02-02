import 'package:drift/drift.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/data/local/database/tables/categories.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(AppDatabase db) : super(db);

  Future<List<Category>> getAllCategories({int? limit, int? offset}) async {
    final query = select(categories);
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  Future<Category?> getCategory(int id) async {
    return (select(
      categories,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertCategory(Category category) {
    return into(categories).insert(category);
  }

  Future<bool> updateCategory(Category category) {
    return update(categories).replace(category);
  }

  Future<int> deleteCategory(int id) {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }
}
