import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';

class ConversationParticipant extends Equatable {
  final String id;
  final String name;
  final String? profilePictureUrl;
  final String? username;

  const ConversationParticipant({
    required this.id,
    required this.name,
    this.profilePictureUrl,
    this.username,
  });

  @override
  List<Object?> get props => [id, name, profilePictureUrl, username];
}

class EnrichedConversation extends Equatable {
  final Conversation conversation;
  final ConversationParticipant? otherParticipant;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;

  const EnrichedConversation({
    required this.conversation,
    this.otherParticipant,
    this.lastMessage,
    this.lastMessageTimestamp,
  });

  @override
  List<Object?> get props => [
        conversation,
        otherParticipant,
        lastMessage,
        lastMessageTimestamp,
      ];
}








