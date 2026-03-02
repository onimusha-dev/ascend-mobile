import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/core/utils/date_formatter.dart';
import 'package:ascend/feature/home_screen/widgets/no_task_placeholder.dart';
import 'package:ascend/feature/home_screen/widgets/no_task_remaining_widget.dart';
import 'package:ascend/feature/home_screen/widgets/today_overview_card.dart';
import 'package:ascend/feature/tasks/view_models/note_view_model.dart';
import 'package:ascend/feature/tasks/widgets/tasks_cards.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(noteViewModelProvider);

    final todayTasks = tasksState.notes
        .where((t) => isToday(t.dueDate ?? t.createdAt) && !t.isCompleted)
        .toList();

    todayTasks.sort(
      (a, b) => (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt),
    );

    final todayCompletedTasks = tasksState.notes
        .where((t) => isToday(t.dueDate ?? t.createdAt) && t.isCompleted)
        .toList();

    // TODO: Sort completion history more efficiently or move to the view model
    todayCompletedTasks.sort(
      (a, b) => (b.dueDate ?? b.createdAt).compareTo(a.dueDate ?? a.createdAt),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasCompleted = todayCompletedTasks.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───────────────── Today header ─────────────────
          _buildOverview(todayTasks, todayCompletedTasks),

          const SizedBox(height: 24),

          // ───────────────── Today tasks / Placeholder ─────────────────
          if (todayTasks.isEmpty && !hasCompleted)
            const NoTaskPlaceholder()
          else if (todayTasks.isEmpty)
            const NoTaskRemainingWidget()
          else
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 16,
              runSpacing: 16,
              children: todayTasks
                  .map(
                    (task) => TasksCard(
                      id: task.id,
                      title: task.title,
                      description: task.description ?? '',
                      dueTime: task.dueDate ?? task.createdAt,
                      priority: task.priority,
                      difficulty: task.difficulty,
                      isCompleted: task.isCompleted,
                      taskType: task.taskType,
                    ),
                  )
                  .toList(),
            ),

          // ───────────────── Completed header ─────────────────
          if (hasCompleted) ...[
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: Text(
                "Completed",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 16,
              runSpacing: 16,
              children: todayCompletedTasks
                  .map(
                    (task) => TasksCard(
                      id: task.id,
                      title: task.title,
                      description: task.description ?? '',
                      dueTime: task.dueDate ?? task.createdAt,
                      priority: task.priority,
                      difficulty: task.difficulty,
                      isCompleted: task.isCompleted,
                      taskType: task.taskType,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverview(
    List<dynamic> todayTasks,
    List<dynamic> todayCompletedTasks,
  ) {
    final totalTodayTasks = todayTasks.length + todayCompletedTasks.length;
    final progress = totalTodayTasks == 0
        ? 0.0
        : todayCompletedTasks.length / totalTodayTasks;

    return TodayOverviewCard(
      totalTasks: totalTodayTasks,
      completedTasks: todayCompletedTasks.length,
      pendingTasks: todayTasks.length,
      progress: progress,
    );
  }
}
