import 'package:flutter/material.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';

class FreelancerOnboardingPage1 extends StatefulWidget {
  const FreelancerOnboardingPage1({super.key, this.selectedRole});

  final UserRole? selectedRole;

  @override
  State<FreelancerOnboardingPage1> createState() =>
      _FreelancerOnboardingPage1State();
}

class _FreelancerOnboardingPage1State extends State<FreelancerOnboardingPage1> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _about = TextEditingController();
  final _instagram = TextEditingController();
  final _tiktok = TextEditingController();
  final _facebook = TextEditingController();
  final _twitter = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String _language = 'English';

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _mobile.dispose();
    _about.dispose();
    _instagram.dispose();
    _tiktok.dispose();
    _facebook.dispose();
    _twitter.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.primaryColor;
    final accent = theme.colorScheme.secondary;

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
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.25,
                        minHeight: 6,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('1/4', style: TextStyle(color: Colors.white70)),
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
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 6),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Colors.white12,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/freelancer_icon.png',
                                      width: 36,
                                      height: 36,
                                    ),
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
                                    child: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Welcome, ${_getRoleName(widget.selectedRole)}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tell us about you. Give brands a good idea of who you are.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Name row
                      const Text(
                        'Name',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _field(controller: _firstName, hint: 'john'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(controller: _lastName, hint: 'doe'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Email',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      _field(
                        controller: _email,
                        hint: 'example@company.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Mobile',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      _field(
                        controller: _mobile,
                        hint: '+56xxxxxxx',
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        'Password',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Create a strong password',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        'Confirm Password',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPassword,
                        obscureText: _obscureConfirm,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Re-enter your password',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        'About me',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _about,
                        maxLines: 5,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText:
                              'Describe your expertise, years of experience, and passion for your work.',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _language,
                        dropdownColor: background,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'English',
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'Spanish',
                            child: Text('Spanish'),
                          ),
                          DropdownMenuItem(
                            value: 'Portuguese',
                            child: Text('Portuguese'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _language = v ?? _language),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        'Social Media Link (optional)',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      _field(controller: _instagram, hint: 'Instagram URL'),
                      const SizedBox(height: 8),
                      _field(controller: _tiktok, hint: 'Tiktok URL'),
                      const SizedBox(height: 8),
                      _field(controller: _facebook, hint: 'Facebook'),
                      const SizedBox(height: 8),
                      _field(controller: _twitter, hint: 'Twitter(X)'),

                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Basic validation
                            if (_firstName.text.isEmpty ||
                                _lastName.text.isEmpty ||
                                _email.text.isEmpty ||
                                _mobile.text.isEmpty ||
                                _password.text.isEmpty ||
                                _confirmPassword.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill in all required fields',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (_password.text != _confirmPassword.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Create partial entity or pass arguments to next page
                            // Since entity is complete, we'll pass the collected data to the next page
                            // to be combined with skills/languages.

                            final partialData = {
                              'firstName': _firstName.text,
                              'lastName': _lastName.text,
                              'email': _email.text,
                              'phoneNumber': _mobile.text,
                              'password': _password.text,
                              'about': _about.text,
                              'selectedRole': widget.selectedRole,
                              'preferredLanguage': _language,
                              'socialMediaLinks': [
                                if (_instagram.text.isNotEmpty) _instagram.text,
                                if (_tiktok.text.isNotEmpty) _tiktok.text,
                                if (_facebook.text.isNotEmpty) _facebook.text,
                                if (_twitter.text.isNotEmpty) _twitter.text,
                              ],
                            };

                            Navigator.pushNamed(
                              context,
                              '/freelancer_onboarding_page_2',
                              arguments: partialData,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue',
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

  Widget _field({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  String _getRoleName(UserRole? role) {
    if (role == null) return 'Freelancer';
    switch (role) {
      case UserRole.contentCreator:
        return 'Content Creator';
      case UserRole.creative:
        return 'Creative Professional';
      default:
        return 'Creative';
    }
  }
}
