import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/faq_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/theme_bloc.dart';
import 'package:mobile_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/user_profile_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/edit_profile_modal.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/faq_page.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/privacy_policy_page.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/report_user_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/features/content_creator/dashboard/data/datasources/influencer_remote_data_source.dart';
import 'package:mobile_app/features/network/presentation/pages/network_page.dart';
import 'package:mobile_app/features/network/presentation/bloc/network_bloc.dart';
import 'package:mobile_app/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InfluencerProfilePage extends StatefulWidget {
  const InfluencerProfilePage({super.key});

  @override
  State<InfluencerProfilePage> createState() => _InfluencerProfilePageState();
}

class _InfluencerProfilePageState extends State<InfluencerProfilePage> {
  bool _pushNotificationsEnabled = true;
  final ImagePicker _imagePicker = ImagePicker();
  final InfluencerRemoteDataSource _dataSource =
      sl<InfluencerRemoteDataSource>();
  bool _isUploadingPicture = false;

  @override
  void initState() {
    super.initState();
    // Load profile data if not already loaded - Reusing DashboardBloc as they likely share similar data needs
    // or we might need a separate InfluencerProfileBloc if data differs significantly.
    // For now assuming we can reuse or at least consistent UI structure.
    context.read<DashboardBloc>().add(const LoadDashboardData());
    _loadPushNotificationSetting();
  }

  Future<void> _loadPushNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotificationsEnabled =
          prefs.getBool('push_notifications_enabled') ?? true;
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
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final profile = state is DashboardLoaded ? state.profile : null;
        final isLoading = state is DashboardLoading && profile == null;

