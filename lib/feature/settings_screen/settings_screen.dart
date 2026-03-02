import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/constants/constants.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/account_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/appearance_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/data_and_privacy_screen/data_and_privacy_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/categories_screen/categories_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/about_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
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
              _buildSectionTitle(context, "Preference"),
              const SizedBox(height: 12),
              _SettingsTile(
                title: 'Appearance',
                subtitle: 'Theme, Language, Fonts',
                icon: Icons.palette_rounded,
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppearanceScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                title: 'Categories',
                subtitle: 'Manage task tags & icons',
                icon: Icons.category_rounded,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle(context, "Security & Data"),
              const SizedBox(height: 12),
              _SettingsTile(
                title: 'Data & Privacy',
                subtitle: 'Backup, Restore, Passcode',
                icon: Icons.shield_rounded,
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DataAndPrivacyScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                title: 'Account',
                subtitle: 'Cloud sync, Premium features',
                icon: Icons.account_circle_rounded,
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle(context, "Support"),
              const SizedBox(height: 12),
              _SettingsTile(
                title: 'About',
                subtitle: 'Version ${AppConstants.appVersion}',
                icon: Icons.info_rounded,
                color: cs.outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
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
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
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
                      ),
                    ),
                    const SizedBox(height: 2),
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
