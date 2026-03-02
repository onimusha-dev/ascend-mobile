import 'package:flutter/material.dart';
import 'package:ascend/feature/settings_screen/Screens/account_screen/widgets/user_profile_card.dart';
import 'package:ascend/feature/settings_screen/widgets/common_setting_tile.dart';
import 'package:ascend/core/services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState({bool showSuccessToast = false}) async {
    setState(() => _isLoading = true);

    final loggedIn = await AuthService.isLoggedIn();
    Map<String, dynamic>? profile;

    if (loggedIn) {
      final result = await AuthService.getProfile();
      if (result['success'] == true) {
        profile = result['user'] as Map<String, dynamic>?;
      }
    }

    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _userProfile = profile;
        _isLoading = false;
      });

      if (showSuccessToast && loggedIn) {
        // Small delay so the snackbar appears after the screen has rebuilt
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profile != null
                        ? 'Welcome, ${profile['email']}!'
                        : 'Logged in successfully!',
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        }
      }
    }
  }

  String? _formatMemberSince(dynamic rawDate) {
    if (rawDate == null) return null;
    try {
      final date = DateTime.parse(rawDate.toString());
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return null;
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure? Your local data stays safe on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Log Out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userProfile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserProfileCard(
                      cs: cs,
                      theme: theme,
                      isLoggedIn: _isLoggedIn,
                      userEmail: _userProfile?['email']?.toString(),
                      memberSince: _formatMemberSince(
                        _userProfile?['createdAt'],
                      ),
                      onAuthChanged: () =>
                          _loadAuthState(showSuccessToast: true),
                    ),

                    if (_isLoggedIn) ...[
                      const SizedBox(height: 32),
                      _buildSectionTitle(context, 'Cloud Synchronization'),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'Cloud Backup',
                        subtitle: 'Upload your journal data to the cloud',
                        icon: Icons.cloud_upload_rounded,
                        color: Colors.blue,
                        onTap: () => _showComingSoon('Cloud Backup'),
                      ),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'Restore from Cloud',
                        subtitle: 'Download and restore a backup',
                        icon: Icons.cloud_download_rounded,
                        color: Colors.teal,
                        onTap: () => _showComingSoon('Cloud Restore'),
                      ),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'View Backups',
                        subtitle: 'See all your saved cloud snapshots',
                        icon: Icons.history_rounded,
                        color: Colors.indigo,
                        onTap: () => _showComingSoon('Backup history'),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle(context, 'Plans & Upgrades'),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'Get Premium',
                        subtitle: 'Unlock themes, unlimited backups & more',
                        icon: Icons.workspace_premium_rounded,
                        color: Colors.purple,
                        onTap: () => _showComingSoon('Premium'),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle(context, 'Session'),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'Log Out',
                        subtitle: 'Sign out from this device',
                        icon: Icons.logout_rounded,
                        color: Colors.orange,
                        onTap: _handleLogout,
                      ),
                      const SizedBox(height: 12),
                      CommonSettingTile(
                        title: 'Delete Account',
                        subtitle: 'Permanently erase your account & data',
                        icon: Icons.delete_forever_rounded,
                        color: cs.error,
                        onTap: () => _showComingSoon('Account deletion'),
                      ),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
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
