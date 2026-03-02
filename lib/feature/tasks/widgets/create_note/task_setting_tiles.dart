import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/data/db/tables/note_table.dart';
import 'package:ascend/feature/tasks/view_models/task_category_view_model.dart';
import 'package:ascend/core/utils/icon_utils.dart';

class TaskSettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const TaskSettingTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant.withAlpha(150),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  color: cs.onSurfaceVariant.withAlpha(100),
                  size: 20,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withAlpha(100),
              ),
          ],
        ),
      ),
    );
  }
}

class PrioritySettingTile extends StatelessWidget {
  final Priority priority;
  final Function(Priority) onSelect;
  final ColorScheme cs;
  final ThemeData theme;
  final IconData Function(Priority) priorityIcon;
  final String Function(Priority) priorityLabel;
  final Color Function(Priority, ColorScheme) priorityColor;

  const PrioritySettingTile({
    super.key,
    required this.priority,
    required this.onSelect,
    required this.cs,
    required this.theme,
    required this.priorityIcon,
    required this.priorityLabel,
    required this.priorityColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = priority == Priority.none
        ? cs.outline
        : priorityColor(priority, cs);

    return PopupMenuButton<Priority>(
      onSelected: onSelect,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      itemBuilder: (context) =>
          [Priority.high, Priority.medium, Priority.low, Priority.none]
              .map(
                (p) => PopupMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      Icon(
                        priorityIcon(p),
                        color: priorityColor(p, cs),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        priorityLabel(p),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(priorityIcon(priority), color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Priority",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant.withAlpha(150),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    priorityLabel(priority),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.unfold_more_rounded,
              color: cs.onSurfaceVariant.withAlpha(100),
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultySettingTile extends StatelessWidget {
  final TaskDifficulty difficulty;
  final Function(TaskDifficulty) onSelect;
  final ColorScheme cs;
  final ThemeData theme;

  const DifficultySettingTile({
    super.key,
    required this.difficulty,
    required this.onSelect,
    required this.cs,
    required this.theme,
  });

  IconData _difficultyIcon(TaskDifficulty d) {
    return switch (d) {
      TaskDifficulty.hard => Icons.bolt_rounded,
      TaskDifficulty.medium => Icons.electric_bolt_rounded,
      TaskDifficulty.easy => Icons.flash_on_rounded,
    };
  }

  String _difficultyLabel(TaskDifficulty d) {
    return switch (d) {
      TaskDifficulty.hard => 'Hard (15 pts)',
      TaskDifficulty.medium => 'Medium (10 pts)',
      TaskDifficulty.easy => 'Easy (5 pts)',
    };
  }

  Color _difficultyColor(TaskDifficulty d) {
    return switch (d) {
      TaskDifficulty.hard => cs.error,
      TaskDifficulty.medium => cs.tertiary,
      TaskDifficulty.easy => cs.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _difficultyColor(difficulty);

    return PopupMenuButton<TaskDifficulty>(
      onSelected: onSelect,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      itemBuilder: (context) =>
          [TaskDifficulty.hard, TaskDifficulty.medium, TaskDifficulty.easy]
              .map(
                (d) => PopupMenuItem(
                  value: d,
                  child: Row(
                    children: [
                      Icon(
                        _difficultyIcon(d),
                        color: _difficultyColor(d),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _difficultyLabel(d),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(_difficultyIcon(difficulty), color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Difficulty",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant.withAlpha(150),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _difficultyLabel(difficulty),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.unfold_more_rounded,
              color: cs.onSurfaceVariant.withAlpha(100),
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySettingTile extends ConsumerWidget {
  final List<int> selectedIds;
  final VoidCallback onTap;
  final Function(int) onRemove;
  final ColorScheme cs;
  final ThemeData theme;

  const CategorySettingTile({
    super.key,
    required this.selectedIds,
    required this.onTap,
    required this.onRemove,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(taskCategoryViewModelProvider);

    return categoriesState.maybeWhen(
      data: (categories) {
        final selectedCats = categories
            .where((c) => selectedIds.contains(c.id))
            .toList();

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (selectedIds.isNotEmpty ? cs.primary : cs.outline)
                        .withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.dashboard_customize_rounded,
                    color: selectedIds.isNotEmpty ? cs.primary : cs.outline,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Categories",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withAlpha(150),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (selectedCats.isEmpty)
                        Text(
                          "Add category",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: selectedCats
                                .map(
                                  (c) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: cs.primary.withAlpha(40),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconUtils.buildCategoryIcon(
                                          c.icon,
                                          size: 14,
                                          color: cs.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          c.name,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: cs.primary,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () => onRemove(c.id),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 14,
                                            color: cs.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                if (selectedIds.length < 3)
                  Icon(
                    Icons.add_rounded,
                    color: cs.onSurfaceVariant.withAlpha(100),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withAlpha(100),
                  ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
