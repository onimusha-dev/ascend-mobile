import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _onlineSync = false;

  void _showComingSoonToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Premium features coming soon!'),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account',
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
              _UserProfileCard(cs: cs, theme: theme),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Cloud Synchronization"),
              const SizedBox(height: 12),
              _AccountSettingTile(
                title: 'Online Sync',
                subtitle: 'Backup and sync across devices',
                icon: Icons.sync_rounded,
                color: Colors.blue,
                trailing: Switch(
                  value: _onlineSync,
                  activeThumbColor: cs.primary,
                  onChanged: (v) => setState(() => _onlineSync = v),
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle(context, "Data Management"),
              const SizedBox(height: 12),
              _AccountSettingTile(
                title: 'Export Cloud Data',
                subtitle: 'Download your remote footprint',
                icon: Icons.cloud_download_rounded,
                color: Colors.teal,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _AccountSettingTile(
                title: 'Wipe Cloud Cache',
                subtitle: 'Clear remote storage only',
                icon: Icons.cloud_off_rounded,
                color: Colors.orange,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _AccountSettingTile(
                title: 'Delete Account',
                subtitle: 'Permanently erase everything',
                icon: Icons.delete_forever_rounded,
                color: cs.error,
                onTap: () {},
              ),

              const SizedBox(height: 32),
              _buildSectionTitle(context, "Plans & Upgrades"),
              const SizedBox(height: 12),
              _AccountSettingTile(
                title: 'Get Premium',
                subtitle: 'Unlock themes, backups & more',
                icon: Icons.workspace_premium_rounded,
                color: Colors.purple,
                onTap: _showComingSoonToast,
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

class _UserProfileCard extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  const _UserProfileCard({required this.cs, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary.withAlpha(40), cs.primary.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: cs.primary.withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: cs.surface,
              child: Icon(Icons.person_rounded, size: 36, color: cs.primary),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'demo@example.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _AccountSettingTile({
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
