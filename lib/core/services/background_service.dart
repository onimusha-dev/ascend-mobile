import 'dart:io';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ascend/core/services/app_preferences.dart';
import 'package:ascend/data/db/app_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Native called background task: $task");

    // Ensure bindings
    WidgetsFlutterBinding.ensureInitialized();
    await AppPreferences.init();

    final db = AppDatabase();

    try {
      if (task == BackgroundService.periodicTaskName ||
          task == Workmanager.iOSBackgroundTask) {
        await _handleNotifications(db);
        await _handleAutomatedBackups(db);
      }
    } catch (err) {
      debugPrint("Error in background task: $err");
      return Future.value(false);
    } finally {
      await db.close();
    }

    return Future.value(true);
  });
}

Future<void> _handleNotifications(AppDatabase db) async {
  // Initialize notifications locally in the isolate
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );
  const initializationSettingsIOS = DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  final now = DateTime.now();

  // 1. Check Task Deadlines
  final tasks = await db.select(db.noteTable).get();
  for (final task in tasks) {
    if (task.isCompleted == true) continue;
    if (task.dueDate != null) {
      final taskDateTime = task.dueDate!;

      // If the task is due in the next 15 minutes and hasn't been notified
      final difference = taskDateTime.difference(now);
      if (difference.inMinutes > 0 && difference.inMinutes <= 15) {
        final notifiedKey = 'notified_task_${task.id}';
        final alreadyNotified =
            AppPreferences.getPreferenceBool(notifiedKey) ?? false;

        if (!alreadyNotified) {
          await _showNotification(
            flutterLocalNotificationsPlugin,
            id: task.id,
            title: "Upcoming Deadline!",
            body: "'${task.title}' is due in ${difference.inMinutes} minutes.",
          );
          await AppPreferences.setPreferenceBool(notifiedKey, true);
        }
      }

      // If overdue within the last 1-hour and not notified
      if (difference.inMinutes < 0 && difference.inMinutes >= -60) {
        final overdueNotifiedKey = 'overdue_notified_task_${task.id}';
        final alreadyNotified =
            AppPreferences.getPreferenceBool(overdueNotifiedKey) ?? false;

        if (!alreadyNotified) {
          await _showNotification(
            flutterLocalNotificationsPlugin,
            id: task.id + 10000,
            title: "Forgot something?",
            body: "'${task.title}' is overdue. Ascend and conquer it now!",
          );
          await AppPreferences.setPreferenceBool(overdueNotifiedKey, true);
        }
      }
    }
  }

  // 2. Add Gamification Streak logic if Gamification is enabled
  final gamificationEnabled =
      AppPreferences.getPreferenceBool(AppPreferences.keyGamificationEnabled) ??
      false;
  if (gamificationEnabled) {
    final progressDao = db.userProgressDao;
    final progress = await progressDao.getProgress();
    if (progress != null && progress.lastCompletionDate != null) {
      final lastCompletion = progress.lastCompletionDate!;
      final difference = now.difference(lastCompletion);

      // If it's been more than 24 hours but less than 48 hours, warn about losing streak
      if (difference.inHours >= 24 && difference.inHours < 40) {
        final streakWarnKey =
            'streak_warning_${now.year}_${now.month}_${now.day}';
        final alreadyWarned =
            AppPreferences.getPreferenceBool(streakWarnKey) ?? false;

        if (!alreadyWarned) {
          await _showNotification(
            flutterLocalNotificationsPlugin,
            id: 99999,
            title: "Keep your streak alive! 🔥",
            body:
                "Complete a task today to maintain your current streak of ${progress.currentStreak}.",
          );
          await AppPreferences.setPreferenceBool(streakWarnKey, true);
        }
      }
    }
  }
}

Future<void> _handleAutomatedBackups(AppDatabase db) async {
  final isBackupEnabled =
      AppPreferences.getPreferenceBool("auto_backup_enabled") ?? false;
  if (!isBackupEnabled) return;

  final backupFolder = AppPreferences.getPreference("auto_backup_folder");
  if (backupFolder == null || backupFolder.isEmpty) return;

  final lastBackupStr = AppPreferences.getPreference("last_backup_time");
  if (lastBackupStr != null) {
    final lastBackupTime = DateTime.parse(lastBackupStr);
    // Determine interval, default is 24 hours
    final diff = DateTime.now().difference(lastBackupTime);
    if (diff.inHours < 24) {
      return; // Not time yet
    }
  }

  // Perform Backup
  final targetDir = Directory(backupFolder);
  if (!targetDir.existsSync()) return;

  final appDir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(appDir.path, 'journal_app_db.sqlite'));
  if (!dbFile.existsSync()) return;

  final timestamp = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '-')
      .split('.')
      .first;
  final backupFile = File(
    p.join(backupFolder, 'ascend_backup_$timestamp.sqlite'),
  );

  // Copy db file
  await dbFile.copy(backupFile.path);
  await AppPreferences.setPreference(
    "last_backup_time",
    DateTime.now().toIso8601String(),
  );

  // Cleanup old backups
  final keepCount =
      AppPreferences.getPreferenceInt("auto_backup_keep_count") ?? 5;

  final existingBackups = targetDir
      .listSync()
      .where(
        (f) =>
            f is File &&
            p.basename(f.path).startsWith('ascend_backup_') &&
            p.basename(f.path).endsWith('.sqlite'),
      )
      .toList();

  // Sort by modified time descending (newest first)
  existingBackups.sort(
    (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
  );

  // Remove excess
  if (existingBackups.length > keepCount) {
    final toRemove = existingBackups.sublist(keepCount);
    for (var file in toRemove) {
      try {
        file.deleteSync();
      } catch (_) {}
    }
  }
}

Future<void> _showNotification(
  FlutterLocalNotificationsPlugin plugin, {
  required int id,
  required String title,
  required String body,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'ascend_task_reminders',
    'Task Reminders',
    channelDescription: 'Notifications for upcoming and overdue tasks',
    importance: Importance.max,
    priority: Priority.high,
  );

  const iosDetails = DarwinNotificationDetails();
  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: notificationDetails,
  );
}

class BackgroundService {
  static const periodicTaskName = "com.onimusha.ascend.periodicTask";

  static Future<void> initialize() async {
    // Initialize WorkManager
    await Workmanager().initialize(callbackDispatcher);

    // Register Periodic Task
    // This will securely run roughly every 15-30 mins in the background depending on OS constraints
    await Workmanager().registerPeriodicTask(
      "1",
      periodicTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
