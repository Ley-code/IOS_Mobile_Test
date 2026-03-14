import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/freelancer_profile/data/models/freelancer_profile_detail_model.dart';
import 'package:mobile_app/features/freelancer_profile/domain/repositories/freelancer_profile_repository.dart';

class GetFreelancerPortfolios
    extends UseCase<List<PortfolioItemModel>, GetFreelancerPortfoliosParams> {
  final FreelancerProfileRepository repository;

  GetFreelancerPortfolios({required this.repository});

  @override
  Future<Either<Failure, List<PortfolioItemModel>>> call(
    GetFreelancerPortfoliosParams params,
  ) async {
    return await repository.getFreelancerPortfolios(
      freelancerId: params.freelancerId,
      type: params.type,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetFreelancerPortfoliosParams extends Equatable {
  final String freelancerId;
  final String? type;
  final int page;
  final int pageSize;

  const GetFreelancerPortfoliosParams({
    required this.freelancerId,
    this.type,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [freelancerId, type, page, pageSize];
}
