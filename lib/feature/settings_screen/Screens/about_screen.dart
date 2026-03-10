import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ascend/core/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ascend/feature/settings_screen/widgets/common_setting_tile.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "App Info"),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'Version',
                        subtitle:
                            '${AppConstants.appVersion}  (${AppConstants.versionName})',
                        icon: Icons.info_rounded,
                        color: Colors.blue,
                        onTap: _checkUpdates,
                      ),

                      /// NOTE: Beta channel is not implemented yet.
                      // const SizedBox(height: 12),
                      // CommonSettingTile(
                      //   title: 'Beta Channel',
                      //   subtitle: 'Receive early features & bugs',
                      //   icon: Icons.bug_report_rounded,
                      //   color: Colors.amber,
                      //   trailing: Switch(
                      //     value: _allowUnstableUpdates,
                      //     activeThumbColor: cs.primary,
                      //     onChanged: (v) =>
                      //         setState(() => _allowUnstableUpdates = v),
                      //   ),
                      // ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(context, "Community & Source"),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'Discord',
                        subtitle: 'Join our Discord community',
                        icon: Icons
                            .chat_bubble_rounded, // Fallback for standard Material Icons
                        color: const Color(0xFF5865F2),
                        onTap: () => _launch(AppConstants.discordUrl),
                      ),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'Source Code',
                        subtitle: 'Github repository',
                        icon: Icons.code_rounded,
                        color: Colors.green,
                        onTap: () => _launch(AppConstants.githubUrl),
                      ),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'Telegram',
                        subtitle: 'Join the development community',
                        icon: Icons.chat_bubble_rounded,
                        color: Colors.lightBlue,
                        onTap: () => _launch(AppConstants.telegramUrl),
                      ),

                      const Spacer(),
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Made with ❤️ by ${AppConstants.author}",
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.outline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "© 2026 ${AppConstants.appName}",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.outline.withAlpha(150),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _launch(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  Future<void> _checkUpdates() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('You are on the latest version'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              showCloseIcon: true,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Update check failed. No connection.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
    }
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
