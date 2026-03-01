import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/tables/note_table.dart';
import 'package:fuck_your_todos/feature/notes/view_models/task_category_view_model.dart';
import 'package:fuck_your_todos/feature/notes/widgets/task_edit_options.dart';
import 'package:intl/intl.dart';

class Shownotes extends ConsumerStatefulWidget {
  const Shownotes({
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
  final int? taskType;

  @override
  ConsumerState<Shownotes> createState() => _ShownotesState();
}

class _ShownotesState extends ConsumerState<Shownotes>
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

    // Use theme-based colors
    Color cardColor;
    Color tagColor;
    Color textColor = widget.isCompleted
        ? theme.hintColor
        : colorScheme.onSurface;

    final colorMapping = {
      Priority.high: colorScheme.errorContainer.withValues(alpha: 0.7),
      Priority.medium: colorScheme.tertiaryContainer.withValues(alpha: 0.7),
      Priority.low: colorScheme.primaryContainer.withValues(alpha: 0.7),
      Priority.none: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
    };

    final tagColorMapping = {
      Priority.high: colorScheme.errorContainer,
      Priority.medium: colorScheme.tertiaryContainer,
      Priority.low: colorScheme.primaryContainer,
      Priority.none: colorScheme.surfaceContainerHighest,
    };

    cardColor =
        colorMapping[widget.priority] ?? colorScheme.surfaceContainerHighest;
    tagColor =
        tagColorMapping[widget.priority] ?? colorScheme.secondaryContainer;

    if (widget.isCompleted) {
      cardColor = colorScheme.surfaceContainerLow;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// NOTE: left side timeline
          SizedBox(
            width: 64,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Continuous Line
                Positioned.fill(
                  child: CustomPaint(
                    painter: DottedLinePainter(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                // Time label
                Positioned(
                  top: 12,
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 4,
                    ),
                    child: Text(
                      DateFormat('H:mm').format(widget.dueTime),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.hintColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// NOTE: right side task card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 12, top: 12),
              child: GestureDetector(
                onLongPress: () => showTaskOptions(
                  context,
                  ref,
                  widget.id,
                  widget.isCompleted,
                ),
                onTap: _toggleExpand,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      categoriesState.maybeWhen(
                        data: (cats) {
                          final match =
                              cats
                                  .where((c) => c.id == widget.taskType)
                                  .firstOrNull ??
                              cats.firstOrNull;
                          if (match == null) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              match.name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),

                      // expanded view
                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.description.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(height: 1, thickness: 0.5),
                              ),
                              Text(
                                widget.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textColor.withValues(alpha: 0.8),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('h:mm a').format(widget.dueTime),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: textColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.priority_high_rounded,
                                    size: 14,
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.priority.name.toUpperCase(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: textColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// it is used to draw the dotted line in the timeline
/// [color] is the color of the dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double dashHeight = 5, dashSpace = 3, startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// it is used to draw the footer of the timeline
/// [time] is the time of the footer
class TimelineFooter extends StatelessWidget {
  final DateTime time;
  const TimelineFooter({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: DottedLinePainter(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 4,
                    ),
                    child: Text(
                      DateFormat('H:mm').format(time),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
