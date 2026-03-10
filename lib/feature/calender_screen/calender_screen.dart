import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/feature/calender_screen/provider/calendar_date_provider.dart';
import 'package:ascend/feature/tasks/view_models/note_view_model.dart';
import 'package:ascend/feature/tasks/widgets/tasks_cards.dart';
import 'widgets/week_carousel_widget.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final bool _showCompleted = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedCalendarDateProvider.notifier).setDate(_selectedDate);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final noteState = ref.watch(noteViewModelProvider);
    final allTasks = noteState.notes;

    final tasksForDate = allTasks.where((note) {
      final dateToMatch = (note.dueDate ?? note.createdAt).toLocal();
      return dateToMatch.year == _selectedDate.year &&
          dateToMatch.month == _selectedDate.month &&
          dateToMatch.day == _selectedDate.day;
    }).toList();

    final remainingTasks = tasksForDate.where((t) => !t.isCompleted).toList();
    final completedTasks = tasksForDate.where((t) => t.isCompleted).toList();

    remainingTasks.sort(
      (a, b) => (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt),
    );
    completedTasks.sort(
      (a, b) => (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt),
    );

    final List<dynamic> listItems = [...remainingTasks];
    if (completedTasks.isNotEmpty && _showCompleted) {
      listItems.add("COMPLETED_HEADER");
      listItems.addAll(completedTasks);
    }

    return Column(
      children: [
        WeekCarouselWidget(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() => _selectedDate = date);
            ref.read(selectedCalendarDateProvider.notifier).setDate(date);
          },
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: listItems.isEmpty
                ? _buildEmptyState(context)
                : SingleChildScrollView(
                    key: ValueKey(_selectedDate),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Remaining Tasks
                        Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 16,
                          runSpacing: 16,
                          children: remainingTasks
                              .map(
                                (item) => TasksCard(
                                  id: item.id,
                                  title: item.title,
                                  description: item.description ?? '',
                                  dueTime: item.dueDate ?? item.createdAt,
                                  priority: item.priority,
                                  difficulty: item.difficulty,
                                  isCompleted: item.isCompleted,
                                  taskType: item.taskType,
                                ),
                              )
                              .toList(),
                        ),

                        if (completedTasks.isNotEmpty && _showCompleted) ...[
                          _buildCompletedHeader(
                            cs,
                            theme,
                            completedTasks.length,
                          ),
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 16,
                            runSpacing: 16,
                            children: completedTasks
                                .map(
                                  (item) => TasksCard(
                                    id: item.id,
                                    title: item.title,
                                    description: item.description ?? '',
                                    dueTime: item.dueDate ?? item.createdAt,
                                    priority: item.priority,
                                    difficulty: item.difficulty,
                                    isCompleted: item.isCompleted,
                                    taskType: item.taskType,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedHeader(ColorScheme cs, ThemeData theme, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: cs.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary.withAlpha(30)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 10),
                Text(
                  "COMPLETED TASKS",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 10),
                Text("•", style: TextStyle(color: cs.primary.withAlpha(100))),
                const SizedBox(width: 10),
                Text(
                  "$count",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: Divider(indent: 12, endIndent: 4)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_rounded,
              size: 64,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Clear for today!",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            "Enjoy your free time or add a new task",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}
