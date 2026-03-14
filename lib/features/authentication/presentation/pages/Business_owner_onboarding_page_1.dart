import 'package:flutter/material.dart';
import 'package:mobile_app/features/authentication/domain/entities/business_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';

class BusinessOwnerOnboardingPage1 extends StatefulWidget {
  const BusinessOwnerOnboardingPage1({super.key});

  @override
  State<BusinessOwnerOnboardingPage1> createState() =>
      _BusinessOwnerOnboardingPage1State();
}

class _BusinessOwnerOnboardingPage1State
    extends State<BusinessOwnerOnboardingPage1> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _businessController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final bool _pushNotifications = false;
  final bool _newsletter = false;
  String _language = 'English';
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  // Validation errors
  String? _firstNameError;
  String? _lastNameError;
  String? _businessError;
  String? _emailError;
  String? _telephoneError;
  String? _mobileError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _descriptionError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _mobileController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, size: 22, color: textColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.33,
                        minHeight: 6,
                        backgroundColor: cardColor,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('1/3', style: TextStyle(color: subtleText)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Colors.white12,
                                  child: Icon(
                                    Icons.business,
                                    color: accent,
                                    size: 28,
                                  ),
                                ),
                                Positioned(
                                  right: -4,
                                  bottom: -4,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Welcome, Business Owner!',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Let\'s set up your company profile to attract the best talent',
                              style: TextStyle(color: subtleText),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      _label('First Name', subtleText),
                      _field(
                        controller: _firstNameController,
                        hint: 'Enter your first name',
                        errorText: _firstNameError,
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 10),

                      _label('Last Name', subtleText),
                      _field(
                        controller: _lastNameController,
                        hint: 'Enter your last name',
                        errorText: _lastNameError,
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 10),

                      _label('Business Name', subtleText),
                      _field(
                        controller: _businessController,
                        hint: 'Enter your business name',
                        errorText: _businessError,
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 10),

                      _label('Business Email', subtleText),
                      _field(
                        controller: _emailController,
                        hint: 'example@company.com',
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 10),

                      _label('Business Telephone', subtleText),
                      _field(
                        controller: _telephoneController,
                        hint: '(123) 456-7890',
                        keyboardType: TextInputType.phone,
                        errorText: _telephoneError,
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 10),

                      _label('Mobile Number', subtleText),
                      _field(
                        controller: _mobileController,
                        hint: '+57 437xxxx',
                        keyboardType: TextInputType.phone,
                        errorText: _mobileError,
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),

                      const SizedBox(height: 10),
                      _label('Create Password', subtleText),
                      _field(
                        controller: _passwordController,
                        hint: 'Create a strong password',
                        obscureText: _hidePassword,
                        enableVisibilityToggle: true,
                        errorText: _passwordError,
                        onVisibilityToggle: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 10),
                      _label('Confirm Password', subtleText),
                      _field(
                        controller: _confirmPasswordController,
                        hint: 'Re-enter your password',
                        obscureText: _hideConfirmPassword,
                        enableVisibilityToggle: true,
                        errorText: _confirmPasswordError,
                        onVisibilityToggle: () => setState(
                          () => _hideConfirmPassword = !_hideConfirmPassword,
                        ),
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 12),
                      _label('Business Description', subtleText),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'What does your company do?',
                              hintStyle: TextStyle(
                                color: subtleText.withOpacity(0.6),
                              ),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                          if (_descriptionError != null) ...[
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                _descriptionError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 10),
                      _label('Company Website (optional)', subtleText),
                      _field(
                        controller: _websiteController,
                        hint: 'https://www.yourcompany.com',
                        keyboardType: TextInputType.url,
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),

                      const SizedBox(height: 12),
                      _label('Preferred Language', subtleText),
                      DropdownButtonFormField<String>(
                        initialValue: _language,
                        dropdownColor: background,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'English',
                            child: Text(
                              'English',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Spanish',
                            child: Text(
                              'Spanish',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'French',
                            child: Text(
                              'French',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _language = v ?? _language),
                      ),

                      const SizedBox(height: 12),
                      _label('Social Media Link (optional)', subtleText),
                      _field(
                        controller: TextEditingController(),
                        hint: 'Instagram URL',
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 8),
                      _field(
                        controller: TextEditingController(),
                        hint: 'Tiktok URL',
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 8),
                      _field(
                        controller: TextEditingController(),
                        hint: 'Facebook',
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 8),
                      _field(
                        controller: TextEditingController(),
                        hint: 'Twitter(X)',
                        textColor: textColor,
                        subtleText: subtleText,
                        cardColor: cardColor,
                      ),

                      const SizedBox(height: 18),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Clear previous errors
                            setState(() {
                              _firstNameError = null;
                              _lastNameError = null;
                              _businessError = null;
                              _emailError = null;
                              _telephoneError = null;
                              _mobileError = null;
                              _passwordError = null;
                              _confirmPasswordError = null;
                              _descriptionError = null;
                            });

                            // Validate all fields
                            bool isValid = true;
                            final firstName = _firstNameController.text.trim();
                            final lastName = _lastNameController.text.trim();
                            final business = _businessController.text.trim();
                            final email = _emailController.text.trim();
                            final telephone = _telephoneController.text.trim();
                            final mobile = _mobileController.text.trim();
                            final password = _passwordController.text.trim();
                            final confirm = _confirmPasswordController.text
                                .trim();
                            final description = _descriptionController.text
                                .trim();

                            if (firstName.isEmpty) {
                              setState(
                                () =>
                                    _firstNameError = 'First name is required',
                              );
                              isValid = false;
                            }

                            if (lastName.isEmpty) {
                              setState(
                                () => _lastNameError = 'Last name is required',
                              );
                              isValid = false;
                            }

                            if (business.isEmpty) {
                              setState(
                                () => _businessError =
                                    'Business name is required',
                              );
                              isValid = false;
                            }

                            if (email.isEmpty) {
                              setState(() => _emailError = 'Email is required');
                              isValid = false;
                            } else if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(email)) {
                              setState(
                                () => _emailError =
                                    'Please enter a valid email address',
                              );
                              isValid = false;
                            }

                            if (telephone.isEmpty) {
                              setState(
                                () => _telephoneError = 'Telephone is required',
                              );
                              isValid = false;
                            }

                            if (mobile.isEmpty) {
                              setState(
                                () =>
                                    _mobileError = 'Mobile number is required',
                              );
                              isValid = false;
                            }

                            if (password.isEmpty) {
                              setState(
                                () => _passwordError = 'Password is required',
                              );
                              isValid = false;
                            } else if (password.length < 8) {
                              setState(
                                () => _passwordError =
                                    'Password must be at least 8 characters',
                              );
                              isValid = false;
                            }

                            if (confirm.isEmpty) {
                              setState(
                                () => _confirmPasswordError =
                                    'Please confirm your password',
                              );
                              isValid = false;
                            } else if (password != confirm) {
                              setState(
                                () => _confirmPasswordError =
                                    'Passwords do not match',
                              );
                              isValid = false;
                            }

                            if (description.isEmpty) {
                              setState(
                                () => _descriptionError =
                                    'Business description is required',
                              );
                              isValid = false;
                            }

                            if (!isValid) {
                              return;
                            }

                            // Store validated password back into the controller
                            _passwordController.text = password;

                            final website = _websiteController.text.trim();

                            Navigator.pushNamed(
                              context,
                              '/business_owner_onboarding_page_2',
                              arguments: BusinessSignupEntity(
                                firstName: firstName,
                                lastName: lastName,
                                businessName: business,
                                businessEmail: email,
                                businessPhone: telephone,
                                businessDescription: description,
                                companyWebsite: website.isEmpty
                                    ? null
                                    : website,
                                preferredLanguage: _language,
                                socialMediaLinks: null,
                                password: password,
                                phoneNumber: mobile,
                                selectedRole: UserRole.businessOwner,
                                servicesRequired: const [],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, Color subtleText) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 4),
    child: Text(text, style: TextStyle(color: subtleText)),
  );

  Widget _field({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enableVisibilityToggle = false,
    String? errorText,
    VoidCallback? onVisibilityToggle,
    required Color textColor,
    required Color subtleText,
    required Color cardColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: subtleText.withOpacity(0.6)),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            suffixIcon: enableVisibilityToggle
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: subtleText,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
