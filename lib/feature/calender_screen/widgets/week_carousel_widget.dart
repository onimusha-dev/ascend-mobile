import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/settings_screen/settings_screen.dart';
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
  int _currentPageIndex = 1000; // Large number for infinite scroll

  @override
  void initState() {
    super.initState();
    _initialWeekStart = _getWeekStart(DateTime.now());
    _pageController = PageController(initialPage: _currentPageIndex);

    // Jump to current week if selected date is different
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
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. App Header: Title, Subtitle, Avatar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back!",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withAlpha(180),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings_outlined,
                      color: colorScheme.onSurfaceVariant.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // 3. Weekly Carousel
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
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withAlpha(120),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Task indicator dot
          if (isSelected || isToday)
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.primary.withAlpha(100),
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
