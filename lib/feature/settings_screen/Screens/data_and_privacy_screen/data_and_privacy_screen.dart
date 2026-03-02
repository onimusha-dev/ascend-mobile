import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/app_database.dart';
import 'package:fuck_your_todos/data/repository/note_repository.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/data_and_privacy_screen/services/backup_and_restore.dart';

class DataAndPrivacyScreen extends ConsumerStatefulWidget {
  const DataAndPrivacyScreen({super.key});

  @override
  ConsumerState<DataAndPrivacyScreen> createState() =>
      _DataAndPrivacyScreenState();
}

class _DataAndPrivacyScreenState extends ConsumerState<DataAndPrivacyScreen> {
  late String dbSize;

  @override
  void initState() {
    super.initState();
    dbSize = 'calculating';
    BackupAndRestoreService().calculateDbSize().then(
      (value) => setState(() => dbSize = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data & Privacy',
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
              _buildSectionTitle(context, "App Security"),
              const SizedBox(height: 12),
              _DataSettingTile(
                title: 'Screenshot Privacy',
                subtitle: 'Prevent screenshots of the app',
                icon: Icons.screenshot_rounded,
                color: Colors.blue,
                trailing: Switch(
                  value: true,
                  activeThumbColor: cs.primary,
                  onChanged: (v) {},
                ),
              ),
              const SizedBox(height: 12),
              _DataSettingTile(
                title: 'Error Reporting',
                subtitle: 'Help improve the app with logs',
                icon: Icons.bug_report_rounded,
                color: Colors.orange,
                trailing: Switch(
                  value: false,
                  activeThumbColor: cs.primary,
                  onChanged: (v) {},
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle(context, "Backup & Restore"),
              const SizedBox(height: 12),
              _DataSettingTile(
                title: 'Export Data',
                subtitle: 'Create a local backup file',
                icon: Icons.cloud_upload_rounded,
                color: Colors.green,
                onTap: () => BackupAndRestoreService().createBackup(),
              ),
              const SizedBox(height: 12),
              _DataSettingTile(
                title: 'Import Data',
                subtitle: 'Restore from a backup file',
                icon: Icons.cloud_download_rounded,
                color: Colors.teal,
                onTap: () => BackupAndRestoreService().restoreBackup(),
              ),
              const SizedBox(height: 12),
              _DataSettingTile(
                title: 'Scheduled Backups',
                subtitle: 'Automate your data safety',
                icon: Icons.history_rounded,
                color: Colors.deepPurple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PeriodicBackupsScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle(context, "Storage Management"),
              const SizedBox(height: 12),
              _DataSettingTile(
                title: 'Database Size',
                subtitle: 'Space used on your local drive',
                icon: Icons.storage_rounded,
                color: Colors.blueGrey,
                trailing: dbSize == 'calculating'
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        dbSize,
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                onTap: () {
                  setState(() {
                    dbSize = 'calculating';
                    BackupAndRestoreService().calculateDbSize().then((value) {
                      setState(() => dbSize = value);
                    });
                  });
                },
              ),
              const SizedBox(height: 12),
              _DataSettingTile(
                title: 'Wipe All Data',
                subtitle: 'Reset app to factory state',
                icon: Icons.delete_sweep_rounded,
                color: cs.error,
                onTap: () => _handleWipeDatabase(context, ref),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleWipeDatabase(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Step 1: Initial Yes/No
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Wipe Database?"),
        content: const Text(
          "This will permanently delete all your tasks and categories. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text("YES, DELETE"),
          ),
        ],
      ),
    );

    if (firstConfirm != true || !context.mounted) return;

    // Step 2: 6-digit PIN
    final randomPin = (Random().nextInt(900000) + 100000)
        .toString(); // 100000-999999
    final pinController = TextEditingController();

    final pinConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Verification Code"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("To confirm deletion, type the following code:"),
            const SizedBox(height: 12),
            Center(
              child: Text(
                randomPin,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: "Enter 6-digit code",
                counterText: "",
                filled: true,
                fillColor: cs.surfaceContainerHighest.withAlpha(100),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              if (pinController.text == randomPin) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Incorrect code")));
              }
            },
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text("VERIFY"),
          ),
        ],
      ),
    );

    if (pinConfirm != true || !context.mounted) return;

    // Step 3: Final Yes/No
    final finalConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Final Warning"),
        content: const Text(
          "Are you absolutely sure? All data will be wiped immediately.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text("YES, WIPE EVERYTHING"),
          ),
        ],
      ),
    );

    if (finalConfirm != true || !context.mounted) return;

    // Perform the wipe using repository for notes and DB for categories
    await ref.read(noteRepositoryProvider).deleteAllNotes();
    await ref.read(appDatabaseProviderProvider).clearAllData();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Database wiped successfully")),
      );
      // Refresh db size
      setState(() {
        dbSize = 'calculating';
        BackupAndRestoreService().calculateDbSize().then(
          (value) => setState(() => dbSize = value),
        );
      });
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

class _DataSettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _DataSettingTile({
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

class PeriodicBackupsScreen extends StatelessWidget {
  const PeriodicBackupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Periodic Backups',
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 64,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Automated Backups',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Coming soon! We are working on a feature to automatically secure your data every day.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
