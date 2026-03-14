import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/features/chat/data/models/rocket_chat_message_model.dart';
import 'package:http/http.dart' as http;

class RocketChatWebSocketService {
  WebSocketChannel? _channel;
  StreamController<RocketChatMessageModel>? _messageController;
  StreamController<bool>? _connectionController;
  bool _isConnected = false;
  String? _authToken;
  String? _userId;
  int _messageId = 0;
  // Map to track pending method calls and their completers
  final Map<String, Completer<Map<String, dynamic>>> _pendingMethods = {};

  Stream<RocketChatMessageModel> get messageStream =>
      _messageController?.stream ?? const Stream.empty();

  Stream<bool> get connectionStream =>
      _connectionController?.stream ?? const Stream.empty();

  bool get isConnected => _isConnected;

  Future<void> connect(String authToken, String userId) async {
    if (_isConnected && _authToken == authToken && _userId == userId) {
      return; // Already connected with same credentials
    }

    _authToken = authToken;
    _userId = userId;
    _messageController ??= StreamController<RocketChatMessageModel>.broadcast();
    _connectionController ??= StreamController<bool>.broadcast();

    try {
      final wsUrl = ApiConfig.rocketChatServerUrl;
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen to incoming messages
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          _isConnected = false;
          _connectionController?.add(false);
        },
        onDone: () {
          _isConnected = false;
          _connectionController?.add(false);
        },
      );

      // Send connect message
      await _sendConnect();

      // Resume session with auth token
      await _resumeSession(authToken, userId);

