import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/repositories/influencer_dashboard_repository.dart';

class GetPortfolioItems
    implements UseCase<List<PortfolioItemEntity>, NoParams> {
  final InfluencerDashboardRepository repository;

  GetPortfolioItems(this.repository);

  @override
  Future<Either<Failure, List<PortfolioItemEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getPortfolioItems();
  }
}
