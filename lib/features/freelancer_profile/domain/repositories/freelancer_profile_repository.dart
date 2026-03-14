import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/freelancer_profile/data/models/freelancer_profile_detail_model.dart';

abstract class FreelancerProfileRepository {
  Future<Either<Failure, FreelancerProfileDetailModel>> getFreelancerProfile(
    String freelancerId,
  );
  Future<Either<Failure, List<ContractModel>>> getFreelancerContracts(
    String freelancerId,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getFreelancerRatings(
    String userId,
  );
  Future<Either<Failure, List<PortfolioItemModel>>> getFreelancerPortfolios({
    required String freelancerId,
    String? type,
    int page = 1,
    int pageSize = 10,
  });
}
