import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';
import 'package:mobile_app/features/chat/domain/repositories/chat_repository.dart';

class CreateOrGetConversation {
  final ChatRepository repository;

  CreateOrGetConversation(this.repository);

  Future<Either<Failure, Conversation>> call({
    required String clientId,
    required String freelancerId,
    String? jobId,
    String? proposalId,
  }) async {
    return await repository.createOrGetConversation(
      clientId: clientId,
      freelancerId: freelancerId,
      jobId: jobId,
      proposalId: proposalId,
    );
  }
}
