import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/chat/data/models/rocket_chat_message_model.dart';
import 'package:mobile_app/features/chat/data/services/rocket_chat_websocket_service.dart';
import 'package:mobile_app/features/chat/domain/usecases/create_or_get_conversation.dart';
import 'package:mobile_app/features/chat/domain/usecases/get_user_conversations.dart';
import 'package:mobile_app/features/chat/domain/usecases/initialize_chat_room.dart'
    as usecase;
import 'package:mobile_app/features/chat/domain/usecases/get_rocket_chat_connection_info.dart';
import 'package:mobile_app/features/chat/domain/usecases/login_to_rocket_chat.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:mobile_app/injection_container.dart' as di;

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final CreateOrGetConversation createOrGetConversation;
  final GetUserConversations getUserConversations;
  final usecase.InitializeChatRoom initializeChatRoom;
  final GetRocketChatConnectionInfo getRocketChatConnectionInfo;
  final LoginToRocketChat loginToRocketChat;
  final RocketChatWebSocketService webSocketService;
  final TokenStorage tokenStorage;

  StreamSubscription<RocketChatMessageModel>? _messageSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  final List<RocketChatMessageModel> _messages = [];
  String? _currentUserEmail;
  String? _currentConversationId;

  ChatBloc({
    required this.createOrGetConversation,
    required this.getUserConversations,
    required this.initializeChatRoom,
    required this.getRocketChatConnectionInfo,
    required this.loginToRocketChat,
    required this.webSocketService,
    required this.tokenStorage,
  }) : super(ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<RefreshConversations>(_onRefreshConversations);
    on<StartConversation>(_onStartConversation);
    on<InitializeChatRoomEvent>(_onInitializeChatRoom);
    on<ConnectWebSocket>(_onConnectWebSocket);
    on<DisconnectWebSocket>(_onDisconnectWebSocket);
    on<SendMessage>(_onSendMessage);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<MessageReceivedEvent>(_onMessageReceived);

    // Note: Stream subscriptions are set up when WebSocket connects
    // to ensure the stream controller exists
  }

  void _setupMessageStreamSubscription() {
    // Cancel existing subscription if any
    _messageSubscription?.cancel();

    // Set up new subscription to the message stream
    _messageSubscription = webSocketService.messageStream.listen((message) {
      add(MessageReceivedEvent(message));
    });

  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(ConversationsLoading());

    final result = await getUserConversations(
      userId: event.userId,
      role: event.role,
    );

    result.fold(
      (failure) {
        emit(ConversationsError(failure.message));
      },
      (conversations) {
        emit(ConversationsLoaded(conversations));
      },
    );
  }

  Future<void> _onRefreshConversations(
    RefreshConversations event,
    Emitter<ChatState> emit,
  ) async {
    final result = await getUserConversations(
      userId: event.userId,
      role: event.role,
    );

    result.fold(
      (failure) => emit(ConversationsError(failure.message)),
      (conversations) => emit(ConversationsLoaded(conversations)),
    );
  }

  Future<void> _onStartConversation(
    StartConversation event,
    Emitter<ChatState> emit,
  ) async {
    emit(ConversationStarting());

    final result = await createOrGetConversation(
      clientId: event.clientId,
      freelancerId: event.freelancerId,
      jobId: event.jobId,
      proposalId: event.proposalId,
    );

    result.fold(
      (failure) => emit(ConversationError(failure.message)),
      (conversation) => emit(ConversationStarted(conversation)),
    );
  }

  Future<void> _onInitializeChatRoom(
    InitializeChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(RoomInitializing());

    final result = await initializeChatRoom(event.conversationId);

    result.fold(
      (failure) => emit(RoomError(failure.message)),
      (_) => emit(RoomInitialized(event.conversationId)),
    );
  }

  Future<void> _onConnectWebSocket(
    ConnectWebSocket event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatConnecting());

    try {
      // Store conversation ID and user email for potential re-authentication
      _currentConversationId = event.conversationId;

      // Step 1: Get Rocket.Chat connection info
      final infoResult = await getRocketChatConnectionInfo(
        event.conversationId,
      );
      final info = infoResult.fold(
        (failure) => throw Exception(failure.message),
        (info) => info,
      );

      final roomId = info['room_id'] as String?;
      if (roomId == null) {
        emit(ChatConnectionError('Room ID not found'));
        return;
      }

      // Step 1.5: Check for cached RocketChat credentials
      String? authToken = await tokenStorage.getRocketChatAuthToken();
      String? userId = await tokenStorage.getRocketChatUserId();

      // Step 2: Login to Rocket.Chat if credentials not cached
      if (authToken == null || userId == null) {
        // Get user email if not provided
        String userEmail = event.userEmail;
        if (userEmail.isEmpty) {
          // Fetch user email from profile
          try {
            final apiClient = di.sl<ApiClient>();
            final response = await apiClient.get(
              '/users/profile',
              requireAuth: true,
            );

            if (response.statusCode == 200) {
              final json = jsonDecode(response.body) as Map<String, dynamic>;
              final user = json['user'] as Map<String, dynamic>? ?? json;
              userEmail = user['email'] as String? ?? '';
            }
          } catch (e) {
          }
        }

        if (userEmail.isEmpty) {
          emit(
            ChatConnectionError('User email is required for Rocket.Chat login'),
          );
          return;
        }

        // Store user email for potential re-authentication
        _currentUserEmail = userEmail;

        // Login to Rocket.Chat
        final loginResult = await loginToRocketChat(
          user: userEmail,
          password: 'AnotherStrongPass456!',
        );

        final loginData = loginResult.fold(
          (failure) => throw Exception(failure.message),
          (data) => data,
        );

        authToken = loginData['authToken'] as String?;
        userId = loginData['userId'] as String?;

        if (authToken == null || userId == null) {
          emit(ChatConnectionError('Failed to get authentication tokens'));
          return;
        }

        // Cache the credentials
        await tokenStorage.saveRocketChatAuthToken(authToken);
        await tokenStorage.saveRocketChatUserId(userId);
      } else {
        // Store user email if we have it from the event
        if (event.userEmail.isNotEmpty) {
          _currentUserEmail = event.userEmail;
        }
      }

      await webSocketService.connect(authToken, userId);

      // Set up message stream subscription after connection
      // This ensures the stream controller exists
      _setupMessageStreamSubscription();
      // Step 4: Subscribe to room
      await webSocketService.subscribeToRoom(roomId);
      // Step 5: Load message history
      final loadedMessages = await webSocketService.loadHistory(roomId);
      // Add loaded messages to internal list
      _messages.clear();
      _messages.addAll(loadedMessages);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      emit(ChatConnected(roomId, userId));
      // Emit messages loaded state
      emit(MessagesLoaded(List.from(_messages)));
    } catch (e) {
      // Clear cached credentials on error so we retry login next time
      await tokenStorage.clearRocketChatCredentials();
      emit(ChatConnectionError(e.toString()));
    }
  }

  Future<void> _onDisconnectWebSocket(
    DisconnectWebSocket event,
    Emitter<ChatState> emit,
  ) async {
    await webSocketService.disconnect();
    _messages.clear();
    emit(ChatDisconnected());
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(MessageSending());

    try {
      // Send message and get the actual message object from response
      final sentMessage = await webSocketService.sendMessage(
        event.roomId,
        event.message,
      );

      // Add to internal messages list
      if (!_messages.any((m) => m.id == sentMessage.id)) {
        _messages.add(sentMessage);
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }

      // Emit MessageSent state with the actual message
      emit(MessageSent(sentMessage));

      // Also emit MessagesLoaded to update UI with the new message
      emit(MessagesLoaded(List.from(_messages)));
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();

      // Check if it's an authentication error
      if (errorMessage.contains('not authenticated') ||
          errorMessage.contains('unauthorized') ||
          errorMessage.contains('invalid token') ||
          errorMessage.contains('authentication')) {
        // Clear cached credentials
        await tokenStorage.clearRocketChatCredentials();

        // Try to re-authenticate and reconnect if we have the necessary info
        if (_currentConversationId != null && _currentUserEmail != null) {
          try {
            // Re-login to Rocket.Chat
            final loginResult = await loginToRocketChat(
              user: _currentUserEmail!,
              password: 'AnotherStrongPass456!',
            );

            final loginData = loginResult.fold(
              (failure) => throw Exception(failure.message),
              (data) => data,
            );

            final authToken = loginData['authToken'] as String?;
            final userId = loginData['userId'] as String?;

            if (authToken != null && userId != null) {
              // Cache the new credentials
              await tokenStorage.saveRocketChatAuthToken(authToken);
              await tokenStorage.saveRocketChatUserId(userId);

              // Reconnect WebSocket
              await webSocketService.disconnect();
              await webSocketService.connect(authToken, userId);

              // Re-subscribe to room
              await webSocketService.subscribeToRoom(event.roomId);

              // Retry sending the message
              await webSocketService.sendMessage(event.roomId, event.message);
              return; // Success, don't emit error
            }
          } catch (reAuthError) {
            emit(
              MessageError(
                'Authentication failed. Please try opening the conversation again.',
              ),
            );
            return;
          }
        } else {
          emit(
            MessageError(
              'Authentication failed. Please try opening the conversation again.',
            ),
          );
          return;
        }
      }

      // For other errors, emit the original error
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final loadedMessages = await webSocketService.loadHistory(event.roomId);
      _messages.clear();
      _messages.addAll(loadedMessages);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      emit(MessagesLoaded(List.from(_messages)));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  void _onMessageReceived(MessageReceivedEvent event, Emitter<ChatState> emit) {
    try {
      final message = event.message as RocketChatMessageModel;
      // Check if this message already exists (by ID)
      final existingIndex = _messages.indexWhere((m) => m.id == message.id);

      if (existingIndex != -1) {
        // Message already exists, update it (might be replacing a temp message)
        _messages[existingIndex] = message;
      } else {
        // New message, add it
        _messages.add(message);
      }

      // Sort by timestamp
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Create a new list to ensure state change is detected
      final updatedMessages = List<RocketChatMessageModel>.from(_messages);
      emit(MessagesLoaded(updatedMessages));
    } catch (e) {
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    webSocketService.dispose();
    return super.close();
  }
}
