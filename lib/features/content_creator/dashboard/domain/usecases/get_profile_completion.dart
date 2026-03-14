import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/repositories/influencer_dashboard_repository.dart';

class GetProfileCompletion implements UseCase<int, NoParams> {
  final InfluencerDashboardRepository repository;

  GetProfileCompletion(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.getProfileCompletionPercentage();
  }
}
