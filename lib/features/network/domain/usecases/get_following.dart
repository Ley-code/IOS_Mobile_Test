import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/network/domain/entities/network_entity.dart';
import 'package:mobile_app/features/network/domain/repositories/network_repository.dart';

class GetFollowing extends UseCase<List<NetworkUser>, GetFollowingParams> {
  final NetworkRepository repository;

  GetFollowing(this.repository);

  @override
  Future<Either<Failure, List<NetworkUser>>> call(
    GetFollowingParams params,
  ) async {
    return await repository.getFollowing(params.userId);
  }
}

class GetFollowingParams extends Equatable {
  final String userId;

  const GetFollowingParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
