import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/freelancer_profile/data/data_sources/remote/freelancer_profile_remote_data_source.dart';
import 'package:mobile_app/features/freelancer_profile/data/models/freelancer_profile_detail_model.dart';
import 'package:mobile_app/features/freelancer_profile/domain/repositories/freelancer_profile_repository.dart';

class FreelancerProfileRepositoryImpl implements FreelancerProfileRepository {
  final FreelancerProfileRemoteDataSource remoteDataSource;

  FreelancerProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FreelancerProfileDetailModel>> getFreelancerProfile(
    String freelancerId,
  ) async {
    try {
      final result = await remoteDataSource.getFreelancerProfile(freelancerId);
      return Right(FreelancerProfileDetailModel.fromJson(result));
    } catch (e) {
      String errorMessage = 'Cannot fetch freelancer profile.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<ContractModel>>> getFreelancerContracts(
    String freelancerId,
  ) async {
    try {
      final result = await remoteDataSource.getFreelancerContracts(
        freelancerId,
      );
      return Right(result.map((e) => ContractModel.fromJson(e)).toList());
    } catch (e) {
      String errorMessage = 'Cannot fetch contracts.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getFreelancerRatings(
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.getFreelancerRatings(userId);
      return Right(result);
    } catch (e) {
      String errorMessage = 'Cannot fetch ratings.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<PortfolioItemModel>>> getFreelancerPortfolios({
    required String freelancerId,
    String? type,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await remoteDataSource.getFreelancerPortfolios(
        freelancerId: freelancerId,
        type: type,
        page: page,
        pageSize: pageSize,
      );
      return Right(result.map((e) => PortfolioItemModel.fromJson(e)).toList());
    } catch (e) {
      String errorMessage = 'Cannot fetch portfolios.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }
}
