import 'package:drift/drift.dart';

class UserProgressTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get totalPoints => integer().withDefault(const Constant(0))();

  IntColumn get currentLevel => integer().withDefault(const Constant(1))();

  IntColumn get currentStreak => integer().withDefault(const Constant(0))();

  DateTimeColumn get lastCompletionDate => dateTime().nullable()();

  BoolColumn get weeklyStreakRewardClaimed =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
