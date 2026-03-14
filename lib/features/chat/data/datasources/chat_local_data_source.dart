import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/features/chat/data/models/conversation_model.dart';

abstract class ChatLocalDataSource {
  Future<List<ConversationModel>> getCachedConversations(String userId, String role);
  Future<void> cacheConversations(String userId, String role, List<ConversationModel> conversations);
  Future<void> clearCache();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  static const String _conversationsPrefix = 'cached_conversations_';

  String _getCacheKey(String userId, String role) {
    return '$_conversationsPrefix${userId}_$role';
  }

  @override
  Future<List<ConversationModel>> getCachedConversations(
    String userId,
    String role,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(userId, role);
      final cachedJson = prefs.getString(cacheKey);
      
      if (cachedJson == null || cachedJson.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(cachedJson);
      return jsonList
          .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheConversations(
    String userId,
    String role,
    List<ConversationModel> conversations,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(userId, role);
      final jsonList = conversations.map((conv) => conv.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(jsonList));
    } catch (e) {
      // Silently fail caching
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_conversationsPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Silently fail
    }
  }
}








