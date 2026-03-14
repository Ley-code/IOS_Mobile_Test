import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/authentication/domain/repository/auth_repo.dart';

class ConnectInstagramUseCase {
  final AuthRepository repository;

  ConnectInstagramUseCase(this.repository);

  Future<Either<Failure, void>> call(String code, String state) async {
    return await repository.connectInstagram(code, state);
  }
}
