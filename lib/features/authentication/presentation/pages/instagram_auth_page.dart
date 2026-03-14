import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/config/instagram_config.dart';
import 'package:mobile_app/core/storage/token_storage.dart';

/// Instagram OAuth authentication page.
///
/// Uses deep linking for seamless OAuth flow:
/// 1. User clicks button to open Instagram authorization in browser
/// 2. User authorizes the app
/// 3. Backend redirects to deep link with session_id
/// 4. App automatically receives session_id and closes this page
class InstagramAuthPage extends StatefulWidget {
  final String clientId;
  final String redirectUri;

  const InstagramAuthPage({
    super.key,
    this.clientId = InstagramConfig.clientId,
    this.redirectUri = InstagramConfig.redirectUri,
  });

  @override
  State<InstagramAuthPage> createState() => _InstagramAuthPageState();
}

class _InstagramAuthPageState extends State<InstagramAuthPage> {
  bool _isLoading = false;
  final TokenStorage _tokenStorage = TokenStorage();
  Timer? _checkSessionTimer;

  /// Constructs the Instagram OAuth URL with proper encoding
  String get _authUrl {
    final params = {
      'client_id': widget.clientId,
      'redirect_uri': widget.redirectUri,
      'scope': InstagramConfig.scopes.join(','),
      'response_type': 'code',
      'state': 'mobile_app_auth',
    };
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '${InstagramConfig.authorizationUrl}?$queryString';
  }

  @override
  void initState() {
    super.initState();
    _startListeningForDeepLink();
  }

  /// Start listening for deep link callback
  void _startListeningForDeepLink() {
    // Check periodically if session_id was received via deep link
    _checkSessionTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      // Check if widget is still mounted before proceeding
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      try {
        final sessionId = await _tokenStorage.getInstagramSessionId();
        if (sessionId != null && sessionId.isNotEmpty && mounted) {
          timer.cancel();
          _handleDeepLinkReceived(sessionId);
        }
      } catch (e) {
        // If there's an error, cancel the timer to prevent infinite retries
        print('Error checking for session_id: $e');
        if (mounted) {
          timer.cancel();
        }
      }
    });
  }

  /// Handle when deep link session_id is received
  void _handleDeepLinkReceived(String sessionId) {
    if (!mounted) return;
    
    // Cancel the timer to prevent multiple calls
    _checkSessionTimer?.cancel();
    
    // Use a post-frame callback to ensure the widget tree is stable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      try {
        // Check if we can pop before attempting
        final navigator = Navigator.of(context, rootNavigator: false);
        if (navigator.canPop()) {
          _showSuccess('Instagram authorization received!');
          // Keep session_id in storage - it will be used by the finalize endpoint
          // The calling code should clear it after finalizing
          navigator.pop('session_received');
        } else {
          // If we can't pop, just show success message
          // The parent widget should handle navigation
          _showSuccess('Instagram authorization received!');
        }
      } catch (e) {
        // If navigation fails, just show success
        // The session_id is already stored
        print('Navigation error (non-critical): $e');
        if (mounted) {
          _showSuccess('Instagram authorization received!');
        }
      }
    });
  }

  @override
  void dispose() {
    _checkSessionTimer?.cancel();
    super.dispose();
  }

  /// Opens Instagram OAuth page in external browser
  Future<void> _launchInstagramAuth() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(_authUrl);

      // Try to launch URL - use platformDefault which works better on mobile
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);

      if (!launched) {
        // If platformDefault fails, try externalApplication
        final launchedExternal = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launchedExternal) {
          _showError('Failed to open browser. Please try again.');
        }
      }
    } catch (e) {
      _showError('Error opening browser: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final accentColor = theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Instagram'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Instagram gradient icon
              Center(child: _buildInstagramIcon()),

              const SizedBox(height: 24),

              const Text(
                'Connect Your Instagram',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Link your Instagram to showcase your profile and metrics to potential clients.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Step 1
              _buildStep(
                context,
                number: '1',
                title: 'Open Instagram Authorization',
                description:
                    'Click the button below to authorize in your browser',
              ),

              const SizedBox(height: 24),

              _buildPrimaryButton(
                onPressed: _isLoading ? null : _launchInstagramAuth,
                isLoading: _isLoading,
                icon: Icons.open_in_new,
                label: 'Open Instagram',
                color: accentColor,
              ),

              const SizedBox(height: 32),

              // Step 2
              _buildStep(
                context,
                number: '2',
                title: 'Authorize the App',
                description:
                    'Login to Instagram and click "Allow" to grant permissions',
              ),

              const SizedBox(height: 32),

              // Step 3
              _buildStep(
                context,
                number: '3',
                title: 'Automatic Connection',
                description:
                    'You will be automatically redirected back to the app',
              ),

              const SizedBox(height: 32),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.9),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keep this page open while you authorize Instagram. You\'ll be automatically redirected back.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Troubleshooting box for "Insufficient Developer Role" error
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade300,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Seeing "Insufficient Developer Role"?',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'If you see this error, the app is in development mode. Ask your administrator to:\n\n'
                      '1. Add your Instagram account as an "Instagram Tester" in Facebook Developer Console\n'
                      '2. Visit instagram.com/accounts/manage_access/ and accept the tester invitation\n'
                      '3. Make sure you\'re logged into Instagram in your browser',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstagramIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFD5949), Color(0xFFD6249F), Color(0xFF285AEB)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD6249F).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
