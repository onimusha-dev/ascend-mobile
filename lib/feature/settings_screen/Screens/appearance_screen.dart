// import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/core/theme/theme_provider.dart';
import 'package:ascend/core/theme/app_themes.dart';
import 'package:ascend/feature/settings_screen/widgets/theme_preview_card.dart';
import 'package:ascend/feature/settings_screen/widgets/common_setting_tile.dart';
import 'package:ascend/feature/settings_screen/widgets/theme_mode_dropdown.dart';

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
                  children: (() {
                    final dynamicTheme = AppThemes.presets.firstWhere(
                      (p) => p.name == 'Dynamic',
                      orElse: () => AppThemes.dynamic,
                    );
                    final sortedPresets = [
                      currentPreset,
                      if (currentPreset.name != 'Dynamic') dynamicTheme,
                      ...AppThemes.presets.where(
                        (p) =>
                            p.name != currentPreset.name && p.name != 'Dynamic',
                      ),
                    ];
                    return sortedPresets.map((preset) {
                      final isSelected = currentPreset.name == preset.name;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        // TODO: Optimize scrolling performance when we add more themes
                        child: ThemePreviewCard(
                          preset: preset,
                          isSelected: isSelected,
                          pureDark: themeState.pureDark,
                        ),
                      );
                    }).toList();
                  })(),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Theme Settings"),
              const SizedBox(height: 12),
              // TODO: Fix UI glitch when changing themes too fast
              CommonSettingTile(
                title: 'Theme Mode',
                subtitle: _themeModeLabel(themeMode),
                icon: Icons.brightness_6_rounded,
                color: Colors.amber,
                trailing: ThemeModeDropdown(themeMode: themeMode, cs: cs),
              ),
              const SizedBox(height: 12),
              CommonSettingTile(
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

              /// NOTE: Language is not implemented yet.
              // const SizedBox(height: 12),
              // CommonSettingTile(
              //   title: 'Language',
              //   subtitle: 'System default',
              //   icon: Icons.translate_rounded,
              //   color: Colors.teal,
              //   onTap: () =>
              //       AppSettings.openAppSettings(type: AppSettingsType.settings),
              // ),
              const SizedBox(height: 12),
              CommonSettingTile(
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
