import 'package:flutter/material.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart'
    as domain;
import '../widgets/role_card_widget.dart';

enum UserRole {
  businessOwner,
  contentCreator,
  photographer,
  videographer,
  designer,
}

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({super.key});

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  UserRole _selected = UserRole.businessOwner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg = theme.primaryColor;
    final Color accent = theme.colorScheme.secondary; // CTA and selected border
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // Top icon
            SizedBox(
              width: 56,
              height: 56,
              child: Image.asset(
                'assets/images/networking.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'What kind of account\nwould you like to create',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    RoleCard(
                      title: 'Business Owner',
                      subtitle:
                          'Find the perfect talent for your\nmarketing campaigns',
                      selected: _selected == UserRole.businessOwner,
                      accent: accent,
                      onTap: () =>
                          setState(() => _selected = UserRole.businessOwner),
                      icon: Icons.badge_outlined,
                    ),

                    const SizedBox(height: 16),

                    RoleCard(
                      title: 'Content Creator',
                      subtitle:
                          'Monetize your influence and\ncollaborate with brands.',
                      selected: _selected == UserRole.contentCreator,
                      accent: accent,
                      onTap: () =>
                          setState(() => _selected = UserRole.contentCreator),
                      icon: Icons.verified_user_outlined,
                    ),

                    const SizedBox(height: 16),

                    RoleCard(
                      title: 'Photographer',
                      subtitle:
                          'Show case your work and get\nhired for your creative works.',
                      selected: _selected == UserRole.photographer,
                      accent: accent,
                      onTap: () =>
                          setState(() => _selected = UserRole.photographer),
                      icon: Icons.camera_alt_outlined,
                    ),
                    const SizedBox(height: 16),
                    RoleCard(
                      title: 'Videographer',
                      subtitle:
                          'Show case your work and get\nhired for your creative works.',
                      selected: _selected == UserRole.videographer,
                      accent: accent,
                      onTap: () =>
                          setState(() => _selected = UserRole.videographer),
                      icon: Icons.videocam_outlined,
                    ),
                    const SizedBox(height: 16),
                    RoleCard(
                      title: 'Designer',
                      subtitle:
                          'Show case your work and get\nhired for your creative works.',
                      selected: _selected == UserRole.designer,
                      accent: accent,
                      onTap: () =>
                          setState(() => _selected = UserRole.designer),
                      icon: Icons.design_services_outlined,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_selected == UserRole.businessOwner) {
                      // Navigate to business owner registration page
                      Navigator.pushNamed(
                        context,
                        '/business_owner_onboarding_page_1',
                      );
                    } else {
                      // Map local UI role to domain UserRole
                      domain.UserRole domainRole;
                      if (_selected == UserRole.contentCreator) {
                        domainRole = domain.UserRole.contentCreator;
                      } else {
                        // Photographer, Videographer, Designer -> Creative
                        domainRole = domain.UserRole.creative;
                      }

                      // Navigate to registration and pass the domain role
                      Navigator.pushNamed(
                        context,
                        '/freelancer_onboarding_page_1',
                        arguments: domainRole,
                      );
                    }
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: subtleText),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                    ),
                    //TODO: Update navigation
                    onPressed: () => {},
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login_page');
                      },
                      child: Text(
                        'Log In.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
