import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/theme_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/update_profile_params.dart';

class EditProfileModal extends StatefulWidget {
  final dynamic profile;
  final bool showPasswordTab;

  const EditProfileModal({super.key, this.profile, this.showPasswordTab = false});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Profile fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  // Role-specific fields (Freelancer)
  final _headlineController = TextEditingController();
  final _introductionController = TextEditingController();

  // Role-specific fields (Client/Business Owner)
  final _businessNameController = TextEditingController();
  final _companyWebsiteController = TextEditingController();
  final _aboutBusinessController = TextEditingController();
  final _businessPhoneController = TextEditingController();

  // Password fields
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.showPasswordTab) {
      _tabController.index = 1;
    }
    _loadProfileData();
  }

  void _loadProfileData() {
    if (widget.profile != null) {
      _firstNameController.text = widget.profile.firstName ?? '';
      _lastNameController.text = widget.profile.lastName ?? '';
      _emailController.text = widget.profile.email ?? '';
      _phoneController.text = widget.profile.phone ?? '';
      _locationController.text = widget.profile.location ?? '';

      // Load freelancer-specific data
      if (widget.profile.freelancerInfo != null) {
        _headlineController.text =
            widget.profile.freelancerInfo?.headline ?? '';
        _introductionController.text =
            widget.profile.freelancerInfo?.introduction ?? '';
      }

      // Load client-specific data
      if (widget.profile.clientInfo != null) {
        _businessNameController.text =
            widget.profile.clientInfo?.businessName ?? '';
        _companyWebsiteController.text =
            widget.profile.clientInfo?.companyWebsite ?? '';
        _aboutBusinessController.text =
            widget.profile.clientInfo?.aboutBusiness ?? '';
        _businessPhoneController.text =
            widget.profile.clientInfo?.businessPhone ?? '';
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _headlineController.dispose();
    _introductionController.dispose();
    _businessNameController.dispose();
    _companyWebsiteController.dispose();
    _aboutBusinessController.dispose();
    _businessPhoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final themeMode = themeState is ThemeLoaded
            ? themeState.mode
            : AppThemeMode.dark;
        final colors = AppTheme.getColors(themeMode);
        final theme = AppTheme.getThemeData(themeMode);

        return Theme(
          data: theme,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.text),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: colors.secondary,
                  unselectedLabelColor: colors.textSecondary,
                  indicatorColor: colors.secondary,
                  tabs: const [
                    Tab(text: 'Profile'),
                    Tab(text: 'Password'),
                  ],
                ),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProfileTab(colors),
                      _buildPasswordTab(colors),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              'First Name',
              _firstNameController,
              colors,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Last Name',
              _lastNameController,
              colors,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Email',
              _emailController,
              colors,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Phone',
              _phoneController,
              colors,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Location',
              _locationController,
              colors,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
            ),
            // Freelancer-specific fields
            if (_isFreelancer()) ...[
              const SizedBox(height: 24),
              Text(
                'Freelancer Details',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Headline', _headlineController, colors),
              const SizedBox(height: 16),
              _buildTextField(
                'Introduction',
                _introductionController,
                colors,
                maxLines: 3,
              ),
            ],
            // Client/Business Owner-specific fields
            if (_isClient()) ...[
              const SizedBox(height: 24),
              Text(
                'Business Details',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Business Name', _businessNameController, colors),
              const SizedBox(height: 16),
              _buildTextField(
                'Company Website',
                _companyWebsiteController,
                colors,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'About Business',
                _aboutBusinessController,
                colors,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Business Phone',
                _businessPhoneController,
                colors,
                keyboardType: TextInputType.phone,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.text),
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Note: Profile update functionality requires backend endpoint. Currently, this is a UI-only implementation.',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTab(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPasswordField(
              'Current Password',
              _currentPasswordController,
              colors,
              _obscureCurrentPassword,
              () => setState(
                () => _obscureCurrentPassword = !_obscureCurrentPassword,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              'New Password',
              _newPasswordController,
              colors,
              _obscureNewPassword,
              () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              'Confirm New Password',
              _confirmPasswordController,
              colors,
              _obscureConfirmPassword,
              () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.text),
                      ),
                    )
                  : Text(
                      'Change Password',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Note: Password change requires backend endpoint. Currently, this is a UI-only implementation.',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    AppColors colors, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    AppColors colors,
    bool obscureText,
    VoidCallback onToggle, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: colors.textSecondary,
              ),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  bool _isFreelancer() {
    final role = widget.profile?.role?.toString().toLowerCase() ?? '';
    return role == 'freelancer' ||
        role == 'creator' ||
        widget.profile?.freelancerInfo != null;
  }

  bool _isClient() {
    final role = widget.profile?.role?.toString().toLowerCase() ?? '';
    return role == 'client' ||
        role == 'business_owner' ||
        widget.profile?.clientInfo != null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final bloc = context.read<DashboardBloc>();
    final userId = widget.profile?.id ?? '';

    try {
      print('==== _saveProfile called ====');
      print('userId: $userId');
      print('isFreelancer: ${_isFreelancer()}');
      print('isClient: ${_isClient()}');
      print('role: ${widget.profile?.role}');

      if (_isFreelancer()) {
        print('Dispatching UpdateFreelancerProfileEvent');
        bloc.add(
          UpdateFreelancerProfileEvent(
            params: UpdateFreelancerParams(
              userId: userId,
              headline: _headlineController.text.isNotEmpty
                  ? _headlineController.text
                  : null,
              introduction: _introductionController.text.isNotEmpty
                  ? _introductionController.text
                  : null,
            ),
          ),
        );
      } else if (_isClient()) {
        print('Dispatching UpdateClientProfileEvent');
        bloc.add(
          UpdateClientProfileEvent(
            params: UpdateClientParams(
              userId: userId,
              businessName: _businessNameController.text.isNotEmpty
                  ? _businessNameController.text
                  : null,
              companyWebsite: _companyWebsiteController.text.isNotEmpty
                  ? _companyWebsiteController.text
                  : null,
              aboutBusiness: _aboutBusinessController.text.isNotEmpty
                  ? _aboutBusinessController.text
                  : null,
              businessPhone: _businessPhoneController.text.isNotEmpty
                  ? _businessPhoneController.text
                  : null,
            ),
          ),
        );
      } else {
        print('ERROR: Neither freelancer nor client!');
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile update request sent'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement backend API call to change password
    // For now, just show success message
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Clear password fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      Navigator.of(context).pop();
    }
  }
}
