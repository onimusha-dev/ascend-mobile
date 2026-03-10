import 'package:flutter/material.dart';
import 'package:ascend/feature/auth/widget/login_screen.dart';
import 'package:ascend/feature/auth/widget/register_screen.dart';

class UserProfileCard extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  final bool isLoggedIn;
  final String? userEmail;
  final String? memberSince;
  final VoidCallback onAuthChanged;

  const UserProfileCard({
    super.key,
    required this.cs,
    required this.theme,
    required this.isLoggedIn,
    required this.onAuthChanged,
    this.userEmail,
    this.memberSince,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Avatar ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLoggedIn
                        ? cs.primary.withAlpha(200)
                        : cs.outlineVariant.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primary.withAlpha(20),
                  child: Icon(
                    isLoggedIn
                        ? Icons.person_rounded
                        : Icons.person_off_rounded,
                    size: 26,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? (userEmail ?? 'Logged In') : 'Local Account',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLoggedIn
                          ? (memberSince != null
                                ? 'Member since $memberSince'
                                : 'Cloud sync enabled')
                          : 'Not synced — data is local only',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isLoggedIn
                            ? cs.primary.withAlpha(190)
                            : cs.onSurfaceVariant.withAlpha(160),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isLoggedIn
                      ? cs.primary.withAlpha(20)
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLoggedIn
                        ? cs.primary.withAlpha(60)
                        : cs.outlineVariant.withAlpha(60),
                  ),
                ),
                child: Text(
                  isLoggedIn ? 'Synced' : 'Local',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isLoggedIn ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          // Login / signup buttons for guests
          if (!isLoggedIn) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final didLogin = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                      if (didLogin == true) onAuthChanged();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final didRegister = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                      if (didRegister == true) onAuthChanged();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.outlineVariant.withAlpha(100)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
