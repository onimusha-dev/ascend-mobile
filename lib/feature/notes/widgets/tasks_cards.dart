import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/tables/note_table.dart';
import 'package:fuck_your_todos/feature/notes/view_models/task_category_view_model.dart';
import 'package:fuck_your_todos/feature/notes/widgets/task_edit_options.dart';
import 'package:intl/intl.dart';

class TasksCard extends ConsumerStatefulWidget {
  const TasksCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.dueTime,
    required this.priority,
    required this.tags,
    required this.isCompleted,
    this.taskType,
  });

  final int id;
  final String title;
  final String description;
  final DateTime dueTime;
  final bool isCompleted;
  final Priority priority;
  final List<String> tags;
  final String? taskType;

  @override
  ConsumerState<TasksCard> createState() => _TasksCardState();
}

class _TasksCardState extends ConsumerState<TasksCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(taskCategoryViewModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Left Border Color based on Priority
    final priorityColor = widget.isCompleted
        ? colorScheme.outlineVariant
        : switch (widget.priority) {
            Priority.high => colorScheme.error,
            Priority.medium => colorScheme.tertiary,
            Priority.low => colorScheme.primary,
            Priority.none => colorScheme.outlineVariant, // Gray for none
          };

    final textColor = widget.isCompleted
        ? theme.hintColor
        : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: () =>
            showTaskOptions(context, ref, widget.id, widget.isCompleted),
        onTap: _toggleExpand,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.isCompleted
                ? colorScheme.surfaceContainerHighest.withAlpha(40)
                : colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(24),
            border: Border(
              left: BorderSide(
                color: priorityColor.withAlpha(widget.isCompleted ? 100 : 255),
                width: 6,
              ),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title and Check Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'task_title_${widget.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              fontSize: 17,
                              decoration: widget.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.isCompleted)
                      Icon(
                        Icons.check_circle_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Meta Row: Category tag and Time (visible when collapsed or expanded)
                Row(
                  children: [
                    // Category Tags (Multiple)
                    categoriesState.maybeWhen(
                      data: (cats) {
                        if (widget.taskType == null ||
                            widget.taskType!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final selectedIds = widget.taskType!
                            .split(',')
                            .map((s) => int.tryParse(s.trim()))
                            .whereType<int>()
                            .toList();

                        final matches = cats
                            .where((c) => selectedIds.contains(c.id))
                            .take(3)
                            .toList();

                        if (matches.isEmpty) return const SizedBox.shrink();

                        return Wrap(
                          spacing: 4,
                          children: matches
                              .map(
                                (match) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest
                                        .withAlpha(150),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: colorScheme.outline.withAlpha(50),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${match.icon} ",
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      Text(
                                        match.name,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withAlpha(150),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                    const Spacer(),
                    // Time - appealing style
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 14,
                      color: textColor.withAlpha(100),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('h:mm a').format(widget.dueTime),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor.withAlpha(150),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Expanded Section: Description
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Removed the "bar roler" (Divider) as requested
                        Text(
                          widget.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor.withAlpha(180),
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Priority Label explicitly inside expanded view
                      if (widget.priority != Priority.none)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor: priorityColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.priority.name.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: priorityColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
