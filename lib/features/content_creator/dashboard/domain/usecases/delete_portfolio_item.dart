import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/repositories/influencer_dashboard_repository.dart';

class DeletePortfolioItem implements UseCase<void, String> {
  final InfluencerDashboardRepository repository;

  DeletePortfolioItem(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deletePortfolioItem(params);
  }
}
