import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/authentication/presentation/widgets/social_media_widget.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile_app/features/authentication/presentation/pages/instagram_auth_page.dart';
import 'package:mobile_app/features/authentication/domain/entities/freelancer_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/instagram_profile.dart';
import 'package:mobile_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile_app/core/storage/token_storage.dart';

/// Social media linking page for Content Creators during onboarding.
///
/// This page allows content creators to connect their social media accounts
/// (Instagram, Facebook, TikTok) to showcase their profile metrics to
/// potential business clients.
///
/// This step is only shown for users who select the "Content Creator" role
/// during onboarding. Business owners skip this page entirely.
class ContentCreatorSocialMediaPage extends StatefulWidget {
  final FreelancerSignupEntity? entity;

  const ContentCreatorSocialMediaPage({super.key, this.entity});

  @override
  State<ContentCreatorSocialMediaPage> createState() =>
      _ContentCreatorSocialMediaPageState();
}

class _ContentCreatorSocialMediaPageState
    extends State<ContentCreatorSocialMediaPage> {
  // Track connection status for each platform
  bool _instagramConnected = false;
  InstagramProfile? _instagramProfile;
  final bool _facebookConnected = false;
  final bool _tiktokConnected = false;

  String? _pendingInstagramCode;
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _checkStoredInstagramCode();
  }

  /// Check if there's a stored Instagram code in SharedPreferences
  Future<void> _checkStoredInstagramCode() async {
    final storedCode = await _tokenStorage.getInstagramCode();
    if (storedCode != null && storedCode.isNotEmpty && mounted) {
      setState(() {
        _instagramConnected = true;
        _pendingInstagramCode = storedCode;
      });
    }
  }

  /// Navigate to Instagram OAuth flow and handle the result
  Future<void> _connectInstagram() async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (context) => const InstagramAuthPage()),
    );

    // Check if session was received via deep link
    if (result == 'session_received' && mounted) {
      // Check for session_id in storage
      final sessionId = await _tokenStorage.getInstagramSessionId();
      if (sessionId != null && sessionId.isNotEmpty) {
        // Update UI immediately to show as connected
        setState(() {
          _instagramConnected = true;
        });

        // Only finalize if user is already authenticated
        // Otherwise, session_id will be finalized after signup
        final isAuthenticated = await _tokenStorage.isAuthenticated();
        if (isAuthenticated) {
          context.read<AuthBloc>().add(
            FinalizeInstagramSessionEvent(sessionId: sessionId),
          );
        } else {
          // User not authenticated yet - show success message
          // Session will be finalized after signup
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Instagram authorized successfully! It will be connected after you create your account.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  /// Placeholder for Facebook connection (to be implemented)
  void _connectFacebook() {
    // TODO: Implement Facebook OAuth flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook connection coming soon!')),
    );
  }

  /// Placeholder for TikTok connection (to be implemented)
  void _connectTiktok() {
    // TODO: Implement TikTok OAuth flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TikTok connection coming soon!')),
    );
  }

  /// Navigate to the next step (terms and conditions)
  void _continueToTerms() {
    final entity = widget.entity;

    if (entity != null) {
      // Create a new entity with the Instagram code included
      // We have to recreate it because Entites are immutable usually,
      // but here we can't easily copyWith unless we added it.
      // Assuming we need to construct a new one or the next page handles it.
      // Actually, FreelancerSignupEntity doesn't have copyWith in the snippet I saw.
      // I will construct a new one manually.

      final updatedEntity = FreelancerSignupEntity(
        firstName: entity.firstName,
        lastName: entity.lastName,
        email: entity.email,
        phoneNumber: entity.phoneNumber,
        password: entity.password,
        about: entity.about,
        selectedRole: entity.selectedRole,
        preferredLanguage: entity.preferredLanguage,
        socialMediaLinks: entity.socialMediaLinks,
        specialities: entity.specialities,
        languages: entity.languages,
        instagramAuthCode: _pendingInstagramCode,
      );

      Navigator.pushNamed(
        context,
        '/terms_and_conditions_page',
        arguments: updatedEntity,
      );
    } else {
      // Fallback
      Navigator.pushNamed(
        context,
        '/terms_and_conditions_page',
        arguments: UserRole.contentCreator,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.primary;
    final accent = theme.colorScheme.secondary;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle Instagram connection state changes
        if (state is InstagramConnectedState) {
          setState(() => _instagramConnected = true);
        }
        // Handle Instagram session finalized
        if (state is InstagramSessionFinalizedState) {
          setState(() => _instagramConnected = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Instagram connected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear session_id after successful finalization
          _tokenStorage.clearInstagramSessionId();
        }
        // Handle Instagram session consumed (for profile data)
        if (state is InstagramSessionConsumedState) {
          setState(() {
            _instagramConnected = true;
            _instagramProfile = state.profile;
          });
        }
        // Handle errors
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              // Progress header
              _buildHeader(context, accent),

              // Scrollable content
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
                        // Page title and description
                        _buildTitleSection(context, accent),

                        const SizedBox(height: 28),

                        // Social media connection buttons
                        _buildSocialButtons(context),

                        const SizedBox(height: 24),

                        // Skip info text
                        Text(
                          'You can skip this step and connect your accounts later from your profile settings.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Continue button
                        _buildContinueButton(accent),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.75, // 3/4 of the onboarding
                minHeight: 6,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text('3/4', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, Color accent) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white12,
                child: Center(
                  child: Image.asset(
                    'assets/images/freelancer_icon.png',
                    width: 36,
                    height: 36,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.white54,
                      );
                    },
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
                  child: const Icon(Icons.add, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Link Your Social Accounts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Connect your accounts to automatically import your profile and showcase your key metrics to clients.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButtons(BuildContext context) {
    return Column(
      children: [
        // Instagram
        if (_instagramConnected && _instagramProfile != null)
          _buildInstagramCard(context)
        else
          socialRow(
            context,
            'Instagram',
            Icons.camera_alt,
            connected: _instagramConnected,
            onTap: _connectInstagram,
          ),
        const SizedBox(height: 12),

        // Facebook
        socialRow(
          context,
          'Facebook',
          Icons.facebook,
          connected: _facebookConnected,
          onTap: _facebookConnected ? null : _connectFacebook,
        ),
        const SizedBox(height: 12),

        // TikTok
        socialRow(
          context,
          'TikTok',
          Icons.tiktok,
          connected: _tiktokConnected,
          onTap: _tiktokConnected ? null : _connectTiktok,
        ),
      ],
    );
  }

  Widget _buildContinueButton(Color accent) {
    // Count connected accounts
    final connectedCount = [
      _instagramConnected,
      _facebookConnected,
      _tiktokConnected,
    ].where((c) => c).length;

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _continueToTerms,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          connectedCount > 0
              ? 'Continue ($connectedCount connected)'
              : 'Skip & Continue',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildInstagramCard(BuildContext context) {
    return connectedCard(
      context,
      platform: _instagramProfile?.username ?? 'Instagram',
      icon: Icons.camera_alt,
      followers: '${_instagramProfile?.followersCount ?? 0}',
      likes: '-', // Not available in basic API
      joinedYear: '-', // Not available
    );
  }
}
