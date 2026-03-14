import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/authentication/data/models/auth_response_model.dart';
import 'package:mobile_app/features/authentication/domain/repository/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/authentication/domain/entities/freelancer_sign_up_entity.dart';

class FreelancerSignUpUseCase
    extends UseCase<AuthResponseModel, FreelancerSignupParams> {
  final AuthRepository authRepository;

  FreelancerSignUpUseCase({required this.authRepository});
  @override
  Future<Either<Failure, AuthResponseModel>> call(FreelancerSignupParams params) {
    return authRepository.registerFreelancer(params.freelancerSignupEntity);
  }
}

class FreelancerSignupParams extends Equatable {
  final FreelancerSignupEntity freelancerSignupEntity;

  const FreelancerSignupParams({required this.freelancerSignupEntity});

  @override
  List<Object?> get props => [freelancerSignupEntity];
}
