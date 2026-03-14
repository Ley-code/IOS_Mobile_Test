import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/freelancer_profile/domain/repositories/freelancer_profile_repository.dart';

class GetFreelancerRatings
    extends UseCase<List<Map<String, dynamic>>, GetFreelancerRatingsParams> {
  final FreelancerProfileRepository repository;

  GetFreelancerRatings({required this.repository});

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetFreelancerRatingsParams params,
  ) async {
    return await repository.getFreelancerRatings(params.userId);
  }
}

class GetFreelancerRatingsParams extends Equatable {
  final String userId;

  const GetFreelancerRatingsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
