import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/repositories/influencer_dashboard_repository.dart';

class UpdatePortfolioItem implements UseCase<void, PortfolioItemEntity> {
  final InfluencerDashboardRepository repository;

  UpdatePortfolioItem(this.repository);

  @override
  Future<Either<Failure, void>> call(PortfolioItemEntity params) async {
    return await repository.updatePortfolioItem(params);
  }
}
