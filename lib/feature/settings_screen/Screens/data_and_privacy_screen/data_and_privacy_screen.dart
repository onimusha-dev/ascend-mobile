import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/data/db/app_database.dart';
import 'package:ascend/data/repository/note_repository.dart';
import 'package:ascend/feature/settings_screen/Screens/data_and_privacy_screen/services/backup_and_restore.dart';
import 'package:ascend/feature/settings_screen/widgets/common_setting_tile.dart';
import 'periodic_backups_screen.dart';
import 'package:ascend/core/services/notification_service.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

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
    BackupAndRestoreService().calculateDbSize().then((value) {
      if (mounted) {
        setState(() => dbSize = value);
        if (value == 'Error calc') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to calculate database size')),
          );
        }
      }
    });
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
              /// NOTE: uncomment on next update
              // _buildSectionTitle(context, "App Security"),
              // const SizedBox(height: 12),
              // _DataSettingTile(
              //   title: 'Screenshot Privacy',
              //   subtitle: 'Prevent screenshots of the app',
              //   icon: Icons.screenshot_rounded,
              //   color: Colors.blue,
              //   trailing: Switch(
              //     value: true,
              //     activeThumbColor: cs.primary,
              //     onChanged: (v) {},
              //   ),
              // ),
              // const SizedBox(height: 12),
              // _DataSettingTile(
              //   title: 'Error Reporting',
              //   subtitle: 'Help improve the app with logs',
              //   icon: Icons.bug_report_rounded,
              //   color: Colors.orange,
              //   trailing: Switch(
              //     value: false,
              //     activeThumbColor: cs.primary,
              //     onChanged: (v) {},
              //   ),
              // ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Backup & Restore"),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Export Data',
                subtitle: 'Create a local backup file',
                icon: Icons.cloud_upload_rounded,
                color: Colors.green,
                onTap: () => BackupAndRestoreService().createBackup(),
              ),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Import Data',
                subtitle: 'Restore from a backup file',
                icon: Icons.cloud_download_rounded,
                color: Colors.teal,
                onTap: () => BackupAndRestoreService().restoreBackup(),
              ),
              const SizedBox(height: 12),
              CommonSettingTile(
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
              // TODO: Hack - find a better way to listen to DB size changes
              CommonSettingTile(
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
                  });
                  BackupAndRestoreService().calculateDbSize().then((value) {
                    if (mounted) {
                      setState(() => dbSize = value);
                      if (value == 'Error calc') {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to calculate database size'),
                          ),
                        );
                      }
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              CommonSettingTile(
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

  /// NOTE: CLEAR WHOLE DATABASE
  /// There is no way to get it back
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
      // Show notification like restore does
      NotificationService().showInstantBackupAndRestoreNotification(
        id: 3,
        title: 'Database Wiped',
        body: 'All data has been cleared. Restart the app to finalize.',
        showRestartButton: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Database wiped successfully. Restarting..."),
          duration: Duration(seconds: 2),
        ),
      );

      // Refresh db size
      setState(() => dbSize = '0 KB');

      // Delay slightly so the snackbar is seen, then rebirth
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Phoenix.rebirth(context);
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
