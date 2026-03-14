import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/authentication/domain/repository/auth_repo.dart';

class FinalizeInstagramSessionUseCase {
  final AuthRepository repository;

  FinalizeInstagramSessionUseCase(this.repository);

  Future<Either<Failure, void>> call(String sessionId) async {
    return await repository.finalizeInstagramSession(sessionId);
  }
}







