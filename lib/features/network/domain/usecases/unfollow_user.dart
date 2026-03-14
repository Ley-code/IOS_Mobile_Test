import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/network/domain/repositories/network_repository.dart';

class UnfollowUser {
  final NetworkRepository repository;

  UnfollowUser(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await repository.unfollowUser(userId);
  }
}
