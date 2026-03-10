import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/feature/tasks/view_models/note_view_model.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(noteViewModelProvider);
    final allTasks = tasksState.notes;

    final totalTasks = allTasks.length;
    final totalCompleted = allTasks.where((t) => t.isCompleted).length;
    final totalPending = totalTasks - totalCompleted;

    final completionRate = totalTasks > 0
        ? (totalCompleted / totalTasks * 100).round()
        : 0;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final now = DateTime.now();
    final List<_DailyStat> last7Days = List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      final tasksForDay = allTasks.where((t) {
        final targetDate = t.dueDate ?? t.createdAt;
        return _isSameDay(targetDate, day);
      }).toList();

      final completed = tasksForDay.where((t) => t.isCompleted).length;
      return _DailyStat(
        date: day,
        total: tasksForDay.length,
        completed: completed,
      );
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, "Overview"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Total Tasks",
                  value: "$totalTasks",
                  icon: Icons.list_alt_rounded,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Completed",
                  value: "$totalCompleted",
                  icon: Icons.check_circle_rounded,
                  color: cs.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Pending",
                  value: "$totalPending",
                  icon: Icons.pending_actions_rounded,
                  color: cs.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Success Rate",
                  value: "$completionRate%",
                  icon: Icons.trending_up_rounded,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle(context, "Activity"),
          const SizedBox(height: 16),
          Container(
            height: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withAlpha(60),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Last 7 Days",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(last7Days),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => cs.surfaceContainerHighest,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final stat = last7Days[groupIndex];
                            return BarTooltipItem(
                              rodIndex == 0
                                  ? 'Created: ${stat.total}'
                                  : 'Done: ${stat.completed}',
                              TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              if (val.toInt() < 0 ||
                                  val.toInt() >= last7Days.length) {
                                return const SizedBox.shrink();
                              }
                              final date = last7Days[val.toInt()].date;
                              final isToday = _isSameDay(date, DateTime.now());
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  isToday
                                      ? 'Today'
                                      : DateFormat('EEE').format(date),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isToday ? cs.primary : cs.outline,
                                    fontWeight: isToday
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: cs.outlineVariant.withAlpha(50),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(last7Days.length, (index) {
                        final stat = last7Days[index];
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: stat.total.toDouble(),
                              color: cs.primary.withAlpha(40),
                              width: 10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            BarChartRodData(
                              toY: stat.completed.toDouble(),
                              color: cs.primary,
                              width: 10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendIndicator(
                      color: cs.primary.withAlpha(40),
                      label: "Created",
                    ),
                    const SizedBox(width: 16),
                    _LegendIndicator(color: cs.primary, label: "Completed"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  double _getMaxY(List<_DailyStat> stats) {
    if (stats.isEmpty) return 4;
    final maxTotal = stats.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    return maxTotal < 4 ? 4 : (maxTotal * 1.2).toDouble();
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.outline,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _DailyStat {
  final DateTime date;
  final int total;
  final int completed;

  _DailyStat({
    required this.date,
    required this.total,
    required this.completed,
  });
}

class _LegendIndicator extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendIndicator({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant.withAlpha(150),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
