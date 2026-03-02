import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/calender_screen/provider/calendar_date_provider.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'package:fuck_your_todos/feature/notes/widgets/tasks_cards.dart';
import 'widgets/week_carousel_widget.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final bool _showCompleted =
      true; // Show by default as per "just show the tasks"
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
    final noteState = ref.watch(noteViewModelProvider);
    final allTasks = noteState.notes;

    // Filter tasks for the selected date
    final tasksForDate = allTasks.where((note) {
      final dateToMatch = (note.dueDate ?? note.createdAt).toLocal();
      return dateToMatch.year == _selectedDate.year &&
          dateToMatch.month == _selectedDate.month &&
          dateToMatch.day == _selectedDate.day;
    }).toList();

    final remainingTasks = tasksForDate.where((t) => !t.isCompleted).toList();
    final completedTasks = tasksForDate.where((t) => t.isCompleted).toList();

    // Sort tasks by time
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
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                controller: _scrollController,
                key: ValueKey(_selectedDate),
                padding: const EdgeInsets.only(bottom: 120, top: 24),
                itemCount: listItems.length,
                itemBuilder: (context, index) {
                  final item = listItems[index];

                  if (item == "COMPLETED_HEADER") {
                    return Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha(120),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "COMPLETED",
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${completedTasks.length}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            child: Divider(indent: 16, thickness: 0.5),
                          ),
                        ],
                      ),
                    );
                  }

                  final task = item;
                  return TasksCard(
                    id: task.id,
                    title: task.title,
                    description: task.description ?? '',
                    dueTime: task.dueDate ?? task.createdAt,
                    priority: task.priority,
                    tags: const [],
                    isCompleted: task.isCompleted,
                    taskType: task.taskType,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
