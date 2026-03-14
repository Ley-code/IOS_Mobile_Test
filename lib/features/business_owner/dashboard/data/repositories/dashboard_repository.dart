import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/data_sources/remote/dashboard_remote_data_source.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/job_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/user_profile_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/update_profile_params.dart';

abstract class DashboardRepository {
  Future<Either<Failure, UserProfileModel>> getUserProfile();
  Future<Either<Failure, List<JobModel>>> getClientJobs();
  Future<Either<Failure, void>> updateClientProfile(UpdateClientParams params);
  Future<Either<Failure, int>> getProfileCompletionPercentage();
}

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile() async {
    try {
      final profile = await remoteDataSource.getUserProfile();
      return Right(profile);
    } catch (e) {
      String errorMessage = 'Cannot fetch user profile.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<JobModel>>> getClientJobs() async {
    try {
      final jobs = await remoteDataSource.getClientJobs();
      return Right(jobs);
    } catch (e) {
      String errorMessage = 'Cannot fetch client jobs.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> updateClientProfile(
    UpdateClientParams params,
  ) async {
    try {
      await remoteDataSource.updateClientProfile(params);
      return const Right(null);
    } catch (e) {
      String errorMessage = 'Cannot update profile.';
      if (e is ServerException) {
        errorMessage = e.message ?? 'Cannot update profile.';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, int>> getProfileCompletionPercentage() async {
    try {
      final percentage = await remoteDataSource.getProfileCompletionPercentage();
      return Right(percentage);
    } catch (e) {
      String errorMessage = 'Cannot get profile completion.';
      if (e is ServerException) {
        errorMessage = e.message ?? 'Cannot get profile completion.';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }
}
