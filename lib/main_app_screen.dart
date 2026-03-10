import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/core/theme/theme_provider.dart';
import 'package:ascend/feature/calender_screen/provider/calendar_date_provider.dart';
import 'package:ascend/feature/calender_screen/calender_screen.dart';
import 'package:ascend/feature/tasks/widgets/create_note/create_note_view.dart';
import 'package:ascend/feature/profile_screen/analytics_screen.dart';
import 'package:ascend/feature/settings_screen/gamification_screen/gamification_screen.dart';
import 'package:ascend/feature/settings_screen/settings_screen.dart';
import 'package:ascend/view_model/gamification_provider.dart';
import 'package:ascend/view_model/user_progress_view_model.dart';

import 'package:ascend/feature/journal/journal_screen.dart';
import 'package:ascend/feature/habit_tracker/habit_tracker_screen.dart';
import 'package:ascend/feature/focus_mode/focus_mode_screen.dart';

class MainAppScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainAppScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen> {
  DateTime? currentBackPressTime;
  late int currentIndex;
  final List<Widget> pages = [
    const CalendarScreen(),
    const JournalScreen(),
    const HabitTrackerScreen(),
    const FocusModeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex % pages.length; // Ensure valid index
  }

  void _switchTab(int index) => setState(() => currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final doubleTapToExit = ref.watch(doubleTapToExitProvider);

    return PopScope(
      canPop: !doubleTapToExit,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        final now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Press back again to exit',
                textAlign: TextAlign.center,
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: currentIndex == 0
              ? null
              : Text(
                  _getPageTitle(currentIndex),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
          leading: currentIndex == 0
              ? Consumer(
                  builder: (context, ref, child) {
                    final isGamificationEnabled = ref.watch(
                      gamificationProvider,
                    );
                    if (!isGamificationEnabled) return const SizedBox();

                    final progressAsync = ref.watch(
                      userProgressViewModelProvider,
                    );
                    return progressAsync.when(
                      data: (progress) {
                        if (progress == null) return const SizedBox();
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const GamificationScreen(),
                              ),
                            );
                          },
                          child: Center(
                            child: Hero(
                              tag: 'app_bar_progress',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                margin: const EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cs.primary.withAlpha(51),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stars_rounded,
                                      color: cs.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${progress.currentLevel}',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: cs.onPrimaryContainer,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                    );
                  },
                )
              : null,
          leadingWidth: 80,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen(),
                  ),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: cs.primary,
                  size: 20,
                ),
              ),
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
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: cs.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final initialDate = currentIndex == 0
                    ? ref.read(selectedCalendarDateProvider)
                    : null;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  enableDrag: false,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return CreateNoteView(initialDate: initialDate);
                  },
                );
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              customBorder: const CircleBorder(),
              child: const Icon(
                Icons.add_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          padding: EdgeInsets.zero,
          notchMargin: 8,
          color: cs.surface.withAlpha(242), // 0.95 alpha approx
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                   _buildTabItem(
                    index: 0,
                    icon: CupertinoIcons.calendar,
                    activeIcon: CupertinoIcons.calendar_today,
                    label: 'Timeline',
                  ),
                  _buildTabItem(
                    index: 1,
                    icon: CupertinoIcons.book,
                    activeIcon: CupertinoIcons.book_fill,
                    label: 'Journal',
                  ),
                  const SizedBox(width: 70), // Center gap
                  _buildTabItem(
                    index: 2,
                    icon: CupertinoIcons.checkmark_seal,
                    activeIcon: CupertinoIcons.checkmark_seal_fill,
                    label: 'Habits',
                  ),
                  _buildTabItem(
                    index: 3,
                    icon: CupertinoIcons.timer,
                    activeIcon: CupertinoIcons.timer_fill,
                    label: 'Focus',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    return switch (index) {
      0 => 'Timeline',
      1 => 'Journal',
      2 => 'Habit Tracker',
      3 => 'Focus Mode',
      _ => '',
    };
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(150);

    return Expanded(
      child: InkWell(
        onTap: () => _switchTab(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween(begin: 0.8, end: isSelected ? 1.0 : 0.9),
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 10,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
