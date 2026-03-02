import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ascend/data/db/app_database.dart';

part 'user_progress_model.freezed.dart';

@freezed
abstract class UserProgressModel with _$UserProgressModel {
  const UserProgressModel._();

  factory UserProgressModel({
    required int id,
    required int totalPoints,
    required int currentLevel,
    required int currentStreak,
    required DateTime? lastCompletionDate,
    required bool weeklyStreakRewardClaimed,
  }) = _UserProgressModel;

  factory UserProgressModel.fromEntity(UserProgressTableData data) {
    return UserProgressModel(
      id: data.id,
      totalPoints: data.totalPoints,
      currentLevel: data.currentLevel,
      currentStreak: data.currentStreak,
      lastCompletionDate: data.lastCompletionDate,
      weeklyStreakRewardClaimed: data.weeklyStreakRewardClaimed,
    );
  }

  double get progressPercent {
    final currentLevelBase = _pointsForLevel(currentLevel);
    final nextLevelBase = _pointsForLevel(currentLevel + 1);
    final pointsInCurrentLevel = totalPoints - currentLevelBase;
    final totalPointsRequired = nextLevelBase - currentLevelBase;
    if (totalPointsRequired == 0) return 0.0;
    return (pointsInCurrentLevel / totalPointsRequired).clamp(0.0, 1.0);
  }

  int get nextLevelPoints => _pointsForLevel(currentLevel + 1);

  int get pointsToNextLevel => nextLevelPoints - totalPoints;

  static int _pointsForLevel(int n) {
    if (n <= 1) return 0;
    // Formula: (n-1)(50 + 25n)
    return (n - 1) * (50 + 25 * n);
  }
}
