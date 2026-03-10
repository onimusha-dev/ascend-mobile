import 'package:drift/drift.dart';
import 'package:ascend/data/db/app_database.dart';
import 'package:ascend/data/db/tables/task_categories_table.dart';

part 'task_category_dao.g.dart';

@DriftAccessor(tables: [TaskCategoriesTable])
class TaskCategoryDao extends DatabaseAccessor<AppDatabase>
    with _$TaskCategoryDaoMixin {
  TaskCategoryDao(super.db);

  Stream<List<TaskCategoriesTableData>> watchAllCategories() =>
      select(taskCategoriesTable).watch();

  Future<List<TaskCategoriesTableData>> getAllCategories() =>
      select(taskCategoriesTable).get();

  Future<int> insertCategory(TaskCategoriesTableCompanion category) =>
      into(taskCategoriesTable).insert(category);

  Future<bool> updateCategory(TaskCategoriesTableData category) =>
      update(taskCategoriesTable).replace(category);

  Future<int> deleteCategory(int id) =>
      (delete(taskCategoriesTable)..where((t) => t.id.equals(id))).go();

  Future<int> deleteAllCategories() => delete(taskCategoriesTable).go();
}
