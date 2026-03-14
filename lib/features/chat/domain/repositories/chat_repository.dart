import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';
import 'package:mobile_app/features/chat/domain/entities/participant_profile.dart';

abstract class ChatRepository {
  Future<Either<Failure, Conversation>> createOrGetConversation({
    required String clientId,
    required String freelancerId,
    String? jobId,
    String? proposalId,
  });

  Future<Either<Failure, void>> createRoom(String conversationId);

  Future<Either<Failure, Map<String, dynamic>>> getRocketChatInfo(
    String conversationId,
  );

  Future<Either<Failure, Map<String, dynamic>>> loginToRocketChat(
    String user,
    String password,
  );

  Future<Either<Failure, List<Conversation>>> getUserConversations(
    String userId,
    String role,
  );

  Future<Either<Failure, ParticipantProfile>> getParticipantProfile(
    String userId,
  );
}
