import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/chat/domain/repositories/chat_repository.dart';

class GetRocketChatConnectionInfo {
  final ChatRepository repository;

  GetRocketChatConnectionInfo(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String conversationId,
  ) async {
    return await repository.getRocketChatInfo(conversationId);
  }
}

