import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/theme_bloc.dart';
import 'package:mobile_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/edit_profile_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPushNotificationSetting();
  }

  Future<void> _loadPushNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotificationsEnabled = prefs.getBool('push_notifications_enabled') ?? true;
    });
  }

  Future<void> _togglePushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications_enabled', value);
    setState(() {
      _pushNotificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final themeMode = themeState is ThemeLoaded ? themeState.mode : AppThemeMode.dark;
        final colors = AppTheme.getColors(themeMode);
        final theme = AppTheme.getThemeData(themeMode);

        return Theme(
          data: theme,
          child: Scaffold(
            backgroundColor: colors.primary,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colors.text),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Settings & Preferences',
                style: TextStyle(color: colors.text),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Account',
                      [
                        _buildMenuItem(
                          context,
                          icon: Icons.person_outline,
                          label: 'Edit Profile',
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const EditProfileModal(),
                            );
                          },
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.lock_outline,
                          label: 'Change Password',
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const EditProfileModal(showPasswordTab: true),
                            );
                          },
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.link,
                          label: 'Linked Accounts',
                          onTap: () {
                            // TODO: Implement linked accounts
                          },
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.people_outline,
                          label: 'My Network',
                          onTap: () {
                            // TODO: Implement my network
                          },
                          colors: colors,
                        ),
                      ],
                      colors,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Notifications & Privacy',
                      [
                        _buildToggleItem(
                          icon: Icons.notifications_outlined,
                          label: 'Push Notifications',
                          value: _pushNotificationsEnabled,
                          onChanged: _togglePushNotifications,
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.shield_outlined,
                          label: 'Data & Privacy Policy',
                          onTap: () {
                            // TODO: Show privacy policy
                          },
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.palette_outlined,
                          label: 'Language / Theme',
                          subtitle: _getThemeSubtitle(themeMode),
                          onTap: () {
                            _showThemeSelector(context, colors);
                          },
                          colors: colors,
                        ),
                      ],
                      colors,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Help & Contact',
                      [
                        _buildMenuItem(
                          context,
                          icon: Icons.help_outline,
                          label: 'FAQ',
                          onTap: () {
                            // TODO: Show FAQ
                          },
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.gavel_outlined,
                          label: 'Dispute Center',
                          onTap: () {
                            // TODO: Show dispute center
                          },
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.report_outlined,
                          label: 'Report User',
                          onTap: () {
                            // TODO: Show report user
                          },
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.email_outlined,
                          label: 'Email Us',
                          onTap: () {
                            // TODO: Open email
                          },
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.info_outline,
                          label: 'About',
                          onTap: () {
                            _showAboutDialog(context, colors);
                          },
                          colors: colors,
                        ),
                      ],
                      colors,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Danger Zone',
                      [
                        _buildMenuItem(
                          context,
                          icon: Icons.logout,
                          label: 'Log Out',
                          isDanger: true,
                          onTap: () {
                            _showLogoutDialog(context, colors);
                          },
                          colors: colors,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.delete_outline,
                          label: 'Delete Account',
                          isDanger: true,
                          onTap: () {
                            _showDeleteAccountDialog(context, colors);
                          },
                          colors: colors,
                        ),
                      ],
                      colors,
                    ),
                    const SizedBox(height: 24),
                    _buildVersionInfo(colors),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> items, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    required AppColors colors,
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDanger ? Colors.redAccent : colors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: isDanger ? Colors.redAccent : colors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isDanger)
                  Icon(
                    Icons.chevron_right,
                    color: colors.textSecondary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required AppColors colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.secondary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.secondary,
          ),
        ],
      ),
    );
  }

  String _getThemeSubtitle(AppThemeMode mode) {
    if (mode == AppThemeMode.dark) {
      return 'English / Dark Mode';
    } else {
      return 'English / Light Mode';
    }
  }

  void _showThemeSelector(BuildContext context, AppColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Theme',
              style: TextStyle(
                color: colors.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                final currentMode = state is ThemeLoaded ? state.mode : AppThemeMode.dark;
                return Column(
                  children: [
                    _buildThemeOption(
                      context,
                      'Light Mode',
                      AppThemeMode.light,
                      currentMode == AppThemeMode.light,
                      colors,
                    ),
                    const SizedBox(height: 12),
                    _buildThemeOption(
                      context,
                      'Dark Mode',
                      AppThemeMode.dark,
                      currentMode == AppThemeMode.dark,
                      colors,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    AppThemeMode mode,
    bool isSelected,
    AppColors colors,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<ThemeBloc>().add(ChangeThemeEvent(mode: mode));
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? colors.secondary.withOpacity(0.2) : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colors.secondary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colors.secondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text(
          'Log Out',
          style: TextStyle(color: colors.text),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const LogOutEvent());
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text(
          'Delete Account',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete account
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Delete account functionality coming soon',
                    style: TextStyle(color: colors.text),
                  ),
                  backgroundColor: colors.card,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text(
          'About',
          style: TextStyle(color: colors.text),
        ),
        content: Text(
          'Version 2.4.0 (Build 1042)',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: colors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(AppColors colors) {
    return Center(
      child: Text(
        'Version 2.4.0 (Build 1042)',
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}

