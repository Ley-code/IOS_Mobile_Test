import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:mobile_app/core/storage/token_storage.dart';

/// Service to handle deep links for Instagram OAuth callback
/// 
/// Listens for incoming deep links with scheme: vyrlapp://instagram/callback?session_id=XXX
/// Extracts session_id and stores it in SharedPreferences
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  final TokenStorage _tokenStorage = TokenStorage();
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<Uri>? _initialLinkSubscription;

  bool _isInitialized = false;

  /// Initialize deep link listening
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Handle deep link when app is opened from terminated state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }

    // Listen for deep links when app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Error listening to deep links: $err');
      },
    );
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    // Check if this is an Instagram callback
    if (uri.scheme == 'vyrlapp' && uri.host == 'instagram') {
      final sessionId = uri.queryParameters['session_id'];
      if (sessionId != null && sessionId.isNotEmpty) {
        _tokenStorage.saveInstagramSessionId(sessionId);
        print('Instagram session_id stored: $sessionId');
      } else {
        print('Warning: Deep link received but no session_id found');
      }
    }
  }

  /// Dispose and clean up listeners
  void dispose() {
    _linkSubscription?.cancel();
    _initialLinkSubscription?.cancel();
    _isInitialized = false;
  }
}













