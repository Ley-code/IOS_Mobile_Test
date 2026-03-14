import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/network/domain/repositories/network_repository.dart';

class FollowUser {
  final NetworkRepository repository;

  FollowUser(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await repository.followUser(userId);
  }
}
