import 'dart:math' as math;
import 'package:drift/drift.dart';
import 'package:ascend/data/db/app_database.dart';
import 'package:ascend/data/db/tables/note_table.dart';
import 'package:ascend/domain/models/user_progress_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_progress_view_model.g.dart';

@riverpod
class UserProgressViewModel extends _$UserProgressViewModel {
  @override
  Future<UserProgressModel?> build() async {
    final dao = ref.watch(appDatabaseProviderProvider).userProgressDao;
    var progress = await dao.getProgress();

    if (progress == null) {
      // Initialize with default values if not exists
      final newProgress = UserProgressTableCompanion.insert(
        totalPoints: const Value(0),
        currentLevel: const Value(1),
        currentStreak: const Value(0),
        weeklyStreakRewardClaimed: const Value(false),
      );
      await dao.insertProgress(newProgress);
      progress = await dao.getProgress();
    }

    return progress != null ? UserProgressModel.fromEntity(progress) : null;
  }

  Future<void> awardPoints(TaskDifficulty difficulty) async {
    final currentProgress = state.value;
    if (currentProgress == null) return;

    int pointsToAdd = 0;
    switch (difficulty) {
      case TaskDifficulty.easy:
        pointsToAdd = 5;
        break;
      case TaskDifficulty.medium:
        pointsToAdd = 10;
        break;
      case TaskDifficulty.hard:
        pointsToAdd = 15;
        break;
    }

    // Streak logic
    int newStreak = currentProgress.currentStreak;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? lastCompletion;
    if (currentProgress.lastCompletionDate != null) {
      lastCompletion = DateTime(
        currentProgress.lastCompletionDate!.year,
        currentProgress.lastCompletionDate!.month,
        currentProgress.lastCompletionDate!.day,
      );
    }

    if (lastCompletion == null) {
      newStreak = 1;
    } else {
      final difference = today.difference(lastCompletion).inDays;
      if (difference == 1) {
        // Consecutive day
        newStreak++;
      } else if (difference > 1) {
        // Streak broken
        newStreak = 1;
      }
      // if difference == 0, already completed a task today, streak remains same
    }

    int streakPoints = 0;
    bool weeklyClaimed = currentProgress.weeklyStreakRewardClaimed;
    if (newStreak % 7 == 0 && newStreak != 0) {
      if (lastCompletion == null || today.isAfter(lastCompletion)) {
        if (lastCompletion != null && today.isAfter(lastCompletion)) {
          weeklyClaimed = false;
        }

        if (!weeklyClaimed) {
          streakPoints = 50;
          weeklyClaimed = true;
        }
      }
    } else {
      weeklyClaimed = false;
    }

    final finalPoints =
        currentProgress.totalPoints + pointsToAdd + streakPoints;
    final newLevel = _calculateLevel(finalPoints);

    final updatedCompanion = UserProgressTableCompanion(
      totalPoints: Value(finalPoints),
      currentLevel: Value(newLevel),
      currentStreak: Value(newStreak),
      lastCompletionDate: Value(today),
      weeklyStreakRewardClaimed: Value(weeklyClaimed),
      updatedAt: Value(DateTime.now()),
    );

    await ref
        .read(appDatabaseProviderProvider)
        .userProgressDao
        .updateProgress(updatedCompanion);
    ref.invalidateSelf();
  }

  int _calculateLevel(int points) {
    // Formula: (n-1)(50 + 25n) = P
    // n = -0.5 + 0.2 * math.sqrt(56.25 + points)
    return (-0.5 + 0.2 * math.sqrt(56.25 + points)).floor().toInt();
  }
}
