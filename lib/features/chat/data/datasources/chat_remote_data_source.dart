import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/chat/data/models/conversation_model.dart';

abstract class ChatRemoteDataSource {
  Future<ConversationModel> createOrGetConversation({
    required String clientId,
    required String freelancerId,
    String? jobId,
    String? proposalId,
  });

  Future<void> createRoom(String conversationId);

  Future<Map<String, dynamic>> getRocketChatInfo(String conversationId);

  Future<Map<String, dynamic>> loginToRocketChat(
    String userEmail,
    String password,
  );

  Future<List<ConversationModel>> getUserConversations(
    String userId,
    String role,
  );

  Future<Map<String, dynamic>> getUserProfile(String userId);

  Future<Map<String, dynamic>> getParticipantProfile(String userId);

  Future<String?> getLastMessage(
    String roomId,
    String authToken,
    String rocketChatUserId,
  );
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  ChatRemoteDataSourceImpl({required this.client, required this.tokenStorage});

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  @override
  Future<ConversationModel> createOrGetConversation({
    required String clientId,
    required String freelancerId,
    String? jobId,
    String? proposalId,
  }) async {
    final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.conversationsEndpoint));
    final headers = await _getHeaders();

    final body = <String, dynamic>{
      'client_id': clientId,
      'freelancer_id': freelancerId,
    };

    print("--------------------client Id: $clientId");
    print("--------------------freelancer Id: $freelancerId");
    if (jobId != null) {
      body['job_id'] = jobId;
    }
    if (proposalId != null) {
      body['proposal_id'] = proposalId;
    }

    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print("--------------------response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final conversationData =
          data['conversation'] as Map<String, dynamic>? ?? data;
      return ConversationModel.fromJson(conversationData);
    } else {
      String errorMessage = 'Failed to create conversation';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<void> createRoom(String conversationId) async {
    final endpoint = ApiConfig.createRoomEndpoint.replaceAll(
      ':id',
      conversationId,
    );
    final url = Uri.parse(ApiConfig.buildUrl(endpoint));
    final headers = await _getHeaders();

    final response = await client.post(url, headers: headers);

    print("--------------------response2: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to create room';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<Map<String, dynamic>> getRocketChatInfo(String conversationId) async {
    final endpoint = ApiConfig.rocketChatInfoEndpoint.replaceAll(
      ':id',
      conversationId,
    );
    final url = Uri.parse(ApiConfig.buildUrl(endpoint));
    final headers = await _getHeaders();

    final response = await client.get(url, headers: headers);

    print("--------------------response3: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['rocket_chat_info'] as Map<String, dynamic>? ?? {};
    } else {
      throw ServerException(message: 'Failed to get Rocket.Chat info');
    }
  }

  @override
  Future<Map<String, dynamic>> loginToRocketChat(
    String userEmail,
    String password,
  ) async {
    // Login to Rocket.Chat via backend proxy
    final url = Uri.parse(
      ApiConfig.buildUrl(ApiConfig.rocketChatLoginEndpoint),
    );
    final headers = <String, String>{'Content-Type': 'application/json'};

    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode({'user': userEmail, 'password': password}),
    );

    print("--------------------response4: ${response.body}");

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw ServerException(message: 'Empty response from Rocket.Chat login');
      }
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>? ?? {};
      } catch (e) {
        throw ServerException(
          message:
              'Failed to parse Rocket.Chat login response: ${e.toString()}',
        );
      }
    } else {
      String errorMessage = 'Failed to login to Rocket.Chat';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['error'] != null) {
          errorMessage = errorData['error'] as String;
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<List<ConversationModel>> getUserConversations(
    String userId,
    String role,
  ) async {
    final endpoint = ApiConfig.userConversationsEndpoint.replaceAll(
      ':userId',
      userId,
    );
    final url = Uri.parse(ApiConfig.buildUrl('$endpoint?role=$role'));
    final headers = await _getHeaders();

    final response = await client.get(url, headers: headers);

    print("--------------------response5: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final conversationsList = data['conversations'] as List<dynamic>? ?? [];
      return conversationsList
          .map(
            (json) => ConversationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw ServerException(message: 'Failed to load conversations');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final headers = await _getHeaders();
    final url = Uri.parse(
      ApiConfig.buildUrl('${ApiConfig.userProfileEndpoint}/$userId'),
    );

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ServerException(message: 'Failed to load user profile');
    }
  }

  @override
  Future<Map<String, dynamic>> getParticipantProfile(String userId) async {
    final headers = await _getHeaders();
    final url = Uri.parse(
      ApiConfig.buildUrl('${ApiConfig.userProfileEndpoint}/$userId'),
    );

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ServerException(message: 'Failed to load participant profile');
    }
  }

  @override
  Future<String?> getLastMessage(
    String roomId,
    String authToken,
    String rocketChatUserId,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.rocketChatApiUrl}/im.messages?roomId=$roomId&count=1',
      );
      final response = await client.get(
        url,
        headers: {'X-Auth-Token': authToken, 'X-User-Id': rocketChatUserId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final messages = data['messages'] as List<dynamic>? ?? [];
        if (messages.isNotEmpty) {
          final lastMsg = messages[0] as Map<String, dynamic>;
          return lastMsg['msg'] as String?;
        }
      }
      return null;
    } catch (e) {
      // Silently fail - last message is optional
      return null;
    }
  }
}
