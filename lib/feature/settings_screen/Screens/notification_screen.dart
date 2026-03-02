import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ascend/feature/settings_screen/widgets/common_setting_tile.dart';

// Basic provider for notification settings
final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, Map<String, bool>>(
      () => NotificationSettingsNotifier(),
    );

class NotificationSettingsNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    return {
      'daily_reminders': true,
      'task_deadlines': true,
      'streak_alerts': true,
      'app_updates': false,
    };
  }

  void toggleSetting(String key) {
    state = {...state, key: !state[key]!};
  }
}

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with WidgetsBindingObserver {
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
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
              if (!_hasPermission)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.error.withAlpha(50)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications_off_rounded,
                        color: cs.error,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications Disabled',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: cs.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please enable notifications in your system settings to receive reminders and alerts.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => openAppSettings(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.error,
                                foregroundColor: cs.onError,
                                elevation: 0,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('Open Settings'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              _buildSectionTitle(context, "Task Alerts"),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Daily Reminders',
                subtitle: 'Morning overview of your tasks',
                icon: Icons.wb_sunny_rounded,
                color: Colors.orange,
                trailing: Switch(
                  value: settings['daily_reminders']!,
                  activeThumbColor: cs.primary,
                  onChanged: (_) => ref
                      .read(notificationSettingsProvider.notifier)
                      .toggleSetting('daily_reminders'),
                ),
              ),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Task Deadlines',
                subtitle: 'Alerts for upcoming due times',
                icon: Icons.timer_rounded,
                color: Colors.redAccent,
                trailing: Switch(
                  value: settings['task_deadlines']!,
                  activeThumbColor: cs.primary,
                  onChanged: (_) => ref
                      .read(notificationSettingsProvider.notifier)
                      .toggleSetting('task_deadlines'),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Gamification & System"),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'Streak Alerts',
                subtitle: 'Reminders to keep your streak alive',
                icon: Icons.local_fire_department_rounded,
                color: Colors.deepOrange,
                trailing: Switch(
                  value: settings['streak_alerts']!,
                  activeThumbColor: cs.primary,
                  onChanged: (_) => ref
                      .read(notificationSettingsProvider.notifier)
                      .toggleSetting('streak_alerts'),
                ),
              ),
              const SizedBox(height: 12),
              CommonSettingTile(
                title: 'App Updates',
                subtitle: 'News about new features',
                icon: Icons.system_update_rounded,
                color: Colors.blueAccent,
                trailing: Switch(
                  value: settings['app_updates']!,
                  activeThumbColor: cs.primary,
                  onChanged: (_) => ref
                      .read(notificationSettingsProvider.notifier)
                      .toggleSetting('app_updates'),
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
