// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_dao.dart';

// ignore_for_file: type=lint
mixin _$UserProgressDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProgressTableTable get userProgressTable =>
      attachedDatabase.userProgressTable;
  UserProgressDaoManager get managers => UserProgressDaoManager(this);
}

class UserProgressDaoManager {
  final _$UserProgressDaoMixin _db;
  UserProgressDaoManager(this._db);
  $$UserProgressTableTableTableManager get userProgressTable =>
      $$UserProgressTableTableTableManager(
        _db.attachedDatabase,
        _db.userProgressTable,
      );
}
