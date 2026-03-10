import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ascend/core/services/app_preferences.dart';
import 'package:ascend/feature/settings_screen/widgets/common_setting_tile.dart';

final periodicBackupsProvider =
    NotifierProvider<PeriodicBackupsNotifier, PeriodicBackupsState>(
      () => PeriodicBackupsNotifier(),
    );

class PeriodicBackupsState {
  final bool isEnabled;
  final String? folderPath;
  final int keepCount;

  PeriodicBackupsState({
    required this.isEnabled,
    this.folderPath,
    required this.keepCount,
  });

  PeriodicBackupsState copyWith({
    bool? isEnabled,
    String? folderPath,
    int? keepCount,
  }) {
    return PeriodicBackupsState(
      isEnabled: isEnabled ?? this.isEnabled,
      folderPath: folderPath ?? this.folderPath,
      keepCount: keepCount ?? this.keepCount,
    );
  }
}

class PeriodicBackupsNotifier extends Notifier<PeriodicBackupsState> {
  @override
  PeriodicBackupsState build() {
    return PeriodicBackupsState(
      isEnabled:
          AppPreferences.getPreferenceBool("auto_backup_enabled") ?? false,
      folderPath: AppPreferences.getPreference("auto_backup_folder"),
      keepCount: AppPreferences.getPreferenceInt("auto_backup_keep_count") ?? 5,
    );
  }

  Future<void> toggleEnabled(bool value) async {
    await AppPreferences.setPreferenceBool("auto_backup_enabled", value);
    state = state.copyWith(isEnabled: value);
  }

  Future<bool> selectFolder() async {
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        await AppPreferences.setPreference(
          "auto_backup_folder",
          selectedDirectory,
        );
        state = state.copyWith(folderPath: selectedDirectory);
        return true;
      }
    }
    return false;
  }

  Future<void> setKeepCount(int count) async {
    await AppPreferences.setPreferenceInt("auto_backup_keep_count", count);
    state = state.copyWith(keepCount: count);
  }
}

class PeriodicBackupsScreen extends ConsumerWidget {
  const PeriodicBackupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(periodicBackupsProvider);
    final notifier = ref.read(periodicBackupsProvider.notifier);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonSettingTile(
              title: 'Enable Auto-Backups',
              subtitle: 'Automatically backup your database every 24 hours.',
              icon: Icons.auto_awesome_rounded,
              color: Colors.blueAccent,
              trailing: Switch(
                value: state.isEnabled,
                activeThumbColor: cs.primary,
                onChanged: (val) {
                  if (val && state.folderPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a folder first'),
                      ),
                    );
                    return;
                  }
                  notifier.toggleEnabled(val);
                },
              ),
            ),
            const SizedBox(height: 16),
            CommonSettingTile(
              title: 'Backup Folder',
              subtitle: state.folderPath ?? 'Tap to select folder',
              icon: Icons.folder_rounded,
              color: Colors.amber,
              onTap: () async {
                final success = await notifier.selectFolder();
                if (context.mounted && !success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Folder selection canceled or permission denied',
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            if (state.folderPath != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keep up to ${state.keepCount} backups',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Older backups will be deleted automatically to save space.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.outline,
                      ),
                    ),
                    Slider(
                      value: state.keepCount.toDouble(),
                      min: 3,
                      max: 10,
                      divisions: 7,
                      label: state.keepCount.toString(),
                      onChanged: (val) {
                        notifier.setKeepCount(val.toInt());
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Make sure Ascend has permission to run in the background.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
