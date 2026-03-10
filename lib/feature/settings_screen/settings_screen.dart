import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/core/constants/constants.dart';
import 'package:ascend/feature/settings_screen/Screens/account_screen.dart';
import 'package:ascend/feature/settings_screen/Screens/appearance_screen.dart';
// import 'package:ascend/feature/settings_screen/Screens/inbox_screen/inbox_screen.dart';
import 'package:ascend/feature/settings_screen/Screens/notification_screen.dart';
import 'package:ascend/feature/settings_screen/Screens/data_and_privacy_screen/data_and_privacy_screen.dart';
import 'package:ascend/feature/settings_screen/Screens/categories_screen/categories_screen.dart';
import 'package:ascend/feature/settings_screen/Screens/about_screen.dart';
import 'package:ascend/feature/settings_screen/gamification_screen/gamification_screen.dart';
import 'package:ascend/feature/settings_screen/widgets/common_setting_tile.dart';

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
              CommonSettingTile(
                title: 'Appearance',
                subtitle: 'Theme, Language, Fonts',
                icon: Icons.palette_rounded,
                color: const Color(0xFF6366F1), // Indigo
                iconSize: 24,
                iconPadding: 12,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppearanceScreen()),
                ),
              ),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Notifications',
                subtitle: 'Reminders and alerts',
                icon: Icons.notifications_rounded,
                color: const Color(0xFFF43F5E), // Rose
                iconSize: 24,
                iconPadding: 12,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                ),
              ),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Categories',
                subtitle: 'Manage task tags & icons',
                icon: Icons.category_rounded,
                color: const Color(0xFFF59E0B), // Amber
                iconSize: 24,
                iconPadding: 12,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
              ),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Gamification',
                subtitle: 'Points, levels, and streaks',
                icon: Icons.sports_esports_rounded,
                color: const Color(0xFF10B981), // Emerald/Green
                iconSize: 24,
                iconPadding: 12,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GamificationScreen()),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Security & Data"),

              /// NOTE: Account screen is not implemented yet.
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Account',
                subtitle: 'Cloud sync, Premium features',
                icon: Icons.account_circle_rounded,
                color: Colors.purple,
                iconSize: 24,
                iconPadding: 12,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                ),
              ),

              /// NOTE: Inbox screen is not implemented yet.
              // const SizedBox(height: 12),
              // CommonSettingTile(
              //   title: 'Inbox',
              //   subtitle: 'Empty inbox',
              //   icon: Icons.mail_rounded,
              //   color: cs.primary,
              //   iconSize: 24,
              //   iconPadding: 12,
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (_) => const InboxScreen()),
              //   ),
              // ),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Data & Privacy',
                subtitle: 'Backup, Restore, Passcode',
                icon: Icons.security_rounded,
                color: const Color(0xFF3B82F6), // Blue
                iconSize: 24,
                iconPadding: 12,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DataAndPrivacyScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle(context, "Support"),

              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'About',
                subtitle: 'Version ${AppConstants.appVersion}',
                icon: Icons.info_rounded,
                color: const Color(0xFF64748B), // Slate
                iconSize: 24,
                iconPadding: 12,
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
}

/// Builds a section title for the settings screen.
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
