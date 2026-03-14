import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Load conversations for the current user
class LoadConversations extends ChatEvent {
  final String userId;
  final String role;

  const LoadConversations({
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, role];
}

/// Start a new conversation or get existing one
class StartConversation extends ChatEvent {
  final String clientId;
  final String freelancerId;
  final String? jobId;
  final String? proposalId;

  const StartConversation({
    required this.clientId,
    required this.freelancerId,
    this.jobId,
    this.proposalId,
  });

  @override
  List<Object?> get props => [clientId, freelancerId, jobId, proposalId];
}

/// Initialize chat room for a conversation
class InitializeChatRoomEvent extends ChatEvent {
  final String conversationId;

  const InitializeChatRoomEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Connect to Rocket.Chat WebSocket
class ConnectWebSocket extends ChatEvent {
  final String conversationId;
  final String userEmail;

  const ConnectWebSocket({
    required this.conversationId,
    required this.userEmail,
  });

  @override
  List<Object?> get props => [conversationId, userEmail];
}

/// Disconnect from WebSocket
class DisconnectWebSocket extends ChatEvent {
  const DisconnectWebSocket();
}

/// Send a message
class SendMessage extends ChatEvent {
  final String roomId;
  final String message;

  const SendMessage({
    required this.roomId,
    required this.message,
  });

  @override
  List<Object?> get props => [roomId, message];
}

/// Load chat messages history
class LoadChatMessages extends ChatEvent {
  final String roomId;

  const LoadChatMessages(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// New message received via WebSocket
class MessageReceivedEvent extends ChatEvent {
  final dynamic message;

  const MessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Refresh conversations list
class RefreshConversations extends ChatEvent {
  final String userId;
  final String role;

  const RefreshConversations({
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, role];
}

