import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/chat/domain/repositories/chat_repository.dart';

class InitializeChatRoom {
  final ChatRepository repository;

  InitializeChatRoom(this.repository);

  Future<Either<Failure, void>> call(String conversationId) async {
    return await repository.createRoom(conversationId);
  }
}

