import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/repositories/influencer_dashboard_repository.dart';

class AddPortfolioItemParams {
  final PortfolioItemEntity item;
  final File? coverImage;

  AddPortfolioItemParams({required this.item, this.coverImage});
}

class AddPortfolioItem implements UseCase<void, AddPortfolioItemParams> {
  final InfluencerDashboardRepository repository;

  AddPortfolioItem(this.repository);

  @override
  Future<Either<Failure, void>> call(AddPortfolioItemParams params) async {
    return await repository.addPortfolioItem(
      params.item,
      coverImage: params.coverImage,
    );
  }
}
