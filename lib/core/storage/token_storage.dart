import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _freelancerIdKey = 'freelancer_id';
  static const String _clientIdKey = 'client_id';
  static const String _instagramCodeKey = 'instagram_auth_code';
  static const String _instagramSessionIdKey = 'instagram_session_id';
  static const String _rocketChatAuthTokenKey = 'rocketchat_auth_token';
  static const String _rocketChatUserIdKey = 'rocketchat_user_id';

  // Save authentication token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save user role
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  // Get user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Save user ID
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Save freelancer ID
  Future<void> saveFreelancerId(String freelancerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_freelancerIdKey, freelancerId);
  }

  // Get freelancer ID
  Future<String?> getFreelancerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_freelancerIdKey);
  }

  // Save client ID
  Future<void> saveClientId(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientIdKey, clientId);
  }

  // Get client ID
  Future<String?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clientIdKey);
  }

  // Save Instagram authorization code
  Future<void> saveInstagramCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_instagramCodeKey, code);
  }

  // Get Instagram authorization code
  Future<String?> getInstagramCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_instagramCodeKey);
  }

  // Clear Instagram authorization code
  Future<void> clearInstagramCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_instagramCodeKey);
  }

  // Save Instagram session ID (from deep link after OAuth completion)
  Future<void> saveInstagramSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_instagramSessionIdKey, sessionId);
  }

  // Get Instagram session ID
  Future<String?> getInstagramSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_instagramSessionIdKey);
  }

  // Clear Instagram session ID
  Future<void> clearInstagramSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_instagramSessionIdKey);
  }

  // Save RocketChat auth token
  Future<void> saveRocketChatAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rocketChatAuthTokenKey, token);
  }

  // Get RocketChat auth token
  Future<String?> getRocketChatAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rocketChatAuthTokenKey);
  }

  // Save RocketChat user ID
  Future<void> saveRocketChatUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rocketChatUserIdKey, userId);
  }

  // Get RocketChat user ID
  Future<String?> getRocketChatUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rocketChatUserIdKey);
  }

  // Clear RocketChat credentials
  Future<void> clearRocketChatCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rocketChatAuthTokenKey);
    await prefs.remove(_rocketChatUserIdKey);
  }

  // Clear all stored authentication data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_freelancerIdKey);
    await prefs.remove(_clientIdKey);
    await prefs.remove(_instagramCodeKey);
    await prefs.remove(_instagramSessionIdKey);
    await prefs.remove(_rocketChatAuthTokenKey);
    await prefs.remove(_rocketChatUserIdKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
