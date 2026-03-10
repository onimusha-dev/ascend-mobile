import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingNotificationWidget extends StatelessWidget {
  const OnboardingNotificationWidget({super.key, bool isActive = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active_rounded, size: 80, color: cs.primary)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shake(hz: 3, rotation: 0.1, duration: 2.seconds)
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 500.ms),
          const SizedBox(height: 32),
          Text(
                'Stay Informed',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .slideY(begin: 0.5, end: 0, duration: 400.ms, delay: 200.ms)
              .fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 16),
          Text(
                'Allow notifications to receive timely reminders directly to your device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .slideY(begin: 0.5, end: 0, duration: 400.ms, delay: 400.ms)
              .fadeIn(duration: 400.ms, delay: 400.ms),
          const SizedBox(height: 48),
          FilledButton.icon(
                onPressed: () {
                  AppSettings.openAppSettings(
                    type: AppSettingsType.notification,
                  );
                },
                icon: const Icon(Icons.settings_rounded),
                label: const Text(
                  'Configure Notifications',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              )
              .animate()
              .slideY(begin: 0.5, end: 0, duration: 400.ms, delay: 600.ms)
              .fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ),
    );
  }
}
