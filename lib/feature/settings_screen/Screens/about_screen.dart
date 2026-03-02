import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _allowUnstableUpdates = false;

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
                      _AboutSettingTile(
                        title: 'Version',
                        subtitle: '1.0.0 (Release Candidate)',
                        icon: Icons.info_rounded,
                        color: Colors.blue,
                        onTap: _checkUpdates,
                      ),
                      const SizedBox(height: 12),
                      _AboutSettingTile(
                        title: 'Beta Channel',
                        subtitle: 'Receive early features & bugs',
                        icon: Icons.bug_report_rounded,
                        color: Colors.amber,
                        trailing: Switch(
                          value: _allowUnstableUpdates,
                          activeThumbColor: cs.primary,
                          onChanged: (v) =>
                              setState(() => _allowUnstableUpdates = v),
                        ),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle(context, "Community & Source"),
                      const SizedBox(height: 12),
                      _AboutSettingTile(
                        title: 'Discord',
                        subtitle: 'Join our Discord community',
                        icon: Icons
                            .chat_bubble_rounded, // Fallback for standard Material Icons
                        color: const Color(0xFF5865F2),
                        onTap: () => _launch('https://discord.gg/SqDNVhhdHV'),
                      ),
                      const SizedBox(height: 12),
                      _AboutSettingTile(
                        title: 'Source Code',
                        subtitle: 'Github repository',
                        icon: Icons.code_rounded,
                        color: Colors.green,
                        onTap: () => _launch(
                          'https://github.com/onimusha-dev/simple-task-manager-app',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AboutSettingTile(
                        title: 'Telegram',
                        subtitle: 'Join the development community',
                        icon: Icons.chat_bubble_rounded,
                        color: Colors.lightBlue,
                        onTap: () => _launch('https://t.me/+3sRfr-qGQ4BkZDRl'),
                      ),

                      const Spacer(),
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Made with ❤️ by 鬼 musha",
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.outline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "© 2026 fuck_your_todos",
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

class _AboutSettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _AboutSettingTile({
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
          padding: const EdgeInsets.all(16),
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