        return Scaffold(
          backgroundColor: primary,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context, textColor, profile, isLoading),
                  const SizedBox(height: 24),
                  _profileSection(
                    cardColor,
                    accent,
                    textColor,
                    subtleText,
                    profile,
                    isLoading,
                  ),
                  const SizedBox(height: 24),
                  _settingsSection(
                    context,
                    cardColor,
                    accent,
                    textColor,
                    subtleText,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(
    BuildContext context,
    Color textColor,
    UserProfileModel? profile,
    bool isLoading,
  ) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: accent.withOpacity(0.2),
              backgroundImage:
                  profile?.profilePictureUrl != null &&
                      profile!.profilePictureUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(profile.profilePictureUrl!)
                  : null,
              child: _isUploadingPicture
                  ? CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    )
                  : profile?.profilePictureUrl == null ||
                        profile!.profilePictureUrl!.isEmpty
                  ? Icon(Icons.person, size: 30, color: accent)
                  : null,
            ),
            if (!isLoading && !_isUploadingPicture)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () =>
                      _showProfilePictureOptions(context, textColor, theme),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.primaryColor, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                isLoading ? 'Loading...' : 'Freelancer / Content Creator',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => EditProfileModal(profile: profile),
            );
          },
          icon: Icon(Icons.edit_outlined, color: textColor),
        ),
      ],
    );
  }

  Future<void> _showProfilePictureOptions(
    BuildContext context,
    Color textColor,
    ThemeData theme,
  ) async {
    final cardColor = theme.cardColor;
    final accent = theme.colorScheme.secondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile Picture',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.photo_camera, color: accent),
              title: Text('Take Photo', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: accent),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                final profile = state is DashboardLoaded ? state.profile : null;
                final hasPicture =
                    profile?.profilePictureUrl != null &&
                    profile!.profilePictureUrl!.isNotEmpty;

                if (hasPicture) {
                  return ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      'Remove Picture',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteProfilePicture();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        await _uploadProfilePicture(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    setState(() => _isUploadingPicture = true);

    try {
      await _dataSource.uploadProfilePicture(imageFile);
      if (mounted) {
        context.read<DashboardBloc>().add(const RefreshDashboardData());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPicture = false);
      }
    }
  }

  Future<void> _deleteProfilePicture() async {
    setState(() => _isUploadingPicture = true);

    try {
      await _dataSource.deleteProfilePicture();
      if (mounted) {
        context.read<DashboardBloc>().add(const RefreshDashboardData());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPicture = false);
      }
    }
  }

  Widget _profileSection(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
    UserProfileModel? profile,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(
            'Email',
            isLoading
                ? 'Loading...'
                : (profile?.email ?? 'john.doe@example.com'),
            textColor,
            subtleText,
          ),
          const SizedBox(height: 12),
          _infoRow(
            'Phone',
            isLoading ? 'Loading...' : (profile?.phone ?? '+1 234 567 890'),
            textColor,
            subtleText,
          ),
          const SizedBox(height: 12),
          _infoRow(
            'Location',
            isLoading ? 'Loading...' : (profile?.location ?? 'New York, USA'),
            textColor,
            subtleText,
          ),
          if (profile?.companyName != null) ...[
            const SizedBox(height: 12),
            _infoRow('Portfolio', 'www.johndoe.com', textColor, subtleText),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    Color textColor,
    Color subtleText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: subtleText, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _settingsSection(
    BuildContext context,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogOutState) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login_page', (route) => false);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Account', [
            _buildMenuItem(
              context,
              icon: Icons.link,
              label: 'Linked Accounts',
              onTap: () {
                // TODO: Implement linked accounts
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
            _buildMenuItem(
              context,
              icon: Icons.work_outline,
              label: 'My Skills',
              onTap: () {
                // TODO: Implement my skills
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
            _buildMenuItem(
              context,
              icon: Icons.people_outline,
              label: 'My Network',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => sl<NetworkBloc>(),
                      child: const NetworkPage(),
                    ),
                  ),
                );
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
          ], textColor),
          const SizedBox(height: 24),
          _buildSection('Notifications & Privacy', [
            _buildToggleItem(
              icon: Icons.notifications_outlined,
              label: 'Push Notifications',
              value: _pushNotificationsEnabled,
              onChanged: _togglePushNotifications,
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
            ),
            _buildMenuItem(
              context,
              icon: Icons.shield_outlined,
              label: 'Data & Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage(),
                  ),
                );
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
            _buildMenuItem(
              context,
              icon: Icons.palette_outlined,
              label: 'Language / Theme',
              subtitle: _getThemeSubtitle(context),
              onTap: () {
                _showThemeSelector(
                  context,
                  cardColor,
                  accent,
                  textColor,
                  subtleText,
                );
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
          ], textColor),
          const SizedBox(height: 24),
          _buildSection('Help & Contact', [
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              label: 'FAQ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQPage()),
                );
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
            _buildMenuItem(
              context,
              icon: Icons.gavel_outlined,
              label: 'Dispute Center',
              onTap: () {
                // TODO: Show dispute center
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
            _buildMenuItem(
              context,
              icon: Icons.email_outlined,
              label: 'Email Us',
              onTap: () {
                // TODO: Open email
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              label: 'About',
              onTap: () {
                _showAboutDialog(
                  context,
                  cardColor,
                  textColor,
                  subtleText,
                  accent,
                );
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
          ], textColor),
          const SizedBox(height: 24),
          _buildSection('Danger Zone', [
            _buildMenuItem(
              context,
              icon: Icons.logout,
              label: 'Log Out',
              isDanger: true,
              onTap: () {
                _showLogoutDialog(
                  context,
                  cardColor,
                  textColor,
                  subtleText,
                  accent,
                );
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
            _buildMenuItem(
              context,
              icon: Icons.delete_outline,
              label: 'Delete Account',
              isDanger: true,
              onTap: () {
                _showDeleteAccountDialog(
                  context,
                  cardColor,
                  textColor,
                  subtleText,
                  accent,
                );
              },
              cardColor: cardColor,
              accent: accent,
              textColor: textColor,
              subtleText: subtleText,
            ),
          ], textColor),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Version 2.4.0 (Build 1042)',
              style: TextStyle(color: subtleText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
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
    required Color cardColor,
    required Color accent,
    required Color textColor,
    required Color subtleText,
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
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDanger ? Colors.redAccent : accent,
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
                          color: isDanger ? Colors.redAccent : textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(color: subtleText, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isDanger)
                  Icon(Icons.chevron_right, color: subtleText, size: 24),
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
    required Color cardColor,
    required Color accent,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: accent),
        ],
      ),
    );
  }

  String _getThemeSubtitle(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final themeMode = themeState is ThemeLoaded
        ? themeState.mode
        : AppThemeMode.dark;
    final themeName = themeMode == AppThemeMode.dark
        ? 'Dark Mode'
        : 'Light Mode';
    return 'English / $themeName';
  }

  void _showThemeSelector(
    BuildContext context,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Theme',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                final currentMode = state is ThemeLoaded
                    ? state.mode
                    : AppThemeMode.dark;
                return Column(
                  children: [
                    _buildThemeOption(
                      context,
                      'Light Mode',
                      AppThemeMode.light,
                      currentMode == AppThemeMode.light,
                      cardColor,
                      accent,
                      textColor,
                    ),
                    const SizedBox(height: 12),
                    _buildThemeOption(
                      context,
                      'Dark Mode',
                      AppThemeMode.dark,
                      currentMode == AppThemeMode.dark,
                      cardColor,
                      accent,
                      textColor,
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
    Color cardColor,
    Color accent,
    Color textColor,
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
            color: isSelected ? accent.withOpacity(0.2) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: accent),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color subtleText,
    Color accent,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Log Out', style: TextStyle(color: textColor)),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: subtleText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: subtleText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const LogOutEvent());
            },
            child: Text('Log Out', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color subtleText,
    Color accent,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          'Delete Account',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: subtleText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: subtleText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete account
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Delete account functionality coming soon',
                    style: TextStyle(color: textColor),
                  ),
                  backgroundColor: cardColor,
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

  void _showAboutDialog(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color subtleText,
    Color accent,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('About', style: TextStyle(color: textColor)),
        content: Text(
          'Version 2.4.0 (Build 1042)',
          style: TextStyle(color: subtleText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }
}
