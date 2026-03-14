import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/chat/domain/repositories/chat_repository.dart';

class LoginToRocketChat {
  final ChatRepository repository;

  LoginToRocketChat(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String user,
    required String password,
  }) async {
    return await repository.loginToRocketChat(user, password);
  }
}
