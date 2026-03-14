import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';
import 'package:mobile_app/features/chat/data/models/rocket_chat_message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {}

/// Loading conversations
class ConversationsLoading extends ChatState {}

/// Conversations loaded successfully
class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

/// Error loading conversations
class ConversationsError extends ChatState {
  final String message;

  const ConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Starting conversation
class ConversationStarting extends ChatState {}

/// Conversation started/retrieved
class ConversationStarted extends ChatState {
  final Conversation conversation;

  const ConversationStarted(this.conversation);

  @override
  List<Object?> get props => [conversation];
}

/// Error starting conversation
class ConversationError extends ChatState {
  final String message;

  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Initializing chat room
class RoomInitializing extends ChatState {}

/// Room initialized
class RoomInitialized extends ChatState {
  final String conversationId;

  const RoomInitialized(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Error initializing room
class RoomError extends ChatState {
  final String message;

  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Connecting to WebSocket
class ChatConnecting extends ChatState {}

/// Connected to WebSocket
class ChatConnected extends ChatState {
  final String roomId;
  final String userId;

  const ChatConnected(this.roomId, this.userId);

  @override
  List<Object?> get props => [roomId, userId];
}

/// Disconnected from WebSocket
class ChatDisconnected extends ChatState {}

/// Error connecting to WebSocket
class ChatConnectionError extends ChatState {
  final String message;

  const ChatConnectionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Messages loaded
class MessagesLoaded extends ChatState {
  final List<RocketChatMessageModel> messages;

  MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Sending message
class MessageSending extends ChatState {}

/// Message sent successfully
class MessageSent extends ChatState {
  final RocketChatMessageModel message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error sending message
class MessageError extends ChatState {
  final String message;

  const MessageError(this.message);

  @override
  List<Object?> get props => [message];
}

/// New message received via WebSocket
class MessageReceived extends ChatState {
  final RocketChatMessageModel message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
