import 'package:drift/drift.dart';
import 'package:ascend/data/db/app_database.dart';
import 'package:ascend/data/db/tables/user_progress_table.dart';

part 'user_progress_dao.g.dart';

@DriftAccessor(tables: [UserProgressTable])
class UserProgressDao extends DatabaseAccessor<AppDatabase>
    with _$UserProgressDaoMixin {
  UserProgressDao(super.db);

  Future<UserProgressTableData?> getProgress() async {
    return (select(userProgressTable)..limit(1)).getSingleOrNull();
  }

  Future<int> insertProgress(UserProgressTableCompanion progress) {
    return into(userProgressTable).insert(progress);
  }

  Future<bool> updateProgress(UserProgressTableCompanion progress) {
    return (update(
      userProgressTable,
    )..where((t) => t.id.equals(1))).write(progress).then((rows) => rows > 0);
  }
}
