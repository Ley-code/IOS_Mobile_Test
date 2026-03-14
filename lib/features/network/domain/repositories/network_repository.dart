import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/network/domain/entities/network_entity.dart';

abstract class NetworkRepository {
  Future<Either<Failure, void>> followUser(String userId);
  Future<Either<Failure, void>> unfollowUser(String userId);
  Future<Either<Failure, List<NetworkUser>>> getFollowers(String userId);
  Future<Either<Failure, List<NetworkUser>>> getFollowing(String userId);
  Future<Either<Failure, NetworkStats>> getNetworkStats(String userId);
  Future<Either<Failure, bool>> checkFollowStatus(String userId);
}
