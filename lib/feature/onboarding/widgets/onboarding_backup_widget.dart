import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ascend/feature/auth/widget/login_screen.dart';
import 'package:ascend/feature/auth/widget/register_screen.dart';
import 'package:ascend/feature/settings_screen/Screens/data_and_privacy_screen/services/backup_and_restore.dart';

class OnboardingBackupWidget extends StatelessWidget {
  const OnboardingBackupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 80, color: cs.primary)
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 500.ms),
          const SizedBox(height: 32),
          Text(
                'Your Data is Secure',
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
                'Keep your data safe with native local backups and easy restores. You hold the keys.',
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
                onPressed: () async {
                  await BackupAndRestoreService().restoreBackup();
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text(
                  'Import local backup',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              )
              .animate()
              .slideY(begin: 0.5, end: 0, duration: 400.ms, delay: 600.ms)
              .fadeIn(duration: 400.ms, delay: 600.ms),

          const SizedBox(height: 16),

          Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(
                          color: cs.outlineVariant.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(
                          color: cs.outlineVariant.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        'Signup',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .slideY(begin: 0.5, end: 0, duration: 400.ms, delay: 800.ms)
              .fadeIn(duration: 400.ms, delay: 800.ms),
        ],
      ),
    );
  }
}
