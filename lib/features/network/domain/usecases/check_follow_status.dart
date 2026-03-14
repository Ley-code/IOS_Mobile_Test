import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/network/domain/repositories/network_repository.dart';

class CheckFollowStatus {
  final NetworkRepository repository;

  CheckFollowStatus(this.repository);

  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.checkFollowStatus(userId);
  }
}
