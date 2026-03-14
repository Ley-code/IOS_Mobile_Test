import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/freelancer_profile/data/models/freelancer_profile_detail_model.dart';
import 'package:mobile_app/features/freelancer_profile/domain/repositories/freelancer_profile_repository.dart';

class GetFreelancerProfile
    extends UseCase<FreelancerProfileDetailModel, GetFreelancerProfileParams> {
  final FreelancerProfileRepository repository;

  GetFreelancerProfile({required this.repository});

  @override
  Future<Either<Failure, FreelancerProfileDetailModel>> call(
    GetFreelancerProfileParams params,
  ) async {
    return await repository.getFreelancerProfile(params.freelancerId);
  }
}

class GetFreelancerProfileParams extends Equatable {
  final String freelancerId;

  const GetFreelancerProfileParams({required this.freelancerId});

  @override
  List<Object?> get props => [freelancerId];
}
