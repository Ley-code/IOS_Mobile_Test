import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/freelancer_profile/data/models/freelancer_profile_detail_model.dart';
import 'package:mobile_app/features/freelancer_profile/domain/repositories/freelancer_profile_repository.dart';

class GetFreelancerContracts
    extends UseCase<List<ContractModel>, GetFreelancerContractsParams> {
  final FreelancerProfileRepository repository;

  GetFreelancerContracts({required this.repository});

  @override
  Future<Either<Failure, List<ContractModel>>> call(
    GetFreelancerContractsParams params,
  ) async {
    return await repository.getFreelancerContracts(params.freelancerId);
  }
}

class GetFreelancerContractsParams extends Equatable {
  final String freelancerId;

  const GetFreelancerContractsParams({required this.freelancerId});

  @override
  List<Object?> get props => [freelancerId];
}
