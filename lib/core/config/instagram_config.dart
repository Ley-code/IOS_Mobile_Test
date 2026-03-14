/// Instagram OAuth configuration for the Vyrl mobile app.
///
/// This configuration uses the **Instagram Business API** (Graph API),
/// which is for business and creator accounts.
///
/// ## Important Notes
/// - This uses the same credentials as the web app
/// - The auth URL is www.instagram.com (not api.instagram.com)
/// - Scopes are for business accounts (instagram_business_*)
///
/// ## Troubleshooting "Insufficient Developer Role" Error
/// If you see "insufficient developer role" when redirecting to Instagram OAuth:
/// 1. Go to Facebook Developer Console → Your App → Roles → Instagram Testers
/// 2. Add your Instagram account as an "Instagram Tester"
/// 3. Visit https://www.instagram.com/accounts/manage_access/
/// 4. Go to "Tester Invites" tab and click "Authorize" to accept the invitation
/// 5. Make sure you're logged into Instagram with the same account in your browser
/// 6. If the app is in Development mode, all users must be added as testers
class InstagramConfig {
  InstagramConfig._(); // Private constructor

  /// Instagram App Client ID from Facebook Developer Console
  static const String clientId = '772563655395430';

  /// Instagram App Client Secret
  /// ⚠️ WARNING: Should only be used server-side in production
  static const String clientSecret = 'cf489abb620726129e0131219a2f08b4';

  /// OAuth Redirect URI - must match Facebook Developer Console exactly
  /// This is the backend GET endpoint that will redirect to deep link
  /// IMPORTANT: Must match exactly what's configured in Facebook Developer Console
  static const String redirectUri =
      'https://vyrl.space/instagram/mobile-callback';

  /// Deep link scheme for mobile app callback
  static const String deepLinkScheme = 'vyrlapp://instagram/callback';

  /// Instagram Business API Authorization URL
  /// Note: This is different from Basic Display API which uses api.instagram.com
  static const String authorizationUrl =
      'https://www.instagram.com/oauth/authorize';

  /// Instagram OAuth Token Exchange URL
  static const String tokenUrl = 'https://api.instagram.com/oauth/access_token';

  /// Instagram Graph API Base URL
  static const String graphApiUrl = 'https://graph.instagram.com';

  /// Requested OAuth scopes for Instagram Business API
  ///
  /// - `instagram_business_basic`: Access to business account info
  /// - `instagram_business_manage_insights`: Access to insights/metrics
  static const List<String> scopes = [
    'instagram_business_basic',
    'instagram_business_manage_insights',
  ];

  /// State parameter for CSRF protection
  static const String stateParameter = 'mobile_app_auth';

  /// Constructs the full authorization URL with all parameters
  static String buildAuthUrl({String? customState}) {
    final params = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(','),
      'response_type': 'code',
      'state': customState ?? stateParameter,
    };
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$authorizationUrl?$queryString';
  }
}
