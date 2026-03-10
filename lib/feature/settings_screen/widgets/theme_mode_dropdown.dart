import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/core/theme/theme_provider.dart';

class ThemeModeDropdown extends ConsumerWidget {
  final ThemeMode themeMode;
  final ColorScheme cs;

  const ThemeModeDropdown({
    super.key,
    required this.themeMode,
    required this.cs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<ThemeMode>(
      initialValue: themeMode,
      onSelected: (mode) => ref.read(themeProvider.notifier).setThemeMode(mode),
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surface,
      itemBuilder: (context) => [
        _buildItem(context, ThemeMode.system, 'System'),
        _buildItem(context, ThemeMode.light, 'Light'),
        _buildItem(context, ThemeMode.dark, 'Dark'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cs.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(themeMode),
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: cs.primary),
          ],
        ),
      ),
    );
  }

  String _label(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
    }
  }

  PopupMenuItem<ThemeMode> _buildItem(
    BuildContext context,
    ThemeMode value,
    String label,
  ) {
    final isSelected = themeMode == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
              color: isSelected ? cs.primary : cs.onSurface,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
        ],
      ),
    );
  }
}
