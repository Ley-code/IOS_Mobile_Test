import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/update_profile_params.dart';

abstract class InfluencerDashboardRepository {
  Future<Either<Failure, List<PortfolioItemEntity>>> getPortfolioItems();
  Future<Either<Failure, void>> addPortfolioItem(
    PortfolioItemEntity item, {
    File? coverImage,
  });
  Future<Either<Failure, void>> updateFreelancerProfile(
    UpdateFreelancerParams params,
  );
  Future<Either<Failure, void>> updatePortfolioItem(PortfolioItemEntity item);
  Future<Either<Failure, void>> deletePortfolioItem(String portfolioId);
  Future<Either<Failure, int>> getProfileCompletionPercentage();
}
