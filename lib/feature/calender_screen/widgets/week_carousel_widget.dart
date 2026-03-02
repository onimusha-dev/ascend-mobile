import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WeekCarouselWidget extends ConsumerStatefulWidget {
  const WeekCarouselWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  ConsumerState<WeekCarouselWidget> createState() => _WeekCarouselWidgetState();
}

class _WeekCarouselWidgetState extends ConsumerState<WeekCarouselWidget> {
  late PageController _pageController;
  late DateTime _initialWeekStart;
  int _currentPageIndex = 1000;

  @override
  void initState() {
    super.initState();
    _initialWeekStart = _getWeekStart(DateTime.now());
    _pageController = PageController(initialPage: _currentPageIndex);
    _updatePageToDate(widget.selectedDate);
  }

  void _updatePageToDate(DateTime date) {
    final targetWeekStart = _getWeekStart(date);
    final weekDiff = targetWeekStart.difference(_initialWeekStart).inDays ~/ 7;
    _currentPageIndex = 1000 + weekDiff;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_currentPageIndex);
    }
  }

  @override
  void didUpdateWidget(covariant WeekCarouselWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      final oldWeekStart = _getWeekStart(oldWidget.selectedDate);
      final newWeekStart = _getWeekStart(widget.selectedDate);
      if (!_isSameDay(oldWeekStart, newWeekStart)) {
        _updatePageToDate(widget.selectedDate);
      }
    }
  }

  DateTime _getWeekStart(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday % 7));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) =>
                  setState(() => _currentPageIndex = index),
              itemBuilder: (context, pageIndex) {
                final weekStart = _initialWeekStart.add(
                  Duration(days: (pageIndex - 1000) * 7),
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (i) {
                    final date = weekStart.add(Duration(days: i));
                    final isSelected = _isSameDay(date, widget.selectedDate);
                    final isToday = _isSameDay(date, DateTime.now());

                    return _DayItem(
                      date: date,
                      isSelected: isSelected,
                      isToday: isToday,
                      onTap: () => widget.onDateSelected(date),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayItem({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dayLabel = DateFormat('E').format(date).toUpperCase()[0];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withAlpha(120),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : (isToday
                        ? colorScheme.primary.withAlpha(20)
                        : Colors.transparent),
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(
                      color: colorScheme.primary.withAlpha(100),
                      width: 1,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (isSelected)
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
