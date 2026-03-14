import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';
import 'package:mobile_app/features/chat/domain/repositories/chat_repository.dart';

class GetUserConversations {
  final ChatRepository repository;

  GetUserConversations(this.repository);

  Future<Either<Failure, List<Conversation>>> call({
    required String userId,
    required String role,
  }) async {
    return await repository.getUserConversations(userId, role);
  }
}
