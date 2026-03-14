import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/features/network/data/datasources/network_remote_data_source.dart';
import 'package:mobile_app/features/network/domain/repositories/network_repository.dart';
import 'package:mobile_app/features/network/domain/entities/network_entity.dart';

class NetworkRepositoryImpl implements NetworkRepository {
  final NetworkRemoteDataSource remoteDataSource;

  NetworkRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> followUser(String userId) async {
    try {
      await remoteDataSource.followUser(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to follow user'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser(String userId) async {
    try {
      await remoteDataSource.unfollowUser(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to unfollow user'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<NetworkUser>>> getFollowers(String userId) async {
    try {
      final models = await remoteDataSource.getFollowers(userId);
      final entities = models.map((m) => NetworkUser(
        id: m.id,
        userName: m.userName,
        firstName: m.firstName,
        lastName: m.lastName,
        profilePictureUrl: m.profilePictureUrl,
        email: m.email,
      )).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch followers'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<NetworkUser>>> getFollowing(String userId) async {
    try {
      final models = await remoteDataSource.getFollowing(userId);
      final entities = models.map((m) => NetworkUser(
        id: m.id,
        userName: m.userName,
        firstName: m.firstName,
        lastName: m.lastName,
        profilePictureUrl: m.profilePictureUrl,
        email: m.email,
      )).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch following'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, NetworkStats>> getNetworkStats(String userId) async {
    try {
      final model = await remoteDataSource.getNetworkStats(userId);
      final entity = NetworkStats(
        followers: model.followers,
        following: model.following,
      );
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch network stats'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkFollowStatus(String userId) async {
    try {
      final model = await remoteDataSource.checkFollowStatus(userId);
      return Right(model.isFollowing);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to check follow status'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
