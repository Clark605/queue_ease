import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app/router/app_router.dart';
import '../../../core/app/theme/app_colors.dart';
import '../../../core/app/theme/app_text_styles.dart';
import '../../../shared/auth/presentation/cubit/auth_cubit.dart';

/// Settings page for app and organization configuration.
///
/// Provides access to:
/// - Organization profile
/// - Working hours
/// - Notifications
/// - Account settings
/// - About app
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        title: Text(
          'Settings',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.outline.withValues(alpha: 0.4),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader('Organization'),
          _buildSettingsTile(
            context,
            icon: Icons.business,
            title: 'Organization Profile',
            subtitle: 'Manage your organization details',
            onTap: () => context.push(Routes.adminOrgProfile),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.access_time,
            title: 'Working Hours',
            subtitle: 'Set your operating hours',
            onTap: () => context.push(Routes.adminWorkingHours),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.qr_code,
            title: 'Share Access',
            subtitle: 'QR code and booking link',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share Access - Coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(height: 32),

          _buildSectionHeader('Preferences'),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications - Coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: 'Light, Dark, or System',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme settings - Coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(height: 32),

          _buildSectionHeader('Account'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Account Settings',
            subtitle: 'Update your account information',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account Settings - Coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            subtitle: 'Password and security settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy & Security - Coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(height: 32),

          _buildSectionHeader('About'),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About QueueEase',
            subtitle: 'Version $_appVersion',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'QueueEase',
                applicationVersion: _appVersion,
                applicationIcon: const Icon(
                  Icons.queue,
                  size: 48,
                  color: AppColors.primary,
                ),
                children: [
                  const Text(
                    'QueueEase helps businesses manage queues and appointments efficiently.',
                  ),
                ],
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms & Privacy',
            subtitle: 'Read our terms and privacy policy',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms & Privacy - Coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and send feedback',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & Support - Coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showSignOutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthCubit>().signOut();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
