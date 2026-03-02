import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/theme/theme_provider.dart';
import 'package:fuck_your_todos/core/theme/app_themes.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeMode = themeState.themeMode;
    final currentPreset = themeState.preset;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appearance',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.primary,
            size: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, "Color Schemes"),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: AppThemes.presets.map((preset) {
                    final isSelected = currentPreset.name == preset.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _ThemePreviewCard(
                        preset: preset,
                        isSelected: isSelected,
                        pureDark: themeState.pureDark,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Theme Settings"),
              const SizedBox(height: 12),
              _AppearanceSettingTile(
                title: 'Theme Mode',
                subtitle: _themeModeLabel(themeMode),
                icon: Icons.brightness_6_rounded,
                color: Colors.amber,
                trailing: _ThemeModeDropdown(themeMode: themeMode, cs: cs),
              ),
              const SizedBox(height: 12),
              _AppearanceSettingTile(
                title: 'Pure Dark',
                subtitle: 'Deep black for AMOLED screens',
                icon: Icons.dark_mode_rounded,
                color: Colors.indigo,
                trailing: Switch(
                  value: themeState.pureDark,
                  activeThumbColor: cs.primary,
                  onChanged: themeMode == ThemeMode.light
                      ? null
                      : (_) =>
                            ref.read(themeProvider.notifier).togglePureDark(),
                ),
              ),
              const SizedBox(height: 12),
              _AppearanceSettingTile(
                title: 'Language',
                subtitle: 'System default',
                icon: Icons.translate_rounded,
                color: Colors.teal,
                onTap: () =>
                    AppSettings.openAppSettings(type: AppSettingsType.settings),
              ),
              const SizedBox(height: 12),
              _AppearanceSettingTile(
                title: 'Double Tap to Exit',
                subtitle: 'Safety back press',
                icon: Icons.exit_to_app_rounded,
                color: Colors.redAccent,
                trailing: Switch(
                  value: ref.watch(doubleTapToExitProvider),
                  activeThumbColor: cs.primary,
                  onChanged: (_) =>
                      ref.read(doubleTapToExitProvider.notifier).toggle(),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
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

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
    }
  }
}

class _AppearanceSettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _AppearanceSettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withAlpha(80),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
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
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant.withAlpha(150),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
              if (onTap != null && trailing == null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant.withAlpha(100),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeDropdown extends ConsumerWidget {
  final ThemeMode themeMode;
  final ColorScheme cs;

  const _ThemeModeDropdown({required this.themeMode, required this.cs});

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

class _ThemePreviewCard extends ConsumerWidget {
  final AppThemePreset preset;
  final bool isSelected;
  final bool pureDark;

  const _ThemePreviewCard({
    required this.preset,
    required this.isSelected,
    required this.pureDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewCs = ColorScheme.fromSeed(
      seedColor: preset.seedColor,
      brightness: Theme.of(context).brightness,
    );

    final cardBg = isDark && pureDark ? Colors.black : previewCs.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => ref.read(themeProvider.notifier).setPreset(preset),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 180,
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? previewCs.primary
                    : previewCs.outlineVariant.withAlpha(100),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: previewCs.primary.withAlpha(40),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: _PreviewContent(previewCs: previewCs),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            preset.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected
                  ? previewCs.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewContent extends StatelessWidget {
  final ColorScheme previewCs;
  const _PreviewContent({required this.previewCs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 12,
              width: 45,
              decoration: BoxDecoration(
                color: previewCs.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: previewCs.secondaryContainer,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _fakeTask(previewCs, 0.8),
        const SizedBox(height: 10),
        _fakeTask(previewCs, 0.5),
        const SizedBox(height: 10),
        _fakeTask(previewCs, 0.7, done: true),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: previewCs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 14,
              color: previewCs.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fakeTask(ColorScheme cs, double width, {bool done = false}) {
    return Row(
      children: [
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: done
              ? Icon(Icons.check_rounded, size: 10, color: cs.primary)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: width,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: done ? cs.outline : cs.onSurface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              FractionallySizedBox(
                widthFactor: 0.4,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
