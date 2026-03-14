import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/authentication/domain/entities/instagram_profile.dart';
import 'package:mobile_app/features/authentication/domain/repository/auth_repo.dart';

class ConsumeInstagramSessionUseCase {
  final AuthRepository repository;

  ConsumeInstagramSessionUseCase(this.repository);

  Future<Either<Failure, InstagramProfile>> call(String sessionId) async {
    return await repository.consumeInstagramSession(sessionId);
  }
}