      _isConnected = true;
      _connectionController?.add(true);
    } catch (e) {
      _isConnected = false;
      _connectionController?.add(false);
      throw Exception('Failed to connect to Rocket.Chat: $e');
    }
  }

  Future<void> _sendConnect() async {
    final message = {
      'msg': 'connect',
      'version': '1',
      'support': ['1'],
    };
    _channel?.sink.add(jsonEncode(message));
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _resumeSession(String authToken, String userId) async {
    final message = {
      'msg': 'method',
      'method': 'login',
      'params': [
        {'resume': authToken},
      ],
      'id': '${++_messageId}',
    };
    _channel?.sink.add(jsonEncode(message));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> subscribeToRoom(String roomId) async {
    if (!_isConnected || _channel == null) {
      throw Exception('Not connected to WebSocket');
    }

    // Subscribe to room messages with useCollection: false (matching webapp)
    final subscribeMessage = {
      'msg': 'sub',
      'name': 'stream-room-messages',
      'params': [
        roomId,
        {'useCollection': false},
      ],
      'id': '${++_messageId}',
    };

    _channel?.sink.add(jsonEncode(subscribeMessage));
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<RocketChatMessageModel> sendMessage(
    String roomId,
    String messageText,
  ) async {
    if (!_isConnected || _authToken == null || _userId == null) {
      throw Exception('Not connected or authenticated');
    }

    if (_channel == null) {
      throw Exception('WebSocket channel is null');
    }

    // Generate unique message ID for this method call
    final methodId = '${++_messageId}';
    final completer = Completer<Map<String, dynamic>>();
    _pendingMethods[methodId] = completer;

    try {
      // Send message via WebSocket using DDP method call
      final message = {
        'msg': 'method',
        'method': 'sendMessage',
        'params': [
          {'rid': roomId, 'msg': messageText},
        ],
        'id': methodId,
      };

      _channel!.sink.add(jsonEncode(message));

      // Wait for response with timeout
      final response = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _pendingMethods.remove(methodId);
          throw Exception('Timeout waiting for message send response');
        },
      );

      // Check if there was an error in the response
      if (response.containsKey('error')) {
        final error = response['error'];
        throw Exception(error['message'] ?? error.toString());
      }

      // Parse the message from the response
      final result = response['result'] as Map<String, dynamic>?;
      if (result == null) {
        throw Exception('No message data in response');
      }

      // Create message model from response
      final sentMessage = RocketChatMessageModel.fromJson(result);

      // Emit the message via stream for immediate real-time update
      // This ensures both sender and receiver see the message immediately
      // The duplicate check in the bloc will prevent adding it twice
      _messageController?.add(sentMessage);

      return sentMessage;
    } catch (e) {
      _pendingMethods.remove(methodId);
      rethrow;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString()) as Map<String, dynamic>;

      // Handle ping with pong response (keep connection alive)
      if (data['msg'] == 'ping') {
        _channel?.sink.add(jsonEncode({'msg': 'pong'}));
        return;
      }

      // Handle connection response
      if (data['msg'] == 'connected') {
        _isConnected = true;
        _connectionController?.add(true);
        return;
      }

      // Handle method response (login result, sendMessage result, etc.)
      if (data['msg'] == 'result' && data['id'] != null) {
        final methodId = data['id'].toString();
        final completer = _pendingMethods[methodId];

        if (completer != null) {
          // Complete the pending method call
          if (data.containsKey('error')) {
            completer.complete({'error': data['error']});
          } else {
            completer.complete(data);
          }
          _pendingMethods.remove(methodId);
        } else {
          // This might be a login result or other method response without a completer
        }
        return;
      }

      // Handle subscription ready
      if (data['msg'] == 'ready') {
        // Subscription is ready
        return;
      }

      // Handle new message - support both 'changed' and 'added' events (matching webapp)
      if ((data['msg'] == 'changed' || data['msg'] == 'added') &&
          data['collection'] == 'stream-room-messages') {
        final fields = data['fields'] as Map<String, dynamic>?;
        if (fields != null && fields['args'] != null) {
          final args = fields['args'] as List<dynamic>?;
          if (args != null && args.isNotEmpty) {
            final messageData = args[0] as Map<String, dynamic>?;
            if (messageData != null) {
              try {
                final rocketMessage = RocketChatMessageModel.fromJson(
                  messageData,
                );
                _messageController?.add(rocketMessage);
              } catch (e) {
                print('ERROR WS: Error parsing message: $e');
              }
            } else {
              print('DEBUG WS: messageData is null');
            }
          } else {
            print('DEBUG WS: args is null or empty');
          }
        } else {
          print('DEBUG WS: fields is null or args not found');
        }
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    await _channel?.sink.close();
    _channel = null;
    _connectionController?.add(false);
  }

  Future<List<RocketChatMessageModel>> loadHistory(
    String roomId, {
    int limit = 50,
  }) async {
    if (!_isConnected || _authToken == null || _userId == null) {
      throw Exception('Not connected or authenticated');
    }

    // Use stored server URL or fallback to default
    final apiUrl = ApiConfig.rocketChatApiUrl;

    // Use im.messages endpoint like the web app
    final url = Uri.parse('$apiUrl/im.messages?roomId=$roomId&count=$limit');
    final response = await http.get(
      url,
      headers: {'X-Auth-Token': _authToken!, 'X-User-Id': _userId!},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final messages = data['messages'] as List<dynamic>? ?? [];
      final loadedMessages = <RocketChatMessageModel>[];

      // Reverse to show oldest first (like web app)
      final reversedMessages = messages.reversed.toList();

      for (var msgData in reversedMessages) {
        try {
          final rocketMessage = RocketChatMessageModel.fromJson(
            msgData as Map<String, dynamic>,
          );
          loadedMessages.add(rocketMessage);
          // Also add to stream for real-time updates
          _messageController?.add(rocketMessage);
        } catch (e) {
          print('Error parsing history message: $e');
        }
      }

      return loadedMessages;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to load messages');
    }
  }

  void dispose() {
    disconnect();
    // Complete all pending methods with errors
    for (final completer in _pendingMethods.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Service disposed'));
      }
    }
    _pendingMethods.clear();
    _messageController?.close();
    _connectionController?.close();
    _messageController = null;
    _connectionController = null;
  }
}
