import 'package:flutter/material.dart';
import '../../domain/entities/business_sign_up_entity.dart';

class BusinessOwnerOnboardingPage2 extends StatefulWidget {
  final BusinessSignupEntity businessSignUpEntity;

  const BusinessOwnerOnboardingPage2({
    super.key,
    required this.businessSignUpEntity,
  });

  @override
  State<BusinessOwnerOnboardingPage2> createState() =>
      _BusinessOwnerOnboardingPage2State();
}

class _BusinessOwnerOnboardingPage2State
    extends State<BusinessOwnerOnboardingPage2> {
  final List<String> _services = [
    'Graphic Design',
    'Social media photos',
    'social media videos',
    'Photography',
    'Videography',
    'social media mentions',
    'long social media campaign',
    'short social media campaign',
    'interior design',
    'branding',
    'logo design',
    'menu design',
    'website design',
    'social media content',
  ];

  final Set<String> _selected = {};

  void _toggle(String service) {
    setState(() {
      if (_selected.contains(service)) {
        _selected.remove(service);
      } else {
        _selected.add(service);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primary;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText = theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with back + progress
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
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 2 / 3,
                        minHeight: 6,
                        backgroundColor: cardColor,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('2/3', style: TextStyle(color: subtleText)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Avatar + title
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white12,
                        child: Icon(Icons.work, color: accent, size: 32),
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
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Text(
                      'Choose the services you are seeking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: Text(
                      'This helps us match you with relevant marketing campaigns and opportunities.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subtleText),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Chips list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: _services.map((s) {
                    final bool sel = _selected.contains(s);
                    return GestureDetector(
                      onTap: () => _toggle(s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? accent : cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? accent : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            color: sel ? textColor : subtleText,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/terms_and_conditions_page',
                      arguments: BusinessSignupEntity(
                        firstName: widget.businessSignUpEntity.firstName,
                        lastName: widget.businessSignUpEntity.lastName,
                        businessName: widget.businessSignUpEntity.businessName,
                        businessEmail:
                            widget.businessSignUpEntity.businessEmail,
                        businessPhone:
                            widget.businessSignUpEntity.businessPhone,
                        businessDescription:
                            widget.businessSignUpEntity.businessDescription,
                        companyWebsite:
                            widget.businessSignUpEntity.companyWebsite,
                        preferredLanguage:
                            widget.businessSignUpEntity.preferredLanguage,
                        socialMediaLinks:
                            widget.businessSignUpEntity.socialMediaLinks,
                        password: widget.businessSignUpEntity.password,
                        phoneNumber: widget.businessSignUpEntity.phoneNumber,
                        selectedRole: widget.businessSignUpEntity.selectedRole,
                        servicesRequired: _selected.toList(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
