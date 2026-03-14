import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/network/domain/entities/network_entity.dart';
import 'package:mobile_app/features/network/domain/repositories/network_repository.dart';

class GetFollowers extends UseCase<List<NetworkUser>, GetFollowersParams> {
  final NetworkRepository repository;

  GetFollowers(this.repository);

  @override
  Future<Either<Failure, List<NetworkUser>>> call(
    GetFollowersParams params,
  ) async {
    return await repository.getFollowers(params.userId);
  }
}

class GetFollowersParams extends Equatable {
  final String userId;

  const GetFollowersParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
