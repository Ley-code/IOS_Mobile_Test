import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/content_creator/dashboard/data/datasources/influencer_remote_data_source.dart';
import 'package:mobile_app/features/content_creator/dashboard/data/models/portfolio_item_model.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/repositories/influencer_dashboard_repository.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/update_profile_params.dart';

class InfluencerDashboardRepositoryImpl
    implements InfluencerDashboardRepository {
  final InfluencerRemoteDataSource remoteDataSource;

  InfluencerDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PortfolioItemEntity>>> getPortfolioItems() async {
    try {
      final remoteData = await remoteDataSource.getPortfolioItems();
      return Right(remoteData);
    } on ServerException {
      return Left(ServerFailure("Failed to get portfolio items"));
    } catch (e) {
      return Left(ServerFailure("Failed to get portfolio items"));
    }
  }

  @override
  Future<Either<Failure, void>> addPortfolioItem(
    PortfolioItemEntity item, {
    File? coverImage,
  }) async {
    try {
      final model = PortfolioItemModel(
        title: item.title,
        description: item.description,
        type: item.type,
        link: item.link,
      );
      await remoteDataSource.addPortfolioItem(model, coverImage: coverImage);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure("Failed to add portfolio item"));
    } catch (e) {
      return Left(ServerFailure("Failed to add portfolio item"));
    }
  }

  @override
  Future<Either<Failure, void>> updateFreelancerProfile(
    UpdateFreelancerParams params,
  ) async {
    try {
      await remoteDataSource.updateFreelancerProfile(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update profile'));
    } catch (e) {
      return Left(ServerFailure("Failed to update profile"));
    }
  }

  @override
  Future<Either<Failure, void>> updatePortfolioItem(
    PortfolioItemEntity item,
  ) async {
    try {
      final model = PortfolioItemModel(
        id: item.id,
        title: item.title,
        description: item.description,
        type: item.type,
        link: item.link,
      );
      await remoteDataSource.updatePortfolioItem(model);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure("Failed to update portfolio item"));
    } catch (e) {
      return Left(ServerFailure("Failed to update portfolio item"));
    }
  }

  @override
  Future<Either<Failure, void>> deletePortfolioItem(String portfolioId) async {
    try {
      await remoteDataSource.deletePortfolioItem(portfolioId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure("Failed to delete portfolio item"));
    } catch (e) {
      return Left(ServerFailure("Failed to delete portfolio item"));
    }
  }

  @override
  Future<Either<Failure, int>> getProfileCompletionPercentage() async {
    try {
      final percentage = await remoteDataSource
          .getProfileCompletionPercentage();
      return Right(percentage);
    } on ServerException {
      return Left(ServerFailure("Failed to get profile completion"));
    } catch (e) {
      return Left(ServerFailure("Failed to get profile completion"));
    }
  }
}
